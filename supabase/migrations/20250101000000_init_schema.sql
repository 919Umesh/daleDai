-- ====================================================================
-- SUPABASE MIGRATION SCRIPT (IDEMPOTENT)
-- Project: DaleDai / Room Booking App
--
-- This script safely creates and updates all:
-- 1. Extensions
-- 2. Custom Types / Enums
-- 3. Core Tables & Constraints
-- 4. Automatic Timestamp Update Triggers
-- 5. Views
-- 6. Storage Buckets & Policies
-- 7. Row Level Security (RLS) & Table Access Policies
-- ====================================================================

-- --------------------------------------------------------------------
-- 1. EXTENSIONS
-- --------------------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- --------------------------------------------------------------------
-- 2. CUSTOM TYPES / ENUMS (SAFE & IDEMPOTENT CREATION)
-- --------------------------------------------------------------------
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_type') THEN
    CREATE TYPE public.user_type AS ENUM ('tenant', 'landlord', 'admin');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'property_type') THEN
    CREATE TYPE public.property_type AS ENUM (
      'apartment', 'house', 'room', 'flat', 'hostel', 'commercial', 'villa', 'single', 'double', 'rent'
    );
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'furnishing_status') THEN
    CREATE TYPE public.furnishing_status AS ENUM (
      'unfurnished', 'semi-furnished', 'fully-furnished', 'furnished'
    );
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'room_type') THEN
    CREATE TYPE public.room_type AS ENUM (
      'single', 'double', 'shared', 'master', 'deluxe'
    );
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'payment_method') THEN
    CREATE TYPE public.payment_method AS ENUM (
      'cash', 'esewa', 'khalti', 'bank_transfer', 'card'
    );
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'payment_status') THEN
    CREATE TYPE public.payment_status AS ENUM (
      'pending', 'paid', 'failed', 'refunded'
    );
  END IF;
END $$;

-- --------------------------------------------------------------------
-- 3. TABLES (CREATE IF NOT EXISTS & ALTER IF MISSING COLUMNS)
-- --------------------------------------------------------------------

-- A. Users Table
CREATE TABLE IF NOT EXISTS public.users (
  user_id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  email text NOT NULL,
  phone text NULL,
  profile_image text NULL,
  is_verified boolean NOT NULL DEFAULT false,
  document_url text NULL,
  updated_at timestamp with time zone NULL DEFAULT now(),
  created_at timestamp with time zone NULL DEFAULT now(),
  user_type public.user_type NOT NULL DEFAULT 'tenant'::public.user_type,
  CONSTRAINT users_pkey PRIMARY KEY (user_id),
  CONSTRAINT users_email_key UNIQUE (email)
);

-- Ensure all columns exist if table already exists
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS phone text NULL;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS profile_image text NULL;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS is_verified boolean NOT NULL DEFAULT false;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS document_url text NULL;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS updated_at timestamp with time zone NULL DEFAULT now();
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS created_at timestamp with time zone NULL DEFAULT now();
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS user_type public.user_type NOT NULL DEFAULT 'tenant'::public.user_type;


-- B. Area Table
CREATE TABLE IF NOT EXISTS public.area (
  area_id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL DEFAULT 'Basantpur',
  area_image text NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT area_pkey PRIMARY KEY (area_id)
);

ALTER TABLE public.area ADD COLUMN IF NOT EXISTS name text NOT NULL DEFAULT 'Basantpur';
ALTER TABLE public.area ADD COLUMN IF NOT EXISTS area_image text NOT NULL DEFAULT '';
ALTER TABLE public.area ADD COLUMN IF NOT EXISTS created_at timestamp with time zone NOT NULL DEFAULT now();


