-- ============================================================
-- daleDai Seed Data  (run after schema.sql)
-- Safe to re-run: uses ON CONFLICT DO NOTHING
-- ============================================================

-- 1. USERS
INSERT INTO public.users (user_id, name, email, phone, profile_image, user_type, is_verified) VALUES
  ('11111111-1111-1111-1111-111111111111', 'Umesh Shahi',   'umesh@daledai.com',   '9841000001', 'https://i.pravatar.cc/150?img=11', 'landlord', true),
  ('22222222-2222-2222-2222-222222222222', 'Sita Poudel',   'sita@daledai.com',    '9841000002', 'https://i.pravatar.cc/150?img=5',  'tenant',   true),
  ('33333333-3333-3333-3333-333333333333', 'Hari Bahadur',  'hari@daledai.com',    '9841000003', 'https://i.pravatar.cc/150?img=15', 'landlord', true),
  ('44444444-4444-4444-4444-444444444444', 'Mina Thapa',    'mina@daledai.com',    '9841000004', 'https://i.pravatar.cc/150?img=20', 'tenant',   false)
ON CONFLICT (user_id) DO NOTHING;

-- 2. AREAS
INSERT INTO public.area (area_id, name, area_image) VALUES
  ('aaaaaaaa-0001-0001-0001-aaaaaaaaaaaa', 'Thamel',    'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400'),
  ('aaaaaaaa-0002-0002-0002-aaaaaaaaaaaa', 'Baneshwor', 'https://images.unsplash.com/photo-1477959858617-67f85cf4f1df?w=400'),
  ('aaaaaaaa-0003-0003-0003-aaaaaaaaaaaa', 'Lalitpur',  'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=400'),
  ('aaaaaaaa-0004-0004-0004-aaaaaaaaaaaa', 'Bhaktapur', 'https://images.unsplash.com/photo-1599946347371-68eb71b16afc?w=400'),
  ('aaaaaaaa-0005-0005-0005-aaaaaaaaaaaa', 'Boudha',    'https://images.unsplash.com/photo-1603380353725-f8a4d39cc41e?w=400')
ON CONFLICT (area_id) DO NOTHING;

