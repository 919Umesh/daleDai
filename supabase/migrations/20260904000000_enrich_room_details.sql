-- Add optional, display-focused room details without invalidating existing rows.
ALTER TABLE public.rooms
  ADD COLUMN IF NOT EXISTS max_occupants integer NOT NULL DEFAULT 1,
  ADD COLUMN IF NOT EXISTS floor_number integer NULL,
  ADD COLUMN IF NOT EXISTS area_sqft integer NULL,
  ADD COLUMN IF NOT EXISTS furnishing_status text NULL,
  ADD COLUMN IF NOT EXISTS bathroom_type text NULL,
  ADD COLUMN IF NOT EXISTS has_attached_bathroom boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS available_from date NULL,
  ADD COLUMN IF NOT EXISTS minimum_stay_months integer NOT NULL DEFAULT 1,
  ADD COLUMN IF NOT EXISTS utilities_included text[] NOT NULL DEFAULT '{}',
  ADD COLUMN IF NOT EXISTS house_rules text[] NOT NULL DEFAULT '{}',
  ADD COLUMN IF NOT EXISTS preferred_tenant text NULL;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'rooms_max_occupants_check'
  ) THEN
    ALTER TABLE public.rooms
      ADD CONSTRAINT rooms_max_occupants_check CHECK (max_occupants > 0);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'rooms_area_sqft_check'
  ) THEN
    ALTER TABLE public.rooms
      ADD CONSTRAINT rooms_area_sqft_check CHECK (area_sqft IS NULL OR area_sqft > 0);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'rooms_minimum_stay_check'
  ) THEN
    ALTER TABLE public.rooms
      ADD CONSTRAINT rooms_minimum_stay_check CHECK (minimum_stay_months > 0);
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS room_images_room_id_idx
  ON public.room_images(room_id);

-- One room row is returned even when images were uploaded in several records.
-- Existing text[] image data is preserved and flattened into an ordered gallery.
DROP VIEW IF EXISTS public.room_with_images;
CREATE VIEW public.room_with_images
WITH (security_invoker = true) AS
SELECT
  r.*,
  COALESCE(
    (
      SELECT array_agg(image.url ORDER BY ri.created_at, image.ordinality)
      FROM public.room_images ri
      CROSS JOIN LATERAL unnest(ri.image_url)
        WITH ORDINALITY AS image(url, ordinality)
      WHERE ri.room_id = r.room_id
        AND image.url IS NOT NULL
        AND btrim(image.url) <> ''
    ),
    ARRAY[]::text[]
  ) AS images
FROM public.rooms r;

GRANT SELECT ON public.room_with_images TO anon, authenticated;