-- C. Properties Table
CREATE TABLE IF NOT EXISTS public.properties (
  property_id uuid NOT NULL DEFAULT gen_random_uuid(),
  landlord_id uuid NOT NULL,
  title text NOT NULL,
  description text NOT NULL,
  address text NOT NULL,
  city text NOT NULL,
  state text NOT NULL,
  pincode text NOT NULL,
  latitude double precision NOT NULL,
  longitude double precision NOT NULL,
  property_type public.property_type NOT NULL,
  furnishing_status public.furnishing_status NOT NULL DEFAULT 'unfurnished'::public.furnishing_status,
  area_sqft bigint NULL,
  available_from date NULL,
  is_active boolean NULL DEFAULT true,
  updated_at timestamp with time zone NULL DEFAULT now(),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  area_id uuid NOT NULL,
  attributes text[] NULL,
  CONSTRAINT properties_pkey PRIMARY KEY (property_id),
  CONSTRAINT properties_area_id_fkey FOREIGN KEY (area_id) REFERENCES public.area(area_id) ON DELETE RESTRICT,
  CONSTRAINT properties_landlord_id_fkey FOREIGN KEY (landlord_id) REFERENCES public.users(user_id) ON DELETE CASCADE
);

ALTER TABLE public.properties ADD COLUMN IF NOT EXISTS attributes text[] NULL;
ALTER TABLE public.properties ADD COLUMN IF NOT EXISTS area_sqft bigint NULL;
ALTER TABLE public.properties ADD COLUMN IF NOT EXISTS available_from date NULL;
ALTER TABLE public.properties ADD COLUMN IF NOT EXISTS is_active boolean NULL DEFAULT true;
ALTER TABLE public.properties ADD COLUMN IF NOT EXISTS updated_at timestamp with time zone NULL DEFAULT now();
ALTER TABLE public.properties ADD COLUMN IF NOT EXISTS created_at timestamp with time zone NOT NULL DEFAULT now();


-- D. Property Images Table
CREATE TABLE IF NOT EXISTS public.images (
  images_id uuid NOT NULL DEFAULT gen_random_uuid(),
  property_id uuid NOT NULL,
  image_url text[] NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT images_pkey PRIMARY KEY (images_id),
  CONSTRAINT images_property_id_fkey FOREIGN KEY (property_id) REFERENCES public.properties(property_id) ON DELETE CASCADE
);

ALTER TABLE public.images ADD COLUMN IF NOT EXISTS image_url text[] NOT NULL DEFAULT '{}';
ALTER TABLE public.images ADD COLUMN IF NOT EXISTS created_at timestamp with time zone NOT NULL DEFAULT now();


-- E. Rooms Table
CREATE TABLE IF NOT EXISTS public.rooms (
  room_id uuid NOT NULL DEFAULT gen_random_uuid(),
  property_id uuid NOT NULL,
  room_number text NULL,
  rent_amount bigint NOT NULL,
  security_deposit bigint NOT NULL,
  room_type public.room_type NOT NULL DEFAULT 'single'::public.room_type,
  is_occupied boolean NOT NULL DEFAULT false,
  created_at timestamp with time zone NULL DEFAULT now(),
  updated_at timestamp with time zone NULL DEFAULT now(),
  attributes text[] NULL,
  description text NOT NULL DEFAULT 'Description Empty',
  CONSTRAINT rooms_pkey PRIMARY KEY (room_id),
  CONSTRAINT rooms_property_id_fkey FOREIGN KEY (property_id) REFERENCES public.properties(property_id) ON DELETE CASCADE
);

ALTER TABLE public.rooms ADD COLUMN IF NOT EXISTS attributes text[] NULL;
ALTER TABLE public.rooms ADD COLUMN IF NOT EXISTS description text NOT NULL DEFAULT 'Description Empty';
ALTER TABLE public.rooms ADD COLUMN IF NOT EXISTS is_occupied boolean NOT NULL DEFAULT false;
ALTER TABLE public.rooms ADD COLUMN IF NOT EXISTS updated_at timestamp with time zone NULL DEFAULT now();


-- F. Room Images Table
CREATE TABLE IF NOT EXISTS public.room_images (
  room_image_id uuid NOT NULL DEFAULT gen_random_uuid(),
  room_id uuid NOT NULL,
  image_url text[] NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT room_images_pkey PRIMARY KEY (room_image_id),
  CONSTRAINT room_images_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(room_id) ON DELETE CASCADE
);

