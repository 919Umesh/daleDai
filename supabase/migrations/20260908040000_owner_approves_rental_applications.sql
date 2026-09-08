-- Approval, rather than payment submission, creates the active tenancy.
DROP TRIGGER IF EXISTS trg_create_tenancy_from_confirmed_booking
  ON public.bookings;

CREATE OR REPLACE FUNCTION public.create_tenancy_from_completed_booking()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public AS $$
DECLARE
  v_property_id uuid;
  v_tenancy_id uuid;
  v_tenant_name text;
  v_tenant_email text;
  v_tenant_phone text;
  v_due_day integer;
  v_month date;
  v_end date;
BEGIN
  IF NEW.status <> 'completed' THEN
    RETURN NEW;
  END IF;

  SELECT r.property_id, COALESCE(r.rent_due_day, 1)
  INTO v_property_id, v_due_day
  FROM public.rooms r
  WHERE r.room_id = NEW.room_id;

  IF v_property_id IS NULL OR v_property_id IS DISTINCT FROM NEW.property_id THEN
    RAISE EXCEPTION 'Booking property and room do not match';
  END IF;

  IF EXISTS (
    SELECT 1 FROM public.tenancies t
    WHERE t.room_id = NEW.room_id
      AND t.status IN ('active', 'notice')
      AND t.tenant_user_id IS DISTINCT FROM NEW.tenant_id
  ) THEN
    RAISE EXCEPTION 'This unit already has an active tenant';
  END IF;

  SELECT u.name, u.email, u.phone
  INTO v_tenant_name, v_tenant_email, v_tenant_phone
  FROM public.users u
  WHERE u.user_id = NEW.tenant_id;

  INSERT INTO public.tenancies (
    owner_id, property_id, room_id, tenant_user_id, tenant_name,
    tenant_phone, tenant_email, lease_start, lease_end, monthly_rent,
    security_deposit, rent_due_day
  )
  VALUES (
    NEW.landlord_id, v_property_id, NEW.room_id, NEW.tenant_id,
    COALESCE(NULLIF(trim(v_tenant_name), ''), 'Tenant'),
    v_tenant_phone, v_tenant_email, NEW.move_in_date, NEW.move_out_date,
    NEW.monthly_rent, NEW.security_deposit, v_due_day
  )
  ON CONFLICT (room_id) WHERE status IN ('active', 'notice') DO NOTHING
  RETURNING tenancy_id INTO v_tenancy_id;

  IF v_tenancy_id IS NULL THEN
    SELECT t.tenancy_id INTO v_tenancy_id
    FROM public.tenancies t
    WHERE t.room_id = NEW.room_id
      AND t.tenant_user_id = NEW.tenant_id
      AND t.status IN ('active', 'notice')
    LIMIT 1;
  END IF;

  UPDATE public.rooms
  SET is_occupied = true,
      rent_amount = NEW.monthly_rent,
      security_deposit = NEW.security_deposit
  WHERE room_id = NEW.room_id;

  v_month := date_trunc('month', NEW.move_in_date)::date;
  v_end := LEAST(
    COALESCE(NEW.move_out_date, (v_month + interval '11 months')::date),
    (v_month + interval '11 months')::date
  );
  WHILE v_month <= date_trunc('month', v_end)::date LOOP
    INSERT INTO public.rent_payments (
      tenancy_id, owner_id, due_month, due_date, amount, status
    )
    VALUES (
      v_tenancy_id, NEW.landlord_id, v_month,
      make_date(extract(year FROM v_month)::int,
                extract(month FROM v_month)::int, v_due_day),
      NEW.monthly_rent,
      CASE
        WHEN make_date(extract(year FROM v_month)::int,
                       extract(month FROM v_month)::int, v_due_day) > CURRENT_DATE
        THEN 'upcoming' ELSE 'due'
      END
    )
    ON CONFLICT (tenancy_id, due_month) DO NOTHING;
    v_month := (v_month + interval '1 month')::date;
  END LOOP;

  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_create_tenancy_from_completed_booking
  AFTER INSERT OR UPDATE OF status ON public.bookings
  FOR EACH ROW
  EXECUTE FUNCTION public.create_tenancy_from_completed_booking();

CREATE OR REPLACE FUNCTION public.restrict_booking_status_changes()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = public AS $$
BEGIN
  IF auth.uid() IS NOT NULL
     AND NEW.status IS DISTINCT FROM OLD.status
     AND auth.uid() IS DISTINCT FROM OLD.landlord_id THEN
    RAISE EXCEPTION 'Only the property owner can change application status';
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_restrict_booking_status_changes ON public.bookings;
CREATE TRIGGER trg_restrict_booking_status_changes
  BEFORE UPDATE OF status ON public.bookings
  FOR EACH ROW EXECUTE FUNCTION public.restrict_booking_status_changes();

CREATE OR REPLACE FUNCTION public.get_property_applications(p_property_id uuid)
RETURNS TABLE(
  booking_id uuid,
  room_id uuid,
  room_number text,
  tenant_id uuid,
  tenant_name text,
  tenant_email text,
  tenant_phone text,
  move_in_date date,
  move_out_date date,
  monthly_rent bigint,
  security_deposit bigint,
  peoples integer,
  profession text,
  payment_method text,
  created_at timestamptz
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public AS $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM public.properties p
    WHERE p.property_id = p_property_id
      AND p.landlord_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'Not authorized for this property';
  END IF;

  RETURN QUERY
  SELECT b.booking_id, b.room_id, r.room_number, b.tenant_id,
    u.name, u.email, u.phone, b.move_in_date, b.move_out_date,
    b.monthly_rent, b.security_deposit, b.peoples, b.profession,
    b.payment_method, b.created_at
  FROM public.bookings b
  JOIN public.rooms r ON r.room_id = b.room_id
  JOIN public.users u ON u.user_id = b.tenant_id
  WHERE b.property_id = p_property_id
    AND b.landlord_id = auth.uid()
    AND b.status = 'pending'
  ORDER BY b.created_at DESC;
END;
$$;

CREATE OR REPLACE FUNCTION public.approve_rental_application(p_booking_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public AS $$
BEGIN
  UPDATE public.bookings
  SET status = 'completed', updated_at = now()
  WHERE booking_id = p_booking_id
    AND landlord_id = auth.uid()
    AND status = 'pending';

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Pending application not found or not authorized';
  END IF;
END;
$$;

REVOKE ALL ON FUNCTION public.get_property_applications(uuid) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.approve_rental_application(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.get_property_applications(uuid),
  public.approve_rental_application(uuid) TO authenticated;

-- Preserve already-created tenancies; return unassigned legacy applications
-- to the new owner-approval queue.
UPDATE public.bookings b
SET status = CASE
  WHEN EXISTS (
    SELECT 1 FROM public.tenancies t
    WHERE t.room_id = b.room_id
      AND t.tenant_user_id = b.tenant_id
      AND t.status IN ('active', 'notice')
  ) THEN 'completed'
  ELSE 'pending'
END
WHERE b.status = 'confirmed';