-- 3. PROPERTIES
INSERT INTO public.properties (
  property_id, landlord_id, area_id, title, description,
  address, city, state, pincode, latitude, longitude,
  property_type, furnishing_status, area_sqft, attributes, is_active
) VALUES
  -- Thamel
  ('bbbbbbbb-0001-0001-0001-bbbbbbbbbbbb','11111111-1111-1111-1111-111111111111','aaaaaaaa-0001-0001-0001-aaaaaaaaaaaa','Thamel Garden Residency','Cozy rooms in the heart of Thamel, minutes from top restaurants. 24-hour security and rooftop access.','Jyatha Tole, Thamel','Kathmandu','Bagmati','44600',27.7152,85.3123,'apartment','furnished',1200,ARRAY['WiFi','Parking','Hot Water','CCTV','Rooftop'],true),
  ('bbbbbbbb-0002-0002-0002-bbbbbbbbbbbb','11111111-1111-1111-1111-111111111111','aaaaaaaa-0001-0001-0001-aaaaaaaaaaaa','Thamel Heritage House','Traditional Newari architecture converted into comfortable living spaces.','Chhetrapati, Thamel','Kathmandu','Bagmati','44600',27.7135,85.3089,'house','semi-furnished',1800,ARRAY['WiFi','Garden','Hot Water','Common Kitchen'],true),
  ('bbbbbbbb-0003-0003-0003-bbbbbbbbbbbb','33333333-3333-3333-3333-333333333333','aaaaaaaa-0001-0001-0001-aaaaaaaaaaaa','Thamel Studio Flats','Modern studio apartments perfect for solo travellers or students. High-speed internet.','Paknajol, Thamel','Kathmandu','Bagmati','44600',27.7170,85.3110,'apartment','fully-furnished',800,ARRAY['WiFi','Elevator','Gym','Laundry'],true),

  -- Baneshwor
  ('bbbbbbbb-0004-0004-0004-bbbbbbbbbbbb','11111111-1111-1111-1111-111111111111','aaaaaaaa-0002-0002-0002-aaaaaaaaaaaa','Baneshwor Business Suites','Executive-style rooms ideal for professionals near Supreme Court and corporate offices.','New Baneshwor Road','Kathmandu','Bagmati','44600',27.6915,85.3331,'apartment','furnished',2000,ARRAY['WiFi','Parking','CCTV','24hr Security','Generator'],true),
  ('bbbbbbbb-0005-0005-0005-bbbbbbbbbbbb','33333333-3333-3333-3333-333333333333','aaaaaaaa-0002-0002-0002-aaaaaaaaaaaa','Baneshwor Family Homes','Spacious family-friendly units with separate dining and living areas.','Old Baneshwor','Kathmandu','Bagmati','44600',27.6980,85.3380,'house','semi-furnished',2500,ARRAY['Parking','Garden','Hot Water','Quiet Area'],true),
  ('bbbbbbbb-0006-0006-0006-bbbbbbbbbbbb','11111111-1111-1111-1111-111111111111','aaaaaaaa-0002-0002-0002-aaaaaaaaaaaa','Baneshwor Metro Living','Walking distance to metro bus stops. Newly renovated rooms with modern amenities.','Tinkune, Baneshwor','Kathmandu','Bagmati','44600',27.6850,85.3450,'apartment','furnished',1100,ARRAY['WiFi','CCTV','Hot Water','Balcony'],true),

  -- Lalitpur
  ('bbbbbbbb-0007-0007-0007-bbbbbbbbbbbb','33333333-3333-3333-3333-333333333333','aaaaaaaa-0003-0003-0003-aaaaaaaaaaaa','Patan Durbar Residency','Stunning views of Patan Durbar Square. Heritage building with all modern comforts.','Mangal Bazar, Lalitpur','Lalitpur','Bagmati','44700',27.6727,85.3256,'apartment','furnished',1400,ARRAY['WiFi','Hot Water','Heritage View','Rooftop','Security'],true),
  ('bbbbbbbb-0008-0008-0008-bbbbbbbbbbbb','11111111-1111-1111-1111-111111111111','aaaaaaaa-0003-0003-0003-aaaaaaaaaaaa','Kupondol Quiet Nest','Peaceful residential area. Ideal for families. Close to international schools.','Kupondol Height, Lalitpur','Lalitpur','Bagmati','44700',27.6820,85.3180,'house','semi-furnished',3000,ARRAY['Parking','Garden','Hot Water','Quiet Area','Backup Power'],true),
  ('bbbbbbbb-0009-0009-0009-bbbbbbbbbbbb','33333333-3333-3333-3333-333333333333','aaaaaaaa-0003-0003-0003-aaaaaaaaaaaa','Jawalakhel Modern Flats','Brand-new construction with high-end finishes. South-facing units with mountain views.','Jawalakhel Chowk, Lalitpur','Lalitpur','Bagmati','44700',27.6740,85.3160,'apartment','fully-furnished',1600,ARRAY['WiFi','Elevator','Gym','Parking','Balcony','CCTV'],true),

  -- Bhaktapur
  ('bbbbbbbb-0010-0010-0010-bbbbbbbbbbbb','11111111-1111-1111-1111-111111111111','aaaaaaaa-0004-0004-0004-aaaaaaaaaaaa','Bhaktapur Old Town Stays','Authentic Newari courtyard living. Walk to Bhaktapur Durbar Square in 5 minutes.','Taumadhi Tole, Bhaktapur','Bhaktapur','Bagmati','44800',27.6710,85.4280,'house','furnished',1000,ARRAY['Courtyard','Hot Water','WiFi','Rooftop View'],true),
  ('bbbbbbbb-0011-0011-0011-bbbbbbbbbbbb','33333333-3333-3333-3333-333333333333','aaaaaaaa-0004-0004-0004-aaaaaaaaaaaa','Bhaktapur Suryamadhi Rooms','Clean and affordable rooms near major schools and the industrial district.','Suryamadhi, Bhaktapur','Bhaktapur','Bagmati','44800',27.6750,85.4350,'apartment','unfurnished',900,ARRAY['Hot Water','Parking','Quiet Lane'],true),
  ('bbbbbbbb-0012-0012-0012-bbbbbbbbbbbb','11111111-1111-1111-1111-111111111111','aaaaaaaa-0004-0004-0004-aaaaaaaaaaaa','Bhaktapur Pottery Square Loft','Artsy loft-style apartments above the famous pottery square.','Pottery Square, Bhaktapur','Bhaktapur','Bagmati','44800',27.6690,85.4250,'apartment','semi-furnished',1300,ARRAY['WiFi','Cultural View','Hot Water','Balcony'],true),

  -- Boudha
  ('bbbbbbbb-0013-0013-0013-bbbbbbbbbbbb','33333333-3333-3333-3333-333333333333','aaaaaaaa-0005-0005-0005-aaaaaaaaaaaa','Boudha Stupa View Apartments','Rare stupa-facing rooms with spiritual ambience. Ideal for long-term stays.','Boudha Sadak, Boudha','Kathmandu','Bagmati','44600',27.7215,85.3620,'apartment','furnished',1200,ARRAY['WiFi','Stupa View','Meditation Room','Hot Water','Rooftop'],true),
  ('bbbbbbbb-0014-0014-0014-bbbbbbbbbbbb','11111111-1111-1111-1111-111111111111','aaaaaaaa-0005-0005-0005-aaaaaaaaaaaa','Boudha Tibetan Colony Rooms','Immersive Tibetan-style rooms within walking distance of monasteries.','Nayabazar, Boudha','Kathmandu','Bagmati','44600',27.7240,85.3650,'house','semi-furnished',2200,ARRAY['WiFi','Hot Water','Garden','Monastery View'],true),
  ('bbbbbbbb-0015-0015-0015-bbbbbbbbbbbb','33333333-3333-3333-3333-333333333333','aaaaaaaa-0005-0005-0005-aaaaaaaaaaaa','Boudha Corporate Suites','Contemporary executive suites with co-working spaces and meeting rooms.','Boudha Ring Road','Kathmandu','Bagmati','44600',27.7260,85.3580,'apartment','fully-furnished',1800,ARRAY['WiFi','Co-working','CCTV','Parking','24hr Security','Gym'],true)
