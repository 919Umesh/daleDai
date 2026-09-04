-- Property management domain: owner onboarding, tenancies, rent ledger,
-- expenses, maintenance, secure owner operations and dashboard views.

ALTER TABLE public.rooms
  ADD COLUMN IF NOT EXISTS unit_kind text NOT NULL DEFAULT 'room',
  ADD COLUMN IF NOT EXISTS rent_due_day integer NOT NULL DEFAULT 1,
  ADD COLUMN IF NOT EXISTS grace_period_days integer NOT NULL DEFAULT 5;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'rooms_unit_kind_check') THEN
    ALTER TABLE public.rooms ADD CONSTRAINT rooms_unit_kind_check
      CHECK (unit_kind IN ('room', 'flat', 'apartment', 'shop', 'office', 'other'));
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'rooms_rent_due_day_check') THEN
    ALTER TABLE public.rooms ADD CONSTRAINT rooms_rent_due_day_check
      CHECK (rent_due_day BETWEEN 1 AND 28);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'rooms_grace_period_check') THEN
    ALTER TABLE public.rooms ADD CONSTRAINT rooms_grace_period_check
      CHECK (grace_period_days BETWEEN 0 AND 30);
  END IF;
END $$;

CREATE TABLE IF NOT EXISTS public.owner_profiles (
  user_id uuid PRIMARY KEY REFERENCES public.users(user_id) ON DELETE CASCADE,
  business_name text NOT NULL,
  business_address text,
  tax_identifier text,
  onboarding_complete boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.tenancies (
  tenancy_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES public.users(user_id) ON DELETE CASCADE,
  property_id uuid NOT NULL REFERENCES public.properties(property_id) ON DELETE CASCADE,
  room_id uuid NOT NULL REFERENCES public.rooms(room_id) ON DELETE CASCADE,
  tenant_user_id uuid REFERENCES public.users(user_id) ON DELETE SET NULL,
  tenant_name text NOT NULL,
  tenant_phone text,
  tenant_email text,
  emergency_contact text,
  lease_start date NOT NULL,
  lease_end date,
  monthly_rent numeric(12,2) NOT NULL CHECK (monthly_rent >= 0),
  security_deposit numeric(12,2) NOT NULL DEFAULT 0 CHECK (security_deposit >= 0),
  rent_due_day integer NOT NULL DEFAULT 1 CHECK (rent_due_day BETWEEN 1 AND 28),
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'notice', 'ended')),
  notes text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CHECK (lease_end IS NULL OR lease_end >= lease_start)
);

CREATE UNIQUE INDEX IF NOT EXISTS tenancies_one_active_room_idx
  ON public.tenancies(room_id) WHERE status IN ('active', 'notice');
CREATE INDEX IF NOT EXISTS tenancies_owner_idx ON public.tenancies(owner_id);
CREATE INDEX IF NOT EXISTS tenancies_tenant_idx ON public.tenancies(tenant_user_id);

CREATE TABLE IF NOT EXISTS public.rent_payments (
  rent_payment_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenancy_id uuid NOT NULL REFERENCES public.tenancies(tenancy_id) ON DELETE CASCADE,
  owner_id uuid NOT NULL REFERENCES public.users(user_id) ON DELETE CASCADE,
  due_month date NOT NULL,
  due_date date NOT NULL,
  amount numeric(12,2) NOT NULL CHECK (amount >= 0),
  paid_amount numeric(12,2) NOT NULL DEFAULT 0 CHECK (paid_amount >= 0),
  paid_on timestamptz,
  payment_method text,
  transaction_reference text,
  status text NOT NULL DEFAULT 'due' CHECK (status IN ('upcoming', 'due', 'partial', 'paid', 'waived')),
  notes text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (tenancy_id, due_month)
);
CREATE INDEX IF NOT EXISTS rent_payments_owner_due_idx
  ON public.rent_payments(owner_id, due_date);

