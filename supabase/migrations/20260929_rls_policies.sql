-- ========================================================================
-- DealerNet Row Level Security (RLS) & Storage Access Policies
-- Specification based on 09_SECURITY_PRIVACY.md and 01_PRD.md
-- ========================================================================

-- Enable RLS on all domain tables
ALTER TABLE public.dealers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.makes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.models ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.variants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vehicles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vehicle_photos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wanted_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.interests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vehicle_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.device_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

-- Helper function: get dealer_id from current auth.uid()
CREATE OR REPLACE FUNCTION public.get_current_dealer_id()
RETURNS UUID AS $$
    SELECT id FROM public.dealers WHERE auth_user_id = auth.uid() LIMIT 1;
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- 1. CITIES, MAKES, MODELS, VARIANTS: Public read for active rows
CREATE POLICY "Public read for active cities" ON public.cities
    FOR SELECT USING (active = true);

CREATE POLICY "Public read for active makes" ON public.makes
    FOR SELECT USING (active = true);

CREATE POLICY "Public read for active models" ON public.models
    FOR SELECT USING (active = true);

CREATE POLICY "Public read for active variants" ON public.variants
    FOR SELECT USING (active = true);

-- 2. DEALERS:
-- Any verified dealer can view other dealers' public profile
CREATE POLICY "Dealers can view active dealers" ON public.dealers
    FOR SELECT USING (is_active = true);

-- Dealers can update only their own profile
CREATE POLICY "Dealers can update own profile" ON public.dealers
    FOR UPDATE USING (auth_user_id = auth.uid());

-- Authenticated users can insert their dealer profile during onboarding
CREATE POLICY "Dealers can insert profile on onboarding" ON public.dealers
    FOR INSERT WITH CHECK (auth_user_id = auth.uid() OR auth_user_id IS NULL);

-- 3. VEHICLES:
-- Network Discovery: Available / reserved cars are visible to authenticated dealers
CREATE POLICY "Dealers can discover available vehicles" ON public.vehicles
    FOR SELECT USING (
        status IN ('available', 'reserved') OR 
        dealer_id = public.get_current_dealer_id()
    );

-- Owners can insert their own vehicles
CREATE POLICY "Dealers can insert own vehicles" ON public.vehicles
    FOR INSERT WITH CHECK (
        dealer_id = public.get_current_dealer_id() OR
        public.get_current_dealer_id() IS NULL
    );

-- Owners can update their own vehicles (status, price, details, freshness)
CREATE POLICY "Dealers can update own vehicles" ON public.vehicles
    FOR UPDATE USING (dealer_id = public.get_current_dealer_id());

-- Owners can delete their own vehicles
CREATE POLICY "Dealers can delete own vehicles" ON public.vehicles
    FOR DELETE USING (dealer_id = public.get_current_dealer_id());

-- 4. VEHICLE PHOTOS:
-- Photos are visible if the vehicle is visible
CREATE POLICY "Photos visible for visible vehicles" ON public.vehicle_photos
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.vehicles v 
            WHERE v.id = vehicle_id AND (v.status IN ('available', 'reserved') OR v.dealer_id = public.get_current_dealer_id())
        )
    );

CREATE POLICY "Dealers can manage own vehicle photos" ON public.vehicle_photos
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.vehicles v 
            WHERE v.id = vehicle_id AND v.dealer_id = public.get_current_dealer_id()
        )
    );

-- 5. WANTED REQUESTS:
-- Active wanted requests visible to all dealers
CREATE POLICY "Dealers can view active wanted requests" ON public.wanted_requests
    FOR SELECT USING (status = 'active' OR dealer_id = public.get_current_dealer_id());

CREATE POLICY "Dealers can create wanted requests" ON public.wanted_requests
    FOR INSERT WITH CHECK (dealer_id = public.get_current_dealer_id());

CREATE POLICY "Dealers can update own wanted requests" ON public.wanted_requests
    FOR UPDATE USING (dealer_id = public.get_current_dealer_id());

-- 6. INTERESTS:
-- Dealers can record interest and view interest in their vehicles
CREATE POLICY "Dealers can view interest received" ON public.interests
    FOR SELECT USING (
        interested_dealer_id = public.get_current_dealer_id() OR
        EXISTS (SELECT 1 FROM public.vehicles v WHERE v.id = vehicle_id AND v.dealer_id = public.get_current_dealer_id())
    );

CREATE POLICY "Dealers can insert interest" ON public.interests
    FOR INSERT WITH CHECK (interested_dealer_id = public.get_current_dealer_id());

-- 7. VEHICLE REPORTS:
-- Any dealer can submit a moderation report
CREATE POLICY "Dealers can create vehicle reports" ON public.vehicle_reports
    FOR INSERT WITH CHECK (reporter_dealer_id = public.get_current_dealer_id());

-- 8. NOTIFICATIONS:
-- Dealers can only read/update their own notifications
CREATE POLICY "Dealers can read own notifications" ON public.notifications
    FOR SELECT USING (dealer_id = public.get_current_dealer_id());

CREATE POLICY "Dealers can update own notifications" ON public.notifications
    FOR UPDATE USING (dealer_id = public.get_current_dealer_id());

-- ========================================================================
-- STORAGE BUCKETS & POLICIES (Supabase Storage)
-- ========================================================================
-- Insert storage buckets if not existing
INSERT INTO storage.buckets (id, name, public)
VALUES 
    ('vehicle-photos', 'vehicle-photos', true),
    ('dealer-logos', 'dealer-logos', true)
ON CONFLICT (id) DO NOTHING;

-- Public read access for vehicle photos bucket
CREATE POLICY "Public vehicle photos view" ON storage.objects
    FOR SELECT USING (bucket_id = 'vehicle-photos');

-- Authenticated upload access for vehicle photos bucket
CREATE POLICY "Authenticated vehicle photo upload" ON storage.objects
    FOR INSERT WITH CHECK (bucket_id = 'vehicle-photos' AND auth.role() = 'authenticated');

-- Owner delete access for vehicle photos
CREATE POLICY "Owner vehicle photo delete" ON storage.objects
    FOR DELETE USING (bucket_id = 'vehicle-photos' AND auth.uid()::text = (storage.foldername(name))[1]);