ON CONFLICT (property_id) DO NOTHING;

-- 4. IMAGES (2 images per property)
INSERT INTO public.images (images_id, property_id, image_url) VALUES
  (gen_random_uuid(),'bbbbbbbb-0001-0001-0001-bbbbbbbbbbbb',ARRAY['https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800','https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800']),
  (gen_random_uuid(),'bbbbbbbb-0002-0002-0002-bbbbbbbbbbbb',ARRAY['https://images.unsplash.com/photo-1568605114967-8130f3a36994?w=800','https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=800']),
  (gen_random_uuid(),'bbbbbbbb-0003-0003-0003-bbbbbbbbbbbb',ARRAY['https://images.unsplash.com/photo-1501183638710-841dd1904471?w=800','https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=800']),
  (gen_random_uuid(),'bbbbbbbb-0004-0004-0004-bbbbbbbbbbbb',ARRAY['https://images.unsplash.com/photo-1497366216548-37526070297c?w=800','https://images.unsplash.com/photo-1497366754035-f200968a6e72?w=800']),
  (gen_random_uuid(),'bbbbbbbb-0005-0005-0005-bbbbbbbbbbbb',ARRAY['https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800','https://images.unsplash.com/photo-1600585154526-990dced4db0d?w=800']),
  (gen_random_uuid(),'bbbbbbbb-0006-0006-0006-bbbbbbbbbbbb',ARRAY['https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=800','https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800']),
  (gen_random_uuid(),'bbbbbbbb-0007-0007-0007-bbbbbbbbbbbb',ARRAY['https://images.unsplash.com/photo-1600047509807-ba8f99d2cdde?w=800','https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800']),
  (gen_random_uuid(),'bbbbbbbb-0008-0008-0008-bbbbbbbbbbbb',ARRAY['https://images.unsplash.com/photo-1580587771525-78b9dba3b914?w=800','https://images.unsplash.com/photo-1523217582562-09d0def993a6?w=800']),
  (gen_random_uuid(),'bbbbbbbb-0009-0009-0009-bbbbbbbbbbbb',ARRAY['https://images.unsplash.com/photo-1613977257363-707ba9348227?w=800','https://images.unsplash.com/photo-1613977257592-4871e5fcd7c4?w=800']),
  (gen_random_uuid(),'bbbbbbbb-0010-0010-0010-bbbbbbbbbbbb',ARRAY['https://images.unsplash.com/photo-1605276374104-dee2a0ed3cd6?w=800','https://images.unsplash.com/photo-1560185007-cde436f6a4d0?w=800']),
  (gen_random_uuid(),'bbbbbbbb-0011-0011-0011-bbbbbbbbbbbb',ARRAY['https://images.unsplash.com/photo-1502005097973-6a7082348e28?w=800','https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800']),
  (gen_random_uuid(),'bbbbbbbb-0012-0012-0012-bbbbbbbbbbbb',ARRAY['https://images.unsplash.com/photo-1560448204-603b3fc33ddc?w=800','https://images.unsplash.com/photo-1556912172-45b7abe8b7e1?w=800']),
  (gen_random_uuid(),'bbbbbbbb-0013-0013-0013-bbbbbbbbbbbb',ARRAY['https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800','https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=800']),
  (gen_random_uuid(),'bbbbbbbb-0014-0014-0014-bbbbbbbbbbbb',ARRAY['https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800','https://images.unsplash.com/photo-1600566753190-17f0baa2a6c3?w=800']),
  (gen_random_uuid(),'bbbbbbbb-0015-0015-0015-bbbbbbbbbbbb',ARRAY['https://images.unsplash.com/photo-1540518614846-7eded433c457?w=800','https://images.unsplash.com/photo-1554995207-c18c203602cb?w=800'])