CREATE TABLE IF NOT EXISTS public.property_expenses (
  expense_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES public.users(user_id) ON DELETE CASCADE,
  property_id uuid NOT NULL REFERENCES public.properties(property_id) ON DELETE CASCADE,
  room_id uuid REFERENCES public.rooms(room_id) ON DELETE SET NULL,
  category text NOT NULL DEFAULT 'other',
  description text NOT NULL,
  amount numeric(12,2) NOT NULL CHECK (amount > 0),
  expense_date date NOT NULL DEFAULT CURRENT_DATE,
  receipt_url text,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS property_expenses_owner_date_idx
  ON public.property_expenses(owner_id, expense_date);

CREATE TABLE IF NOT EXISTS public.maintenance_requests (
  maintenance_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES public.users(user_id) ON DELETE CASCADE,
  property_id uuid NOT NULL REFERENCES public.properties(property_id) ON DELETE CASCADE,
  room_id uuid REFERENCES public.rooms(room_id) ON DELETE SET NULL,
  tenancy_id uuid REFERENCES public.tenancies(tenancy_id) ON DELETE SET NULL,
  title text NOT NULL,
  description text,
  priority text NOT NULL DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high', 'urgent')),
  status text NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'in_progress', 'resolved', 'cancelled')),
  estimated_cost numeric(12,2),
  actual_cost numeric(12,2),
  reported_at timestamptz NOT NULL DEFAULT now(),
  resolved_at timestamptz,
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS maintenance_owner_status_idx
  ON public.maintenance_requests(owner_id, status);

-- Keep the public profile in sync for email/password and OAuth registrations.
CREATE OR REPLACE FUNCTION public.handle_new_auth_user()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE v_type public.user_type;
BEGIN
  v_type := CASE WHEN NEW.raw_user_meta_data->>'user_type' IN ('tenant','landlord','admin')
    THEN (NEW.raw_user_meta_data->>'user_type')::public.user_type
    ELSE 'tenant'::public.user_type END;
  INSERT INTO public.users(user_id, name, email, profile_image, is_verified, user_type)
  VALUES(
    NEW.id,
    COALESCE(NULLIF(NEW.raw_user_meta_data->>'name',''), NULLIF(NEW.raw_user_meta_data->>'full_name',''), split_part(COALESCE(NEW.email,''),'@',1), 'User'),
    COALESCE(NEW.email, NEW.id::text || '@private.local'),
    COALESCE(NEW.raw_user_meta_data->>'avatar_url', NEW.raw_user_meta_data->>'picture'),
    NEW.email_confirmed_at IS NOT NULL,
    v_type
  )
  ON CONFLICT (user_id) DO UPDATE SET
    name = COALESCE(NULLIF(EXCLUDED.name,''), users.name),
    profile_image = COALESCE(EXCLUDED.profile_image, users.profile_image),
    is_verified = EXCLUDED.is_verified;
  RETURN NEW;
END $$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created AFTER INSERT OR UPDATE OF email_confirmed_at
  ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_new_auth_user();

DROP TRIGGER IF EXISTS trg_owner_profiles_updated_at ON public.owner_profiles;
CREATE TRIGGER trg_owner_profiles_updated_at BEFORE UPDATE ON public.owner_profiles
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
DROP TRIGGER IF EXISTS trg_tenancies_updated_at ON public.tenancies;
CREATE TRIGGER trg_tenancies_updated_at BEFORE UPDATE ON public.tenancies
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
DROP TRIGGER IF EXISTS trg_rent_payments_updated_at ON public.rent_payments;
CREATE TRIGGER trg_rent_payments_updated_at BEFORE UPDATE ON public.rent_payments
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
DROP TRIGGER IF EXISTS trg_maintenance_updated_at ON public.maintenance_requests;
CREATE TRIGGER trg_maintenance_updated_at BEFORE UPDATE ON public.maintenance_requests
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

ALTER TABLE public.owner_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tenancies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rent_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.property_expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.maintenance_requests ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Owners manage their profile" ON public.owner_profiles FOR ALL
  TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY "Owners manage tenancies" ON public.tenancies FOR ALL TO authenticated
  USING (owner_id = auth.uid()) WITH CHECK (owner_id = auth.uid());
CREATE POLICY "Tenants view their tenancy" ON public.tenancies FOR SELECT TO authenticated
  USING (tenant_user_id = auth.uid());
CREATE POLICY "Owners manage rent ledger" ON public.rent_payments FOR ALL TO authenticated
  USING (owner_id = auth.uid()) WITH CHECK (owner_id = auth.uid());
CREATE POLICY "Tenants view rent ledger" ON public.rent_payments FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM public.tenancies t WHERE t.tenancy_id = rent_payments.tenancy_id AND t.tenant_user_id = auth.uid()));
CREATE POLICY "Owners manage expenses" ON public.property_expenses FOR ALL TO authenticated
  USING (owner_id = auth.uid()) WITH CHECK (owner_id = auth.uid());
