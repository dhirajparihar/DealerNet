-- ========================================================================
-- DealerNet Indore Pilot Seed Data
-- ========================================================================

-- 1. CITIES
INSERT INTO public.cities (id, name, state, active)
VALUES
    ('c1111111-1111-1111-1111-111111111111', 'Indore', 'Madhya Pradesh', true),
    ('c2222222-2222-2222-2222-222222222222', 'Bhopal', 'Madhya Pradesh', false),
    ('c3333333-3333-3333-3333-333333333333', 'Ujjain', 'Madhya Pradesh', false)
ON CONFLICT (id) DO NOTHING;

-- 2. MAKES & MODELS
INSERT INTO public.makes (id, name, slug, active)
VALUES
    ('m1111111-1111-1111-1111-111111111111', 'Hyundai', 'hyundai', true),
    ('m2222222-2222-2222-2222-222222222222', 'Mahindra', 'mahindra', true),
    ('m3333333-3333-3333-3333-333333333333', 'Maruti Suzuki', 'maruti-suzuki', true),
    ('m4444444-4444-4444-4444-444444444444', 'Toyota', 'toyota', true),
    ('m5555555-5555-5555-5555-555555555555', 'Tata', 'tata', true),
    ('m6666666-6666-6666-6666-666666666666', 'Kia', 'kia', true),
    ('m7777777-7777-7777-7777-777777777777', 'Honda', 'honda', true)
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.models (id, make_id, name, slug, active)
VALUES
    ('mod-111', 'm1111111-1111-1111-1111-111111111111', 'Creta', 'creta', true),
    ('mod-112', 'm1111111-1111-1111-1111-111111111111', 'Venue', 'venue', true),
    ('mod-211', 'm2222222-2222-2222-2222-222222222222', 'Thar', 'thar', true),
    ('mod-212', 'm2222222-2222-2222-2222-222222222222', 'Scorpio-N', 'scorpio-n', true),
    ('mod-311', 'm3333333-3333-3333-3333-333333333333', 'Swift', 'swift', true),
    ('mod-312', 'm3333333-3333-3333-3333-333333333333', 'Baleno', 'baleno', true),
    ('mod-411', 'm4444444-4444-4444-4444-444444444444', 'Innova Crysta', 'innova-crysta', true),
    ('mod-511', 'm5555555-5555-5555-5555-555555555555', 'Nexon', 'nexon', true),
    ('mod-611', 'm6666666-6666-6666-6666-666666666666', 'Seltos', 'seltos', true),
    ('mod-711', 'm7777777-7777-7777-7777-777777777777', 'City', 'city', true)
ON CONFLICT (id) DO NOTHING;

-- 3. DEALERS IN INDORE
INSERT INTO public.dealers (id, business_name, contact_name, phone, whatsapp_phone, city_id, area, verification_status, is_active)
VALUES
    ('d1111111-1111-1111-1111-111111111111', 'Malwa Premium Cars', 'Rajesh Sharma', '+919826012345', '+919826012345', 'c1111111-1111-1111-1111-111111111111', 'Vijay Nagar', 'verified', true),
    ('d2222222-2222-2222-2222-222222222222', 'Royal Car Bazar', 'Sunil Patidar', '+919826198765', '+919826198765', 'c1111111-1111-1111-1111-111111111111', 'AB Road', 'verified', true),
    ('d3333333-3333-3333-3333-333333333333', 'Shubh Autocars', 'Deepak Jain', '+919826771122', '+919826771122', 'c1111111-1111-1111-1111-111111111111', 'Palasia', 'verified', true),
    ('d4444444-4444-4444-4444-444444444444', 'Speedwell Wheels', 'Mahesh Verma', '+919826884433', '+919826884433', 'c1111111-1111-1111-1111-111111111111', 'Bhanwarkuan', 'mobile_verified', true),
    ('d5555555-5555-5555-5555-555555555555', 'Indore Wheels Hub', 'Anil Solanki', '+919826332211', '+919826332211', 'c1111111-1111-1111-1111-111111111111', 'Rau', 'verified', true)
ON CONFLICT (id) DO NOTHING;