ON CONFLICT DO NOTHING;

-- 5. ROOMS
INSERT INTO public.rooms (
  room_id, property_id, room_number, room_type, rent_amount,
  security_deposit, description, is_occupied, attributes, max_occupants,
  floor_number, area_sqft, furnishing_status, bathroom_type,
  has_attached_bathroom, minimum_stay_months, utilities_included, house_rules,
  preferred_tenant
) VALUES
  ('cccccccc-0001-0001-0001-cccccccccccc','bbbbbbbb-0001-0001-0001-bbbbbbbbbbbb','101','single',12000,24000,'Bright single room with city view',false,ARRAY['WiFi','Hot Water','Wardrobe'],1,1,180,'furnished','shared',false,3,ARRAY['Water','WiFi'],ARRAY['No smoking','Quiet hours after 10 PM'],'Student or professional'),
  ('cccccccc-0002-0002-0002-cccccccccccc','bbbbbbbb-0001-0001-0001-bbbbbbbbbbbb','201','double',18000,36000,'Spacious double room with attached bath',false,ARRAY['WiFi','Hot Water','Wardrobe','AC'],2,2,280,'fully furnished','western',true,3,ARRAY['Water','WiFi'],ARRAY['No smoking','No pets'],'Working professionals'),
  ('cccccccc-0003-0003-0003-cccccccccccc','bbbbbbbb-0001-0001-0001-bbbbbbbbbbbb','301','deluxe',28000,56000,'Top-floor suite with rooftop access',true,ARRAY['WiFi','Hot Water','Wardrobe','AC','Mini Kitchen'],2,3,420,'fully furnished','western',true,6,ARRAY['Water','WiFi','Electricity'],ARRAY['No smoking'],'Professionals or couples'),
  ('cccccccc-0004-0004-0004-cccccccccccc','bbbbbbbb-0002-0002-0002-bbbbbbbbbbbb','A1','single',10000,20000,'Traditional single room, wooden decor',false,ARRAY['Hot Water','Courtyard View'],1,1,160,'semi-furnished','shared',false,3,ARRAY['Water'],ARRAY['Respect heritage property'],'Student'),
  ('cccccccc-0005-0005-0005-cccccccccccc','bbbbbbbb-0002-0002-0002-bbbbbbbbbbbb','A2','double',16000,32000,'Heritage double with courtyard view',true,ARRAY['Hot Water','Courtyard View','WiFi'],2,2,260,'furnished','shared',false,3,ARRAY['Water','WiFi'],ARRAY['No loud music'],'Professionals'),
  ('cccccccc-0006-0006-0006-cccccccccccc','bbbbbbbb-0003-0003-0003-bbbbbbbbbbbb','S01','single',22000,44000,'Self-contained studio, fully furnished',false,ARRAY['WiFi','Kitchen','AC','Hot Water'],2,4,380,'fully furnished','western',true,6,ARRAY['Water','WiFi'],ARRAY['No smoking','No parties'],'Working professionals'),
  ('cccccccc-0007-0007-0007-cccccccccccc','bbbbbbbb-0007-0007-0007-bbbbbbbbbbbb','201','double',20000,40000,'Durbar-view double room',false,ARRAY['WiFi','Hot Water','Heritage View','AC'],2,2,300,'furnished','western',true,3,ARRAY['Water','WiFi'],ARRAY['Quiet hours after 10 PM'],'Professionals or couples'),
  ('cccccccc-0008-0008-0008-cccccccccccc','bbbbbbbb-0013-0013-0013-bbbbbbbbbbbb','S01','single',12000,24000,'Stupa-view single with meditation corner',false,ARRAY['WiFi','Stupa View','Hot Water','Meditation Room'],1,3,190,'furnished','shared',false,3,ARRAY['Water','WiFi'],ARRAY['No smoking','Maintain quiet atmosphere'],'Student or professional')