CREATE POLICY "Owners manage maintenance" ON public.maintenance_requests FOR ALL TO authenticated
  USING (owner_id = auth.uid()) WITH CHECK (owner_id = auth.uid());
CREATE POLICY "Tenants view their maintenance" ON public.maintenance_requests FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM public.tenancies t WHERE t.tenancy_id = maintenance_requests.tenancy_id AND t.tenant_user_id = auth.uid()));

-- Property and room writes are owner-scoped; public marketplace reads remain available.
DROP POLICY IF EXISTS "Allow all operations on properties" ON public.properties;
CREATE POLICY "Public can browse active properties" ON public.properties FOR SELECT USING (is_active IS TRUE OR landlord_id = auth.uid());
CREATE POLICY "Owners insert properties" ON public.properties FOR INSERT TO authenticated WITH CHECK (landlord_id = auth.uid());
CREATE POLICY "Owners update properties" ON public.properties FOR UPDATE TO authenticated USING (landlord_id = auth.uid()) WITH CHECK (landlord_id = auth.uid());
CREATE POLICY "Owners delete properties" ON public.properties FOR DELETE TO authenticated USING (landlord_id = auth.uid());

DROP POLICY IF EXISTS "Allow all operations on rooms" ON public.rooms;
CREATE POLICY "Public can browse rooms" ON public.rooms FOR SELECT USING (true);
CREATE POLICY "Owners insert rooms" ON public.rooms FOR INSERT TO authenticated WITH CHECK
  (EXISTS (SELECT 1 FROM public.properties p WHERE p.property_id = rooms.property_id AND p.landlord_id = auth.uid()));
CREATE POLICY "Owners update rooms" ON public.rooms FOR UPDATE TO authenticated USING
  (EXISTS (SELECT 1 FROM public.properties p WHERE p.property_id = rooms.property_id AND p.landlord_id = auth.uid()));
CREATE POLICY "Owners delete rooms" ON public.rooms FOR DELETE TO authenticated USING
  (EXISTS (SELECT 1 FROM public.properties p WHERE p.property_id = rooms.property_id AND p.landlord_id = auth.uid()));

DROP POLICY IF EXISTS "Allow all operations on images" ON public.images;
CREATE POLICY "Public can browse property images" ON public.images FOR SELECT USING (true);
CREATE POLICY "Owners insert property images" ON public.images FOR INSERT TO authenticated WITH CHECK
  (EXISTS (SELECT 1 FROM public.properties p WHERE p.property_id = images.property_id AND p.landlord_id = auth.uid()));
CREATE POLICY "Owners update property images" ON public.images FOR UPDATE TO authenticated USING
  (EXISTS (SELECT 1 FROM public.properties p WHERE p.property_id = images.property_id AND p.landlord_id = auth.uid()));
CREATE POLICY "Owners delete property images" ON public.images FOR DELETE TO authenticated USING
  (EXISTS (SELECT 1 FROM public.properties p WHERE p.property_id = images.property_id AND p.landlord_id = auth.uid()));

DROP POLICY IF EXISTS "Allow all operations on room_images" ON public.room_images;
CREATE POLICY "Public can browse room images" ON public.room_images FOR SELECT USING (true);
CREATE POLICY "Owners insert room images" ON public.room_images FOR INSERT TO authenticated WITH CHECK
  (EXISTS (SELECT 1 FROM public.rooms r JOIN public.properties p ON p.property_id = r.property_id WHERE r.room_id = room_images.room_id AND p.landlord_id = auth.uid()));
CREATE POLICY "Owners update room images" ON public.room_images FOR UPDATE TO authenticated USING
  (EXISTS (SELECT 1 FROM public.rooms r JOIN public.properties p ON p.property_id = r.property_id WHERE r.room_id = room_images.room_id AND p.landlord_id = auth.uid()));
CREATE POLICY "Owners delete room images" ON public.room_images FOR DELETE TO authenticated USING
  (EXISTS (SELECT 1 FROM public.rooms r JOIN public.properties p ON p.property_id = r.property_id WHERE r.room_id = room_images.room_id AND p.landlord_id = auth.uid()));

DROP POLICY IF EXISTS "Allow all operations on users" ON public.users;
CREATE POLICY "Users are publicly readable" ON public.users FOR SELECT USING (true);
CREATE POLICY "Users insert own profile" ON public.users FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY "Users update own profile" ON public.users FOR UPDATE TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