-- 4. VEHICLES
INSERT INTO public.vehicles (
    id, dealer_id, make_id, model_id, make_name, model_name, variant_name, 
    year, km, price_rupees, fuel_type, transmission, city_id, city_name, area, 
    colour, owner_count, registration_state, insurance_status, service_history, 
    accident_condition, notes, status, last_availability_confirmed_at, published_at
)
VALUES
    (
        'v1111111-1111-1111-1111-111111111111', 
        'd1111111-1111-1111-1111-111111111111',
        'm1111111-1111-1111-1111-111111111111',
        'mod-111',
        'Hyundai', 'Creta', 'SX (O) 1.5 Diesel AT',
        2022, 28400, 1680000, 'Diesel', 'Automatic',
        'c1111111-1111-1111-1111-111111111111', 'Indore', 'Vijay Nagar',
        'Polar White', 1, 'MP-09', 'Comprehensive valid till Nov 2026', 'Authorized Hyundai record',
        'Non-accidental, original paint throughout', 'Panoramic sunroof, Bose sound, immediate dealer deal ready.',
        'available', NOW() - INTERVAL '25 minutes', NOW() - INTERVAL '2 days'
    ),
    (
        'v2222222-2222-2222-2222-222222222222', 
        'd2222222-2222-2222-2222-222222222222',
        'm2222222-2222-2222-2222-222222222222',
        'mod-211',
        'Mahindra', 'Thar', 'LX 4WD Hard Top Diesel AT',
        2023, 19500, 1540000, 'Diesel', 'Automatic',
        'c1111111-1111-1111-1111-111111111111', 'Indore', 'AB Road',
        'Napoli Black', 1, 'MP-09', 'Zero Dep active', 'Company maintained, showroom condition',
        '100% bumper-to-bumper original', 'Under warranty, alloy wheels, stepney unused.',
        'available', NOW() - INTERVAL '1 hour', NOW() - INTERVAL '3 days'
    ),
    (
        'v3333333-3333-3333-3333-333333333333', 
        'd3333333-3333-3333-3333-333333333333',
        'm3333333-3333-3333-3333-333333333333',
        'mod-311',
        'Maruti Suzuki', 'Swift', 'ZXi Plus AMT',
        2021, 36000, 725000, 'Petrol', 'Automatic',
        'c1111111-1111-1111-1111-111111111111', 'Indore', 'Palasia',
        'Solid Fire Red', 1, 'MP-09', 'Valid till Jan 2027', 'Full service book stamped by Arena Indore',
        'Clean car, minor bumper touchup', 'Touchscreen navigation, push button start, new Yokohama tyres.',
        'available', NOW() - INTERVAL '3 hours', NOW() - INTERVAL '1 day'
    ),
    (
        'v4444444-4444-4444-4444-444444444444', 
        'd4444444-4444-4444-4444-444444444444',
        'm4444444-4444-4444-4444-444444444444',
        'mod-411',
        'Toyota', 'Innova Crysta', '2.4 ZX 7 STR Diesel',
        2020, 74000, 2190000, 'Diesel', 'Manual',
        'c1111111-1111-1111-1111-111111111111', 'Indore', 'Bhanwarkuan',
        'Silver Metallic', 1, 'MP-09', 'Comprehensive', 'Complete Ananda Toyota records',
        'Certified non-accidental', 'Captain seats, rear AC, leather interior.',
        'available', NOW() - INTERVAL '5 hours', NOW() - INTERVAL '5 days'
    ),
    (
        'v5555555-5555-5555-5555-555555555555', 
        'd1111111-1111-1111-1111-111111111111',
        'm5555555-5555-5555-5555-555555555555',
        'mod-511',
        'Tata', 'Nexon', 'XZ Plus (S) Petrol',
        2022, 31000, 1040000, 'Petrol', 'Manual',
        'c1111111-1111-1111-1111-111111111111', 'Indore', 'Vijay Nagar',
        'Daytona Grey', 1, 'MP-09', 'Valid till Aug 2027', 'Serviced at Sanghi Tata',
        'Non-accidental', 'Sunroof edition, Harman audio, 5-star GNCAP.',
        'reserved', NOW() - INTERVAL '1 day', NOW() - INTERVAL '8 days'
    ),
    (
        'v6666666-6666-6666-6666-666666666666', 
        'd5555555-5555-5555-5555-555555555555',
        'm6666666-6666-6666-6666-666666666666',
        'mod-611',
        'Kia', 'Seltos', 'HTX 1.5 Petrol MT',
        2021, 41000, 1280000, 'Petrol', 'Manual',
        'c1111111-1111-1111-1111-111111111111', 'Indore', 'Rau',
        'Gravity Grey', 1, 'MP-09', 'Comprehensive', 'All services on record',
        'Non-accidental', 'LED sound mood lights, 10.25-inch infotainment, UVO connected car.',
        'available', NOW() - INTERVAL '4 hours', NOW() - INTERVAL '4 days'
    )
