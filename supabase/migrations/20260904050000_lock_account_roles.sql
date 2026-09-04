-- Account roles are selected during registration and cannot later be used to
-- self-promote. A short window allows a newly-created OAuth profile to persist
-- the role selected immediately before Google registration.
CREATE OR REPLACE FUNCTION public.protect_account_role()
RETURNS trigger LANGUAGE plpgsql SET search_path = public AS $$
BEGIN
  IF NEW.user_type IS DISTINCT FROM OLD.user_type
     AND auth.uid() = OLD.user_id
     AND OLD.created_at < now() - interval '5 minutes' THEN
    RAISE EXCEPTION 'Account role cannot be changed after registration';
  END IF;
  RETURN NEW;
END $$;

DROP TRIGGER IF EXISTS trg_protect_account_role ON public.users;
CREATE TRIGGER trg_protect_account_role
  BEFORE UPDATE OF user_type ON public.users
  FOR EACH ROW EXECUTE FUNCTION public.protect_account_role();
