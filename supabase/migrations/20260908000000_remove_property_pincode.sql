-- Postal codes are no longer collected or stored for properties.
-- Views using p.* must be recreated because PostgreSQL records their columns.
DROP VIEW IF EXISTS public.property_with_primary_image;
DROP VIEW IF EXISTS public.property_with_images;
DROP VIEW IF EXISTS public.owner_property_summary;

ALTER TABLE public.properties DROP COLUMN IF EXISTS pincode;

CREATE VIEW public.property_with_images WITH (security_invoker = true) AS
SELECT p.*,
  COALESCE((
    SELECT array_agg(image.url ORDER BY i.created_at, image.ordinality)
    FROM public.images i
    CROSS JOIN LATERAL unnest(i.image_url) WITH ORDINALITY AS image(url, ordinality)
    WHERE i.property_id = p.property_id
      AND image.url IS NOT NULL
      AND btrim(image.url) <> ''
  ), ARRAY[]::text[]) AS images
FROM public.properties p;

CREATE VIEW public.property_with_primary_image WITH (security_invoker = true) AS
SELECT p.*, p.images[1] AS primary_image
FROM public.property_with_images p;

CREATE VIEW public.owner_property_summary WITH (security_invoker = true) AS
SELECT p.*, count(r.room_id)::int AS unit_count,
  count(r.room_id) FILTER (WHERE r.is_occupied)::int AS occupied_count,
  COALESCE(sum(r.rent_amount), 0)::numeric AS monthly_potential
FROM public.properties p
LEFT JOIN public.rooms r ON r.property_id = p.property_id
GROUP BY p.property_id;

GRANT SELECT ON public.property_with_images,
  public.property_with_primary_image TO anon, authenticated;
GRANT SELECT ON public.owner_property_summary TO authenticated;