ON CONFLICT DO NOTHING;

-- Every room can have any number of images. Additional rows are also allowed;
-- room_with_images flattens all arrays into one ordered gallery.
INSERT INTO public.room_images (room_image_id, room_id, image_url) VALUES
  ('dddddddd-0001-0001-0001-dddddddddddd','cccccccc-0001-0001-0001-cccccccccccc',ARRAY['https://images.unsplash.com/photo-1522708323590-d24dbb6b0267d?w=1200','https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=1200','https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=1200']),
  ('dddddddd-0002-0002-0002-dddddddddddd','cccccccc-0002-0002-0002-cccccccccccc',ARRAY['https://images.unsplash.com/photo-1616594039964-ae9021a400a0?w=1200','https://images.unsplash.com/photo-1540518614846-7eded433c457?w=1200']),
  ('dddddddd-0003-0003-0003-dddddddddddd','cccccccc-0003-0003-0003-cccccccccccc',ARRAY['https://images.unsplash.com/photo-1595526114035-0d45ed16cfbf?w=1200','https://images.unsplash.com/photo-1560185008-b033106af5c3?w=1200']),
  ('dddddddd-0004-0004-0004-dddddddddddd','cccccccc-0004-0004-0004-cccccccccccc',ARRAY['https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=1200','https://images.unsplash.com/photo-1566665797739-1674de7a421a?w=1200']),
  ('dddddddd-0005-0005-0005-dddddddddddd','cccccccc-0005-0005-0005-cccccccccccc',ARRAY['https://images.unsplash.com/photo-1615874959474-d609969a20ed?w=1200','https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?w=1200']),
  ('dddddddd-0006-0006-0006-dddddddddddd','cccccccc-0006-0006-0006-cccccccccccc',ARRAY['https://images.unsplash.com/photo-1536376072261-38c75010e6c9?w=1200','https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?w=1200']),
  ('dddddddd-0007-0007-0007-dddddddddddd','cccccccc-0007-0007-0007-cccccccccccc',ARRAY['https://images.unsplash.com/photo-1560185127-6ed189bf02f4?w=1200','https://images.unsplash.com/photo-1560448075-bb485b067938?w=1200']),
  ('dddddddd-0008-0008-0008-dddddddddddd','cccccccc-0008-0008-0008-cccccccccccc',ARRAY['https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=1200','https://images.unsplash.com/photo-1598928506311-c55ded91a20c?w=1200'])
ON CONFLICT DO NOTHING;

-- 6. REVIEWS
INSERT INTO public.reviews (review_id, property_id, user_id, rating, comment) VALUES
  (gen_random_uuid(),'bbbbbbbb-0001-0001-0001-bbbbbbbbbbbb','22222222-2222-2222-2222-222222222222',5,'Amazing location in Thamel! The room was clean and the rooftop view is spectacular. Highly recommend.'),
  (gen_random_uuid(),'bbbbbbbb-0001-0001-0001-bbbbbbbbbbbb','44444444-4444-4444-4444-444444444444',4,'Great place, very responsive landlord. Hot water was consistent. Will book again.'),
  (gen_random_uuid(),'bbbbbbbb-0007-0007-0007-bbbbbbbbbbbb','44444444-4444-4444-4444-444444444444',5,'Woke up every morning to the Patan Durbar view. A truly magical experience.')
ON CONFLICT DO NOTHING;
