-- Link an assigned tenancy to an existing app account by email.
CREATE OR REPLACE FUNCTION public.link_tenancy_user_by_email()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public AS $$
BEGIN
  IF NEW.tenant_user_id IS NULL AND NEW.tenant_email IS NOT NULL THEN
    SELECT u.user_id INTO NEW.tenant_user_id
    FROM public.users u
    WHERE lower(trim(u.email)) = lower(trim(NEW.tenant_email))
    LIMIT 1;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_link_tenancy_user_by_email ON public.tenancies;
CREATE TRIGGER trg_link_tenancy_user_by_email
  BEFORE INSERT OR UPDATE OF tenant_email ON public.tenancies
  FOR EACH ROW EXECUTE FUNCTION public.link_tenancy_user_by_email();

UPDATE public.tenancies t
SET tenant_user_id = u.user_id
FROM public.users u
WHERE t.tenant_user_id IS NULL
  AND t.tenant_email IS NOT NULL
  AND lower(trim(t.tenant_email)) = lower(trim(u.email));

DROP POLICY IF EXISTS "Tenants create their maintenance" ON public.maintenance_requests;
CREATE POLICY "Tenants create their maintenance"
ON public.maintenance_requests FOR INSERT TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1
    FROM public.tenancies t
    WHERE t.tenancy_id = maintenance_requests.tenancy_id
      AND t.tenant_user_id = auth.uid()
      AND t.owner_id = maintenance_requests.owner_id
      AND t.property_id = maintenance_requests.property_id
      AND t.room_id = maintenance_requests.room_id
      AND t.status IN ('active', 'notice')
  )
);
