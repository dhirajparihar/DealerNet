-- ========================================================================
-- DealerNet B2B Used Vehicle Network — PostgreSQL / Supabase Schema
-- Specification based on 05_DATA_MODEL.md and 07_FLUTTER_ARCHITECTURE.md
-- ========================================================================

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Auto-update updated_at function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 1. CITIES
CREATE TABLE IF NOT EXISTS public.cities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    state TEXT NOT NULL DEFAULT 'Madhya Pradesh',
    active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. DEALERS
CREATE TABLE IF NOT EXISTS public.dealers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    auth_user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    business_name TEXT NOT NULL,
    contact_name TEXT NOT NULL,
    phone TEXT NOT NULL UNIQUE,
    whatsapp_phone TEXT,
    city_id UUID REFERENCES public.cities(id) ON DELETE RESTRICT,
    area TEXT NOT NULL,
    logo_url TEXT,
    verification_status TEXT NOT NULL DEFAULT 'mobile_verified'
        CHECK (verification_status IN ('mobile_verified', 'pending', 'verified', 'rejected', 'suspended')),
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER set_dealers_updated_at
    BEFORE UPDATE ON public.dealers
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- 3. MAKES
CREATE TABLE IF NOT EXISTS public.makes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    slug TEXT NOT NULL UNIQUE,
    active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 4. MODELS