CREATE OR REPLACE FUNCTION public.assign_tenant(
  p_property_id uuid, p_room_id uuid, p_tenant_name text,
  p_tenant_phone text DEFAULT NULL, p_tenant_email text DEFAULT NULL,
  p_emergency_contact text DEFAULT NULL, p_lease_start date DEFAULT CURRENT_DATE,
  p_lease_end date DEFAULT NULL, p_monthly_rent numeric DEFAULT 0,
  p_security_deposit numeric DEFAULT 0, p_rent_due_day integer DEFAULT 1,
  p_notes text DEFAULT NULL
) RETURNS uuid LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
  v_owner uuid := auth.uid();
  v_tenancy uuid;
  v_month date;
  v_end date;
BEGIN
  IF v_owner IS NULL OR NOT EXISTS (
    SELECT 1 FROM properties WHERE property_id = p_property_id AND landlord_id = v_owner
  ) THEN RAISE EXCEPTION 'Not authorized for this property'; END IF;
  IF NOT EXISTS (SELECT 1 FROM rooms WHERE room_id = p_room_id AND property_id = p_property_id) THEN
    RAISE EXCEPTION 'Unit does not belong to this property';
  END IF;
  IF EXISTS (SELECT 1 FROM tenancies WHERE room_id = p_room_id AND status IN ('active','notice')) THEN
    RAISE EXCEPTION 'Unit already has an active tenant';
  END IF;

  INSERT INTO tenancies(owner_id, property_id, room_id, tenant_name, tenant_phone,
    tenant_email, emergency_contact, lease_start, lease_end, monthly_rent,
    security_deposit, rent_due_day, notes)
  VALUES(v_owner, p_property_id, p_room_id, trim(p_tenant_name), p_tenant_phone,
    p_tenant_email, p_emergency_contact, p_lease_start, p_lease_end, p_monthly_rent,
    p_security_deposit, p_rent_due_day, p_notes)
  RETURNING tenancy_id INTO v_tenancy;

  UPDATE rooms SET is_occupied = true, rent_amount = p_monthly_rent,
    security_deposit = p_security_deposit, rent_due_day = p_rent_due_day
  WHERE room_id = p_room_id;

  v_month := date_trunc('month', p_lease_start)::date;
  v_end := LEAST(COALESCE(p_lease_end, (v_month + interval '11 months')::date),
                 (v_month + interval '11 months')::date);
  WHILE v_month <= date_trunc('month', v_end)::date LOOP
    INSERT INTO rent_payments(tenancy_id, owner_id, due_month, due_date, amount, status)
    VALUES(v_tenancy, v_owner, v_month,
      make_date(extract(year FROM v_month)::int, extract(month FROM v_month)::int, p_rent_due_day),
      p_monthly_rent,
      CASE WHEN make_date(extract(year FROM v_month)::int, extract(month FROM v_month)::int, p_rent_due_day) > CURRENT_DATE THEN 'upcoming' ELSE 'due' END)
    ON CONFLICT (tenancy_id, due_month) DO NOTHING;
    v_month := (v_month + interval '1 month')::date;
  END LOOP;
  RETURN v_tenancy;
END $$;

CREATE OR REPLACE FUNCTION public.vacate_tenant(p_tenancy_id uuid)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE v_room uuid;
BEGIN
  UPDATE tenancies SET status = 'ended', lease_end = COALESCE(lease_end, CURRENT_DATE)
  WHERE tenancy_id = p_tenancy_id AND owner_id = auth.uid() AND status <> 'ended'
  RETURNING room_id INTO v_room;
  IF v_room IS NULL THEN RAISE EXCEPTION 'Active tenancy not found'; END IF;
  UPDATE rooms SET is_occupied = false, available_from = CURRENT_DATE WHERE room_id = v_room;
  UPDATE rent_payments SET status = 'waived'
    WHERE tenancy_id = p_tenancy_id AND paid_amount = 0 AND due_date > CURRENT_DATE;
END $$;

CREATE OR REPLACE FUNCTION public.record_rent_payment(
  p_rent_payment_id uuid, p_amount numeric, p_method text DEFAULT 'cash', p_notes text DEFAULT NULL
) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  IF p_amount <= 0 THEN RAISE EXCEPTION 'Payment amount must be positive'; END IF;
  UPDATE rent_payments
  SET paid_amount = LEAST(amount, paid_amount + p_amount), paid_on = now(),
      payment_method = p_method, notes = COALESCE(p_notes, notes),
      status = CASE WHEN paid_amount + p_amount >= amount THEN 'paid' ELSE 'partial' END
  WHERE rent_payment_id = p_rent_payment_id AND owner_id = auth.uid();
  IF NOT FOUND THEN RAISE EXCEPTION 'Rent payment not found'; END IF;