ON CONFLICT (id) DO NOTHING;

-- 5. VEHICLE PHOTOS
INSERT INTO public.vehicle_photos (vehicle_id, storage_path, photo_url, sort_order)
VALUES
    ('v1111111-1111-1111-1111-111111111111', 'creta_1.jpg', 'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?auto=format&fit=crop&w=800&q=80', 0),
    ('v1111111-1111-1111-1111-111111111111', 'creta_2.jpg', 'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?auto=format&fit=crop&w=800&q=80', 1),
    ('v2222222-2222-2222-2222-222222222222', 'thar_1.jpg', 'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?auto=format&fit=crop&w=800&q=80', 0),
    ('v3333333-3333-3333-3333-333333333333', 'swift_1.jpg', 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=800&q=80', 0),
    ('v4444444-4444-4444-4444-444444444444', 'innova_1.jpg', 'https://images.unsplash.com/photo-1541899481282-d53bffe3c35d?auto=format&fit=crop&w=800&q=80', 0),
    ('v5555555-5555-5555-5555-555555555555', 'nexon_1.jpg', 'https://images.unsplash.com/photo-1580273916550-e323be2ae537?auto=format&fit=crop&w=800&q=80', 0),
    ('v6666666-6666-6666-6666-666666666666', 'seltos_1.jpg', 'https://images.unsplash.com/photo-1617814076367-b759c7d7e738?auto=format&fit=crop&w=800&q=80', 0)
ON CONFLICT (id) DO NOTHING;

-- 6. WANTED REQUESTS
INSERT INTO public.wanted_requests (
    id, dealer_id, make_name, model_name, year_min, year_max, budget_max, km_max, 
    fuel_type, transmission, city_name, area, notes, matching_count, status
)
VALUES
    (
        'w1111111-1111-1111-1111-111111111111', 
        'd2222222-2222-2222-2222-222222222222',
        'Hyundai', 'Creta', 2021, 2024, 1700000, 40000, 
        'Diesel', 'Automatic', 'Indore', 'AB Road',
        'Urgent demand from a genuine buyer. Ready payment on spot.', 2, 'active'
    ),
    (
        'w2222222-2222-2222-2222-222222222222', 
        'd1111111-1111-1111-1111-111111111111',
        'Maruti Suzuki', 'Swift', 2020, 2023, 750000, 50000, 
        'Petrol', 'Manual', 'Indore', 'Vijay Nagar',
        'Need 1st owner, clean condition, white or silver preferred.', 1, 'active'
    )
ON CONFLICT (id) DO NOTHING;

-- 7. NOTIFICATIONS
INSERT INTO public.notifications (dealer_id, type, title, body, route_url, is_read)
VALUES
    (
        'd1111111-1111-1111-1111-111111111111',
        'wantedMatch',
        'New Vehicle Match for your Wanted Request',
        'Hyundai Creta 2022 Diesel AT added in Vijay Nagar matches your client search.',
        '/vehicle/v1111111-1111-1111-1111-111111111111',
        false
    ),
    (
        'd1111111-1111-1111-1111-111111111111',
        'interestAlert',
        'Dealer Inquiry on Your Stock',
        'Royal Car Bazar called regarding your 2022 Hyundai Creta.',
        '/vehicle/v1111111-1111-1111-1111-111111111111',
        false
    ),
    (
        'd1111111-1111-1111-1111-111111111111',
        'verificationUpdate',
        'Dealer Account Verified',
        'Welcome to DealerNet Indore! Your business profile has been reviewed and approved.',
        '/profile',
        true
    )
ON CONFLICT (id) DO NOTHING;
