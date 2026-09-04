-- Remove legacy allow-all policies from personal and financial records.
DROP POLICY IF EXISTS "Users are publicly readable" ON public.users;
DROP POLICY IF EXISTS "Users insert own profile" ON public.users;
DROP POLICY IF EXISTS "Users update own profile" ON public.users;
CREATE POLICY "Users view own profile" ON public.users FOR SELECT TO authenticated
  USING (user_id = auth.uid());
CREATE POLICY "Users insert own non-admin profile" ON public.users FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid() AND user_type <> 'admin');
CREATE POLICY "Users update own non-admin profile" ON public.users FOR UPDATE TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid() AND user_type <> 'admin');

DROP POLICY IF EXISTS "Allow all operations on area" ON public.area;
CREATE POLICY "Areas are publicly readable" ON public.area FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow all operations on bookings" ON public.bookings;
CREATE POLICY "Booking participants can view" ON public.bookings FOR SELECT TO authenticated
  USING (tenant_id = auth.uid() OR landlord_id = auth.uid());
CREATE POLICY "Tenants create valid bookings" ON public.bookings FOR INSERT TO authenticated
  WITH CHECK (
    tenant_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM properties p JOIN rooms r ON r.property_id = p.property_id
      WHERE p.property_id = bookings.property_id
        AND r.room_id = bookings.room_id
        AND p.landlord_id = bookings.landlord_id
    )
  );
CREATE POLICY "Booking participants can update" ON public.bookings FOR UPDATE TO authenticated
  USING (tenant_id = auth.uid() OR landlord_id = auth.uid())
  WITH CHECK (tenant_id = auth.uid() OR landlord_id = auth.uid());
CREATE POLICY "Booking participants can delete" ON public.bookings FOR DELETE TO authenticated
  USING (tenant_id = auth.uid() OR landlord_id = auth.uid());

DROP POLICY IF EXISTS "Allow all operations on payments" ON public.payments;
CREATE POLICY "Payment participants can view" ON public.payments FOR SELECT TO authenticated
  USING (EXISTS (
    SELECT 1 FROM bookings b WHERE b.booking_id = payments.booking_id
      AND (b.tenant_id = auth.uid() OR b.landlord_id = auth.uid())
  ));
CREATE POLICY "Payment participants can insert" ON public.payments FOR INSERT TO authenticated
  WITH CHECK (EXISTS (
    SELECT 1 FROM bookings b WHERE b.booking_id = payments.booking_id
      AND (b.tenant_id = auth.uid() OR b.landlord_id = auth.uid())
  ));
CREATE POLICY "Landlords update booking payments" ON public.payments FOR UPDATE TO authenticated
  USING (EXISTS (
    SELECT 1 FROM bookings b WHERE b.booking_id = payments.booking_id
      AND b.landlord_id = auth.uid()
  ));

DROP POLICY IF EXISTS "Allow all operations on reviews" ON public.reviews;
CREATE POLICY "Reviews are publicly readable" ON public.reviews FOR SELECT USING (true);
CREATE POLICY "Users create own reviews" ON public.reviews FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());
CREATE POLICY "Users update own reviews" ON public.reviews FOR UPDATE TO authenticated
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY "Users delete own reviews" ON public.reviews FOR DELETE TO authenticated
  USING (user_id = auth.uid());

-- The booking view must honor the policies above instead of its creator role.
DROP VIEW IF EXISTS public.booking_details;
CREATE VIEW public.booking_details WITH (security_invoker = true) AS
SELECT b.*, p.title, p.description, p.address, p.property_type,
  p.latitude, p.longitude, p.furnishing_status, p.area_sqft,
  r.room_number, r.rent_amount, r.attributes
FROM bookings b
LEFT JOIN properties p ON b.property_id = p.property_id
LEFT JOIN rooms r ON b.room_id = r.room_id;
GRANT SELECT ON public.booking_details TO authenticated;

-- Reviews expose only the public author fields, never phone/email/documents.
DROP VIEW IF EXISTS public.reviews_user;
CREATE VIEW public.reviews_user AS
SELECT r.*, u.name, u.profile_image
FROM reviews r LEFT JOIN users u ON r.user_id = u.user_id;
GRANT SELECT ON public.reviews_user TO anon, authenticated;
