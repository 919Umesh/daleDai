-- A successful rental application becomes an active tenancy automatically.
CREATE OR REPLACE FUNCTION public.create_tenancy_from_confirmed_booking()
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
  IF NEW.status <> 'confirmed' THEN
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

DROP TRIGGER IF EXISTS trg_create_tenancy_from_confirmed_booking
  ON public.bookings;
CREATE TRIGGER trg_create_tenancy_from_confirmed_booking
  AFTER INSERT OR UPDATE OF status ON public.bookings
  FOR EACH ROW
  EXECUTE FUNCTION public.create_tenancy_from_confirmed_booking();

-- Backfill the latest confirmed application for rooms without an active tenancy.
DO $$
DECLARE v_booking record;
BEGIN
  FOR v_booking IN
    SELECT b.booking_id, b.room_id
    FROM public.bookings b
    WHERE b.status = 'confirmed'
    ORDER BY b.updated_at DESC
  LOOP
    IF NOT EXISTS (
      SELECT 1 FROM public.tenancies t
      WHERE t.room_id = v_booking.room_id
        AND t.status IN ('active', 'notice')
    ) THEN
      UPDATE public.bookings
      SET status = 'confirmed'
      WHERE booking_id = v_booking.booking_id;
    END IF;
  END LOOP;
END;
$$;
