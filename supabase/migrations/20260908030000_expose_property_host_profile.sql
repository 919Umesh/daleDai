-- Return only safe host fields to signed-in users viewing a property.
CREATE OR REPLACE FUNCTION public.get_property_host_profile(p_property_id uuid)
RETURNS TABLE(host_name text, host_profile_image text)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public AS $$
BEGIN
  IF auth.uid() IS NULL THEN
    RETURN;
  END IF;

  RETURN QUERY
  SELECT u.name, u.profile_image
  FROM public.properties p
  JOIN public.users u ON u.user_id = p.landlord_id
  WHERE p.property_id = p_property_id
    AND u.user_type IN ('landlord', 'admin')
  LIMIT 1;
END;
$$;

REVOKE ALL ON FUNCTION public.get_property_host_profile(uuid) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.get_property_host_profile(uuid) FROM anon;
GRANT EXECUTE ON FUNCTION public.get_property_host_profile(uuid)
  TO authenticated;