ALTER TABLE public.room_images ADD COLUMN IF NOT EXISTS image_url text[] NOT NULL DEFAULT '{}';
ALTER TABLE public.room_images ADD COLUMN IF NOT EXISTS created_at timestamp with time zone NOT NULL DEFAULT now();


-- G. Reviews Table
CREATE TABLE IF NOT EXISTS public.reviews (
  review_id uuid NOT NULL DEFAULT gen_random_uuid(),
  property_id uuid NOT NULL,
  user_id uuid NOT NULL,
  rating bigint NOT NULL,
  comment text NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT reviews_pkey PRIMARY KEY (review_id),
  CONSTRAINT reviews_property_id_fkey FOREIGN KEY (property_id) REFERENCES public.properties(property_id) ON DELETE CASCADE,
  CONSTRAINT reviews_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE
);

ALTER TABLE public.reviews ADD COLUMN IF NOT EXISTS comment text NULL;
ALTER TABLE public.reviews ADD COLUMN IF NOT EXISTS created_at timestamp with time zone NOT NULL DEFAULT now();


-- H. Bookings Table
CREATE TABLE IF NOT EXISTS public.bookings (
  booking_id uuid NOT NULL DEFAULT gen_random_uuid(),
  room_id uuid NOT NULL,
  tenant_id uuid NOT NULL,
  landlord_id uuid NOT NULL,
  property_id uuid NULL,
  booking_date date NOT NULL DEFAULT CURRENT_DATE,
  move_in_date date NOT NULL,
  move_out_date date NULL,
  monthly_rent bigint NOT NULL DEFAULT 0,
  security_deposit bigint NOT NULL DEFAULT 0,
  status text NOT NULL DEFAULT 'pending',
  profession text NULL,
  peoples integer NOT NULL DEFAULT 1,
  payment_method text NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT bookings_pkey PRIMARY KEY (booking_id),
  CONSTRAINT bookings_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(room_id) ON DELETE CASCADE,
  CONSTRAINT bookings_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.users(user_id) ON DELETE CASCADE,
  CONSTRAINT bookings_landlord_id_fkey FOREIGN KEY (landlord_id) REFERENCES public.users(user_id) ON DELETE CASCADE,
  CONSTRAINT bookings_property_id_fkey FOREIGN KEY (property_id) REFERENCES public.properties(property_id) ON DELETE SET NULL
);

ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS property_id uuid NULL REFERENCES public.properties(property_id) ON DELETE SET NULL;
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS move_out_date date NULL;
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS profession text NULL;
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS peoples integer NOT NULL DEFAULT 1;
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS payment_method text NULL;
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS updated_at timestamp with time zone NOT NULL DEFAULT now();


-- I. Payments Table
CREATE TABLE IF NOT EXISTS public.payments (
  payment_id uuid NOT NULL DEFAULT gen_random_uuid(),
  booking_id uuid NOT NULL,
  amount bigint NOT NULL,
  payment_type public.property_type NOT NULL,
  payment_method public.payment_method NOT NULL,
  payment_date date NOT NULL DEFAULT CURRENT_DATE,
  due_date date NOT NULL,
  status public.payment_status NOT NULL DEFAULT 'pending'::public.payment_status,
  transaction_id text NULL,
  receipt_url text NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT payments_pkey PRIMARY KEY (payment_id),
  CONSTRAINT payments_booking_id_fkey FOREIGN KEY (booking_id) REFERENCES public.bookings(booking_id) ON DELETE CASCADE
);

ALTER TABLE public.payments ADD COLUMN IF NOT EXISTS transaction_id text NULL;
ALTER TABLE public.payments ADD COLUMN IF NOT EXISTS receipt_url text NULL;
ALTER TABLE public.payments ADD COLUMN IF NOT EXISTS created_at timestamp with time zone NOT NULL DEFAULT now();

