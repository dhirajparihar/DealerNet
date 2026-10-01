# DealerNet — B2B Used Vehicle Dealer Network (Indore Pilot)

A mobile-first B2B dealer exchange network for used vehicle dealers in Indore, Madhya Pradesh. Designed with **`ui-ux-pro-max`** design intelligence, clean architecture, responsive layout, offline-first fallback, and optional Supabase backend synchronization.

---

## 🚗 Core Purpose & Value Proposition

- **The Problem:** Used car dealers currently discover stock through fragmented WhatsApp groups, personal status catalogs, and dozens of daily phone calls. Inventory is stale, duplicated, and unsearchable.
- **The Solution:** A private, dealer-only inventory discovery platform where verified dealers can find available stock in seconds and initiate direct WhatsApp or phone communication with the listing dealer.
- **Core User Journey:**
  1. **Find Stock in < 10 Seconds:** Search and filter live inventory across 30+ Indore dealers using price, KM, make/model, fuel, transmission, and location filters.
  2. **Add Inventory in < 60 Seconds:** 3-step streamlined wizard with smart defaults, photo uploads, and local draft saving.
  3. **1-Tap Freshness & Availability:** Instantly update listing status (`AVAILABLE`, `RESERVED`, `SOLD`) with zero typing to ensure high trust.

---

## 📱 Feature Overview & Screen Index (20 Screens)

| Code | Screen | Key Functionality |
|------|--------|-------------------|
| **S01** | **Splash** | Fast session validation, approval routing, and brand identity intro. |
| **S02** | **Mobile Login** | Dealer phone authentication with default `+91` country code. |
| **S03** | **OTP Verification** | 6-digit verification code with resend timer and auto-submit UX. |
| **S04** | **Dealer Onboarding** | Dealership name, contact person, and Indore locality picker (Vijay Nagar, Palasia, etc.). |
| **S05** | **Home Feed** | Search hero, live network inventory counts, quick actions, and recent vehicle additions. |
| **S06 / S07** | **Search & Results** | Multi-facet filtering (Make, Fuel, Transmission, Budget/KM sliders, Year, Sorting). |
| **S08** | **Vehicle Detail** | High-res gallery, Lakh/Crore pricing, specs grid, dealer trust badge, quick Call & WhatsApp CTAs. |
| **S09** | **Add Vehicle — Photos** | Up to 10 photos, cover image selector, delete/reorder with compression preview. |
| **S10** | **Add Vehicle — Details** | Cascaded Make/Model dropdowns, numeric keyboards for KM/Price, Indore area picker. |
| **S11** | **Add Vehicle — Review** | Live preview card, "Publish Vehicle" CTA, success dialog, and instant WhatsApp broadcast share. |
| **S12 / S13** | **My Stock & Status** | Active, Reserved, Sold, and Draft tabs with 1-tap status toggles and freshness reconfirmation. |
| **S14 / S15** | **Wanted Stock Board** | Broadcast buyer requests, matching inventory counters, and "I Have Stock" outreach. |
| **S16** | **Notifications** | Alerts for matching cars, wanted demand, and dealer verification status with deep linking. |
| **S17** | **Dealership Profile** | Business details, verification status, active listing counts, and profile editing. |
| **S18** | **Settings** | Push/WhatsApp notification toggles, Indore support contact (`+91 98260 00111`), terms, and logout. |
| **S19** | **Report Listing** | Moderation reasons (sold, misleading price, duplicate, fraudulent) with admin notes. |
| **S20** | **Pending Approval** | Reassuring status view for new dealers undergoing Indore operations team verification. |

---

## 🏗️ Architecture & Project Structure

Follows feature-first clean architecture with state isolation as specified in system specifications:

