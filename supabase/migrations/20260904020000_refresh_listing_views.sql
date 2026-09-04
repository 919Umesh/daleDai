-- PostgreSQL expands r.* when a view is created, so refresh listing views
-- after adding management columns. Also aggregate image rows deterministically.
DROP VIEW IF EXISTS public.room_with_images;
CREATE VIEW public.room_with_images WITH (security_invoker = true) AS
SELECT r.*,
  COALESCE((
    SELECT array_agg(image.url ORDER BY ri.created_at, image.ordinality)
    FROM public.room_images ri
    CROSS JOIN LATERAL unnest(ri.image_url) WITH ORDINALITY AS image(url, ordinality)
    WHERE ri.room_id = r.room_id AND image.url IS NOT NULL AND btrim(image.url) <> ''
  ), ARRAY[]::text[]) AS images
FROM public.rooms r;

DROP VIEW IF EXISTS public.property_with_primary_image;
DROP VIEW IF EXISTS public.property_with_images;
CREATE VIEW public.property_with_images WITH (security_invoker = true) AS
SELECT p.*,
  COALESCE((
    SELECT array_agg(image.url ORDER BY i.created_at, image.ordinality)
    FROM public.images i
    CROSS JOIN LATERAL unnest(i.image_url) WITH ORDINALITY AS image(url, ordinality)
    WHERE i.property_id = p.property_id AND image.url IS NOT NULL AND btrim(image.url) <> ''
  ), ARRAY[]::text[]) AS images
FROM public.properties p;

CREATE VIEW public.property_with_primary_image WITH (security_invoker = true) AS
SELECT p.*, p.images[1] AS primary_image FROM public.property_with_images p;

GRANT SELECT ON public.room_with_images, public.property_with_images,
  public.property_with_primary_image TO anon, authenticated;