-- --------------------------------------------------------------------
-- 4. AUTOMATIC UPDATED_AT TRIGGER FUNCTION
-- --------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_users_updated_at') THEN
    CREATE TRIGGER trg_users_updated_at
      BEFORE UPDATE ON public.users
      FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_properties_updated_at') THEN
    CREATE TRIGGER trg_properties_updated_at
      BEFORE UPDATE ON public.properties
      FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_rooms_updated_at') THEN
    CREATE TRIGGER trg_rooms_updated_at
      BEFORE UPDATE ON public.rooms
      FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_bookings_updated_at') THEN
    CREATE TRIGGER trg_bookings_updated_at
      BEFORE UPDATE ON public.bookings
      FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

-- --------------------------------------------------------------------
-- 5. VIEWS (SAFE REPLACEMENT)
-- --------------------------------------------------------------------

-- View 1: property_with_images
DROP VIEW IF EXISTS public.property_with_images CASCADE;
CREATE OR REPLACE VIEW public.property_with_images AS
SELECT 
    p.*,
    COALESCE(i.image_url, ARRAY[]::text[]) AS images
FROM 
    public.properties p
LEFT JOIN 
    public.images i ON p.property_id = i.property_id;

-- View 2: property_with_primary_image
DROP VIEW IF EXISTS public.property_with_primary_image CASCADE;
CREATE OR REPLACE VIEW public.property_with_primary_image AS
SELECT 
    p.*,
    CASE 
      WHEN array_length(i.image_url, 1) > 0 THEN i.image_url[1]
      ELSE NULL
    END AS primary_image
FROM 
    public.properties p
LEFT JOIN 
    public.images i ON p.property_id = i.property_id;

-- View 3: room_with_images
DROP VIEW IF EXISTS public.room_with_images CASCADE;
CREATE OR REPLACE VIEW public.room_with_images AS
SELECT 
    r.*,
    COALESCE(i.image_url, ARRAY[]::text[]) AS images
FROM 
    public.rooms r
LEFT JOIN 
    public.room_images i ON r.room_id = i.room_id;

-- View 4: reviews_user
DROP VIEW IF EXISTS public.reviews_user CASCADE;
CREATE OR REPLACE VIEW public.reviews_user AS
SELECT 
    r.*,
    u.name,
    u.profile_image
FROM 
    public.reviews r
LEFT JOIN 
    public.users u ON r.user_id = u.user_id;

-- View 5: booking_details
DROP VIEW IF EXISTS public.booking_details CASCADE;
CREATE OR REPLACE VIEW public.booking_details AS
SELECT 
    b.*,
    p.title,
    p.description,
    p.address,
    p.property_type,
    p.latitude,
    p.longitude,
    p.furnishing_status,
    p.area_sqft,
    r.room_number,
    r.rent_amount,
    r.attributes
FROM 
    public.bookings b
LEFT JOIN 
    public.properties p ON b.property_id = p.property_id
LEFT JOIN 
    public.rooms r ON b.room_id = r.room_id;

-- View 6: location_view
DROP VIEW IF EXISTS public.location_view CASCADE;
CREATE OR REPLACE VIEW public.location_view AS  
SELECT 
    l.property_id,
    l.title,
    l.address,
    l.city,
    l.latitude,
    l.longitude,
    l.is_active 
FROM 
    public.properties l;

-- --------------------------------------------------------------------
-- 6. STORAGE BUCKETS (PROFILE, PROPERTIES, ROOMS, AREA, DOCUMENTS)
-- --------------------------------------------------------------------
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES 
  ('profile', 'profile', true, 10485760, ARRAY['image/png', 'image/jpeg', 'image/webp', 'image/gif']),
  ('properties', 'properties', true, 20971520, ARRAY['image/png', 'image/jpeg', 'image/webp', 'image/gif']),
  ('rooms', 'rooms', true, 20971520, ARRAY['image/png', 'image/jpeg', 'image/webp', 'image/gif']),
  ('area', 'area', true, 10485760, ARRAY['image/png', 'image/jpeg', 'image/webp', 'image/gif']),
  ('documents', 'documents', true, 20971520, NULL)