CREATE TABLE IF NOT EXISTS public.models (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    make_id UUID NOT NULL REFERENCES public.makes(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    slug TEXT NOT NULL,
    active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(make_id, name)
);

-- 5. VARIANTS
CREATE TABLE IF NOT EXISTS public.variants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    model_id UUID NOT NULL REFERENCES public.models(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    slug TEXT NOT NULL,
    active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 6. VEHICLES
CREATE TABLE IF NOT EXISTS public.vehicles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    dealer_id UUID NOT NULL REFERENCES public.dealers(id) ON DELETE CASCADE,
    make_id UUID REFERENCES public.makes(id) ON DELETE RESTRICT,
    model_id UUID REFERENCES public.models(id) ON DELETE RESTRICT,
    variant_id UUID REFERENCES public.variants(id) ON DELETE SET NULL,
    make_name TEXT NOT NULL,
    model_name TEXT NOT NULL,
    variant_name TEXT,
    year SMALLINT NOT NULL CHECK (year >= 2000 AND year <= 2030),
    km INTEGER NOT NULL CHECK (km >= 0),
    price_rupees BIGINT NOT NULL CHECK (price_rupees >= 0),
    fuel_type TEXT NOT NULL CHECK (fuel_type IN ('Petrol', 'Diesel', 'CNG', 'Electric', 'Hybrid')),
    transmission TEXT NOT NULL CHECK (transmission IN ('Manual', 'Automatic')),
    city_id UUID REFERENCES public.cities(id) ON DELETE RESTRICT,
    city_name TEXT NOT NULL DEFAULT 'Indore',
    area TEXT NOT NULL,
    colour TEXT NOT NULL DEFAULT '',
    owner_count SMALLINT NOT NULL DEFAULT 1 CHECK (owner_count >= 1 AND owner_count <= 10),
    registration_state TEXT DEFAULT 'MP-09',
    insurance_status TEXT DEFAULT 'Active',
    service_history TEXT DEFAULT 'Available',
    accident_condition TEXT DEFAULT 'Non-Accidental',
    notes TEXT,
    status TEXT NOT NULL DEFAULT 'available'
        CHECK (status IN ('draft', 'available', 'reserved', 'sold', 'expired')),
    last_availability_confirmed_at TIMESTAMPTZ DEFAULT NOW(),
    published_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER set_vehicles_updated_at
    BEFORE UPDATE ON public.vehicles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- 7. VEHICLE PHOTOS
CREATE TABLE IF NOT EXISTS public.vehicle_photos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vehicle_id UUID NOT NULL REFERENCES public.vehicles(id) ON DELETE CASCADE,
    storage_path TEXT NOT NULL,
    photo_url TEXT NOT NULL,
    sort_order INT NOT NULL DEFAULT 0,
    width INT,
    height INT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 8. WANTED REQUESTS
CREATE TABLE IF NOT EXISTS public.wanted_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    dealer_id UUID NOT NULL REFERENCES public.dealers(id) ON DELETE CASCADE,
    make_name TEXT NOT NULL,
    model_name TEXT NOT NULL,
    year_min SMALLINT,
    year_max SMALLINT,
    budget_max BIGINT,
    km_max INTEGER,
    fuel_type TEXT,
    transmission TEXT,
    city_name TEXT NOT NULL DEFAULT 'Indore',
    area TEXT NOT NULL,
    notes TEXT,
    matching_count INT NOT NULL DEFAULT 0,
    status TEXT NOT NULL DEFAULT 'active'
        CHECK (status IN ('active', 'fulfilled', 'paused', 'expired')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER set_wanted_requests_updated_at
    BEFORE UPDATE ON public.wanted_requests
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- 9. INTERESTS
CREATE TABLE IF NOT EXISTS public.interests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vehicle_id UUID NOT NULL REFERENCES public.vehicles(id) ON DELETE CASCADE,
    interested_dealer_id UUID NOT NULL REFERENCES public.dealers(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(vehicle_id, interested_dealer_id)
);

-- 10. VEHICLE REPORTS (Moderation)
CREATE TABLE IF NOT EXISTS public.vehicle_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vehicle_id UUID NOT NULL REFERENCES public.vehicles(id) ON DELETE CASCADE,
    reporter_dealer_id UUID NOT NULL REFERENCES public.dealers(id) ON DELETE CASCADE,
    reason TEXT NOT NULL,
    note TEXT,
    status TEXT NOT NULL DEFAULT 'open'
        CHECK (status IN ('open', 'reviewed', 'dismissed', 'actioned')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 11. NOTIFICATIONS
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    dealer_id UUID NOT NULL REFERENCES public.dealers(id) ON DELETE CASCADE,
    type TEXT NOT NULL,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    route_url TEXT,
    is_read BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 12. DEVICE TOKENS (Push Notifications FCM)
CREATE TABLE IF NOT EXISTS public.device_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    dealer_id UUID NOT NULL REFERENCES public.dealers(id) ON DELETE CASCADE,
    token TEXT NOT NULL UNIQUE,
    platform TEXT NOT NULL CHECK (platform IN ('android', 'ios', 'web')),
    active BOOLEAN NOT NULL DEFAULT true,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 13. AUDIT LOGS
CREATE TABLE IF NOT EXISTS public.audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_dealer_id UUID REFERENCES public.dealers(id) ON DELETE SET NULL,
    action TEXT NOT NULL,
    entity_type TEXT NOT NULL,
    entity_id UUID NOT NULL,
    metadata JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ========================================================================
-- INDEXES FOR HIGH-PERFORMANCE DISCOVERY & FILTERING
-- ========================================================================
CREATE INDEX IF NOT EXISTS idx_vehicles_status ON public.vehicles(status);
CREATE INDEX IF NOT EXISTS idx_vehicles_city_status ON public.vehicles(city_name, status);
CREATE INDEX IF NOT EXISTS idx_vehicles_make_model_status ON public.vehicles(make_name, model_name, status);
CREATE INDEX IF NOT EXISTS idx_vehicles_price ON public.vehicles(price_rupees);
CREATE INDEX IF NOT EXISTS idx_vehicles_year ON public.vehicles(year);
CREATE INDEX IF NOT EXISTS idx_vehicles_km ON public.vehicles(km);
CREATE INDEX IF NOT EXISTS idx_vehicles_published_at ON public.vehicles(published_at DESC);
CREATE INDEX IF NOT EXISTS idx_vehicles_last_confirmed ON public.vehicles(last_availability_confirmed_at DESC);
CREATE INDEX IF NOT EXISTS idx_vehicle_photos_vehicle_sort ON public.vehicle_photos(vehicle_id, sort_order ASC);
CREATE INDEX IF NOT EXISTS idx_notifications_dealer_read ON public.notifications(dealer_id, is_read, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_wanted_status_created ON public.wanted_requests(status, created_at DESC);
