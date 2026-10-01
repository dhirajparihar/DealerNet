# DealerNet — Supabase Setup Guide

This guide details how to set up and deploy the Supabase backend for DealerNet (Indore B2B Used Vehicle Network).

---

## 📁 Migration Files in this Directory

| File | Purpose |
|------|---------|
| [`migrations/20260929_init_schema.sql`](file:///c:/Users/HP/Desktop/dealer/used_vehicle_dealer_app_build_pack/supabase/migrations/20260929_init_schema.sql) | PostgreSQL tables (`cities`, `dealers`, `makes`, `models`, `vehicles`, `vehicle_photos`, `wanted_requests`, `notifications`), foreign keys, triggers, and discovery indexes. |
| [`migrations/20260929_rls_policies.sql`](file:///c:/Users/HP/Desktop/dealer/used_vehicle_dealer_app_build_pack/supabase/migrations/20260929_rls_policies.sql) | Row Level Security (RLS) policies ensuring dealers can only modify their own inventory and view active network cars. Creates Storage buckets (`vehicle-photos`, `dealer-logos`). |
| [`seed.sql`](file:///c:/Users/HP/Desktop/dealer/used_vehicle_dealer_app_build_pack/supabase/seed.sql) | Indore pilot seed dataset: Indore city, vehicle makes/models, 5 Indore dealerships, verified vehicle listings, photos, and wanted requests. |

---

## ⚡ Method 1: Quick Setup via Supabase Web Dashboard (Recommended)

1. **Create Project:**
   - Go to [supabase.com](https://supabase.com) and create a new project (e.g. `dealernet-indore`).
   - Choose region **ap-south-1 (Mumbai, India)** for minimal latency in Indore.

2. **Execute Database Migrations:**
   - Open **SQL Editor** in the left sidebar.
   - Click **New Query**, paste the full contents of [`migrations/20260929_init_schema.sql`](file:///c:/Users/HP/Desktop/dealer/used_vehicle_dealer_app_build_pack/supabase/migrations/20260929_init_schema.sql), and click **Run**.
   - Create a second query, paste [`migrations/20260929_rls_policies.sql`](file:///c:/Users/HP/Desktop/dealer/used_vehicle_dealer_app_build_pack/supabase/migrations/20260929_rls_policies.sql), and click **Run**.

3. **Insert Seed Data:**
   - In **SQL Editor**, paste [`seed.sql`](file:///c:/Users/HP/Desktop/dealer/used_vehicle_dealer_app_build_pack/supabase/seed.sql) and click **Run**.
   - Your database will be immediately populated with realistic Indore inventory.

4. **Verify Storage Buckets:**
   - Navigate to **Storage** in the sidebar.
   - Confirm buckets `vehicle-photos` and `dealer-logos` are created and marked **Public**.

5. **Retrieve API Credentials:**
   - Navigate to **Project Settings** ➔ **API**.
   - Copy **Project URL** and **anon public key**.

---

## 💻 Method 2: Setup via Supabase CLI (Local Development)

```bash
# 1. Install Supabase CLI (if not already installed)
npm install -g supabase

# 2. Initialize and start local Supabase containers (Docker required)
supabase start

# 3. Apply schema migrations
supabase db reset
```

---

## 📱 Connecting Flutter App to Supabase

Run the Flutter app with your Supabase credentials passed via `--dart-define`:

```bash
flutter run -d chrome \
  --web-port 8080 \
  --dart-define=SUPABASE_URL="https://your-project-id.supabase.co" \
  --dart-define=SUPABASE_ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI..."
```

### Offline / Fallback Behavior:
If `SUPABASE_URL` or `SUPABASE_ANON_KEY` are omitted or blank, DealerNet automatically operates in **offline-first mock mode**, allowing full UI testing and interactive workflows without throwing connection errors.