```
lib/
├── app/
│   ├── app.dart                   # MaterialApp.router with global theme & routerConfig
│   ├── router.dart                # GoRouter routing tree, route guards & ShellRoute
│   ├── main_navigation_shell.dart # 4-tab bottom navigation with notification badge
│   ├── constants/
│   │   ├── app_colors.dart        # B2B brand tokens, status palettes, and button colors
│   │   └── app_strings.dart       # Localized strings, Indore pilot defaults
│   └── theme/
│       └── app_theme.dart         # Material 3 ThemeData with Outfit font & component styling
├── core/
│   ├── network/
│   │   └── supabase_config.dart   # Supabase client initialization & offline mode fallback
│   ├── utils/
│   │   ├── currency_formatter.dart # Indian currency formatting (₹ Lakh / ₹ Crore / comma separation)
│   │   ├── date_formatter.dart     # Freshness relative formatting ("Confirmed 25m ago")
│   │   └── url_helper.dart         # Native WhatsApp & Phone dialer deep link launchers
│   └── widgets/
│       ├── app_button.dart         # Primary and secondary buttons with loading state
│       ├── empty_state.dart        # Reusable empty states with action CTAs
│       ├── status_badge.dart       # Accessible status badges and verified dealer chips
│       └── vehicle_card.dart       # Comprehensive vehicle card with quick WhatsApp & Call
└── features/
    ├── auth/                       # Splash, Mobile Login, OTP, Onboarding, Pending Approval
    ├── dealer/                     # Dealer domain model and Dealership Profile view
    ├── home/                       # Home screen with search hero, network KPIs, and feed
    ├── search/                     # Search screen with brand chips, sort modal, and bottom sheet filters
    ├── vehicles/                   # Vehicle domain, mock data, Riverpod providers, Detail & Add flows
    ├── wanted/                     # Wanted stock requests, match counts, and broadcast creation
    ├── notifications/              # Notification items, unread counter, and feed view
    └── settings/                   # Notification preferences, Indore support, and account management
```

---

## ⚡ Backend & Supabase Integration

DealerNet supports dual backend modes:
1. **Offline / Demo Mode (Default):** Runs seamlessly using Riverpod in-memory state with realistic Indore seed data. No backend credentials required for local testing or UI review.
2. **Supabase Live Mode:** Connects to PostgreSQL database with Row Level Security (RLS) policies and Storage buckets for vehicle photos.

### Supabase Database Setup
- **Migrations:** SQL schema definitions located in [`supabase/migrations/20260929_init_schema.sql`](file:///c:/Users/HP/Desktop/dealer/used_vehicle_dealer_app_build_pack/supabase/migrations/20260929_init_schema.sql) and RLS policies in [`supabase/migrations/20260929_rls_policies.sql`](file:///c:/Users/HP/Desktop/dealer/used_vehicle_dealer_app_build_pack/supabase/migrations/20260929_rls_policies.sql).
- **Seed Data:** Pre-populated Indore pilot data in [`supabase/seed.sql`](file:///c:/Users/HP/Desktop/dealer/used_vehicle_dealer_app_build_pack/supabase/seed.sql).
- **Setup Guide:** See detailed step-by-step instructions in [`supabase/README.md`](file:///c:/Users/HP/Desktop/dealer/used_vehicle_dealer_app_build_pack/supabase/README.md).

---

## 🛠️ Tech Stack & Dependencies

- **Framework:** Flutter 3.41+ (Dart 3.11+)
- **State Management:** `flutter_riverpod: ^2.6.1`
- **Routing:** `go_router: ^17.5.0`
- **Backend SDK:** `supabase_flutter: ^2.17.2`
- **Typography:** `google_fonts: ^8.2.1` (`Outfit`)
- **Formatting:** `intl: ^0.20.3` (Indian Currency ₹ Lakh / Crore)
- **Native Integrations:** `url_launcher: ^6.3.2` (WhatsApp chat & phone calls)
- **Utilities:** `uuid: ^4.6.0`

---

## 🚀 Environment & Running the Project

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Configure Environment Variables (Optional)
Copy `.env.example` to `.env` or set `--dart-define` parameters for Supabase:
```env
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

### 3. Run on Web (Chrome / Edge)
```bash
# Demo / Offline mode:
flutter run -d chrome --web-port 8080 --web-hostname 127.0.0.1

# With Supabase backend:
flutter run -d chrome --web-port 8080 --web-hostname 127.0.0.1 \
  --dart-define=SUPABASE_URL="https://your-project-id.supabase.co" \
  --dart-define=SUPABASE_ANON_KEY="your-anon-key-here"
```

### 4. Run on Desktop (Windows / macOS / Linux)
```bash
flutter run -d windows
```

### 5. Run on Mobile (Android / iOS)
```bash
flutter run -d android
```

---

## 🧪 Testing & Code Quality Verification

- **Run Static Code Analysis:**
  ```bash
  flutter analyze
  ```
  *(Expected: `No issues found!`)*

- **Run Automated Widget Tests:**
  ```bash
  flutter test
  ```
  *(Expected: `All tests passed!`)*