END $$;

DROP VIEW IF EXISTS public.owner_property_summary;
CREATE VIEW public.owner_property_summary WITH (security_invoker = true) AS
SELECT p.*, count(r.room_id)::int AS unit_count,
  count(r.room_id) FILTER (WHERE r.is_occupied)::int AS occupied_count,
  COALESCE(sum(r.rent_amount), 0)::numeric AS monthly_potential
FROM properties p LEFT JOIN rooms r ON r.property_id = p.property_id
GROUP BY p.property_id;

DROP VIEW IF EXISTS public.owner_unit_details;
CREATE VIEW public.owner_unit_details WITH (security_invoker = true) AS
SELECT r.*, t.tenancy_id, t.tenant_name, t.tenant_phone, t.tenant_email,
  t.lease_start, t.lease_end, t.rent_due_day AS tenancy_rent_due_day,
  next_payment.due_date AS next_due_date,
  COALESCE(next_payment.amount - next_payment.paid_amount, 0)::numeric AS balance_due
FROM rooms r
LEFT JOIN LATERAL (
  SELECT * FROM tenancies x WHERE x.room_id = r.room_id AND x.status IN ('active','notice') LIMIT 1
) t ON true
LEFT JOIN LATERAL (
  SELECT rp.* FROM rent_payments rp WHERE rp.tenancy_id = t.tenancy_id
    AND rp.status IN ('upcoming','due','partial') ORDER BY rp.due_date LIMIT 1
) next_payment ON true;

DROP VIEW IF EXISTS public.owner_rent_ledger;
CREATE VIEW public.owner_rent_ledger WITH (security_invoker = true) AS
SELECT rp.*, t.tenant_name, r.room_number, p.title AS property_title
FROM rent_payments rp JOIN tenancies t ON t.tenancy_id = rp.tenancy_id
JOIN rooms r ON r.room_id = t.room_id JOIN properties p ON p.property_id = t.property_id;

DROP VIEW IF EXISTS public.owner_dashboard_summary;
CREATE VIEW public.owner_dashboard_summary WITH (security_invoker = true) AS
SELECT u.user_id AS owner_id,
  (SELECT count(*) FROM properties p WHERE p.landlord_id = u.user_id)::int AS property_count,
  (SELECT count(*) FROM rooms r JOIN properties p ON p.property_id = r.property_id WHERE p.landlord_id = u.user_id)::int AS unit_count,
  (SELECT count(*) FROM rooms r JOIN properties p ON p.property_id = r.property_id WHERE p.landlord_id = u.user_id AND r.is_occupied)::int AS occupied_count,
  COALESCE((SELECT sum(r.rent_amount) FROM rooms r JOIN properties p ON p.property_id = r.property_id WHERE p.landlord_id = u.user_id),0)::numeric AS monthly_potential,
  COALESCE((SELECT sum(rp.paid_amount) FROM rent_payments rp WHERE rp.owner_id = u.user_id AND date_trunc('month', rp.paid_on) = date_trunc('month', now())),0)::numeric AS collected_this_month,
  COALESCE((SELECT sum(rp.amount-rp.paid_amount) FROM rent_payments rp WHERE rp.owner_id = u.user_id AND rp.status IN ('due','partial') AND rp.due_date <= CURRENT_DATE),0)::numeric AS outstanding,
  COALESCE((SELECT sum(e.amount) FROM property_expenses e WHERE e.owner_id = u.user_id AND date_trunc('month', e.expense_date) = date_trunc('month', CURRENT_DATE)),0)::numeric AS expenses_this_month,
  (SELECT count(*) FROM maintenance_requests m WHERE m.owner_id = u.user_id AND m.status IN ('open','in_progress'))::int AS open_maintenance
FROM users u WHERE u.user_id = auth.uid();

GRANT SELECT ON public.owner_property_summary, public.owner_unit_details,
  public.owner_rent_ledger, public.owner_dashboard_summary TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.owner_profiles, public.tenancies,
  public.rent_payments, public.property_expenses, public.maintenance_requests TO authenticated;
GRANT EXECUTE ON FUNCTION public.assign_tenant(uuid,uuid,text,text,text,text,date,date,numeric,numeric,integer,text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.vacate_tenant(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.record_rent_payment(uuid,numeric,text,text) TO authenticated;