ON CONFLICT (id) DO UPDATE 
SET 
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

-- Storage RLS & Policies
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  -- Select Policy
  DROP POLICY IF EXISTS "Allow Public Storage Select" ON storage.objects;
  CREATE POLICY "Allow Public Storage Select" 
    ON storage.objects FOR SELECT 
    USING (true);

  -- Insert Policy
  DROP POLICY IF EXISTS "Allow Public Storage Insert" ON storage.objects;
  CREATE POLICY "Allow Public Storage Insert" 
    ON storage.objects FOR INSERT 
    WITH CHECK (true);

  -- Update Policy
  DROP POLICY IF EXISTS "Allow Public Storage Update" ON storage.objects;
  CREATE POLICY "Allow Public Storage Update" 
    ON storage.objects FOR UPDATE 
    USING (true);

  -- Delete Policy
  DROP POLICY IF EXISTS "Allow Public Storage Delete" ON storage.objects;
  CREATE POLICY "Allow Public Storage Delete" 
    ON storage.objects FOR DELETE 
    USING (true);
END $$;

-- --------------------------------------------------------------------
-- 7. ROW LEVEL SECURITY (RLS) & TABLE ACCESS POLICIES
-- --------------------------------------------------------------------
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.area ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.properties ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.images ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.room_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  -- Users policies
  DROP POLICY IF EXISTS "Allow all operations on users" ON public.users;
  CREATE POLICY "Allow all operations on users" ON public.users FOR ALL USING (true) WITH CHECK (true);

  -- Area policies
  DROP POLICY IF EXISTS "Allow all operations on area" ON public.area;
  CREATE POLICY "Allow all operations on area" ON public.area FOR ALL USING (true) WITH CHECK (true);

  -- Properties policies
  DROP POLICY IF EXISTS "Allow all operations on properties" ON public.properties;
  CREATE POLICY "Allow all operations on properties" ON public.properties FOR ALL USING (true) WITH CHECK (true);

  -- Images policies
  DROP POLICY IF EXISTS "Allow all operations on images" ON public.images;
  CREATE POLICY "Allow all operations on images" ON public.images FOR ALL USING (true) WITH CHECK (true);

  -- Rooms policies
  DROP POLICY IF EXISTS "Allow all operations on rooms" ON public.rooms;
  CREATE POLICY "Allow all operations on rooms" ON public.rooms FOR ALL USING (true) WITH CHECK (true);

  -- Room Images policies
  DROP POLICY IF EXISTS "Allow all operations on room_images" ON public.room_images;
  CREATE POLICY "Allow all operations on room_images" ON public.room_images FOR ALL USING (true) WITH CHECK (true);

  -- Reviews policies
  DROP POLICY IF EXISTS "Allow all operations on reviews" ON public.reviews;
  CREATE POLICY "Allow all operations on reviews" ON public.reviews FOR ALL USING (true) WITH CHECK (true);

  -- Bookings policies
  DROP POLICY IF EXISTS "Allow all operations on bookings" ON public.bookings;
  CREATE POLICY "Allow all operations on bookings" ON public.bookings FOR ALL USING (true) WITH CHECK (true);

  -- Payments policies
  DROP POLICY IF EXISTS "Allow all operations on payments" ON public.payments;
  CREATE POLICY "Allow all operations on payments" ON public.payments FOR ALL USING (true) WITH CHECK (true);
END $$;

-- --------------------------------------------------------------------
-- 8. GRANT API ACCESS TO ROLES
-- --------------------------------------------------------------------
GRANT USAGE ON SCHEMA public TO anon, authenticated, service_role;
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated, service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated, service_role;
GRANT ALL ON ALL ROUTINES IN SCHEMA public TO anon, authenticated, service_role;

ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON ROUTINES TO anon, authenticated, service_role;

-- ====================================================================
-- END OF MIGRATION
-- ====================================================================
