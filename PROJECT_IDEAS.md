# Project Ideas & Continuation Guide

## Project Overview
**Name:** etla3_ya_osta  
**Framework:** Flutter  
**Architecture:** Clean Architecture (Domain, Data, Presentation)  
**State Management:** flutter_bloc (Cubit)  
**Backend:** Firebase (Auth, Firestore)

## Current Features

### Auth Feature (`lib/features/Auth/`)
- User authentication with Firebase Auth
- Login/Register screens

### Driver Feature (`lib/features/driver/`)
- Driver online/offline status management
- **Known Issue:** Folder has leading space - rename `lib/features/ driver/` → `lib/features/driver/`

### Traveler Feature (`lib/features/traveler/`)
- Passenger-side functionality

### Wallet Feature (`lib/features/wallet/`)
- Payment/earnings management

## Project Ideas (Priority Order)

### 🔥 P0 - Critical Fixes
1. **Fix folder naming issue**
   - Rename `lib/features/ driver/` to `lib/features/driver/`
   - Update all imports

### 🚀 P1 - Driver Feature Completion

#### Phase 2: Dashboard
- [ ] Online/Offline toggle UI
- [ ] Queue position display (real-time from Firestore)
- [ ] Driver stats overview

#### Phase 3: Passenger Verification
- [ ] QR Scanner integration for passenger verification
- [ ] Validate passenger UID from `trips` collection
- [ ] Real-time seat occupancy updates

#### Phase 4: Performance Summary
- [ ] Trips completed counter
- [ ] Total earnings display
- [ ] Rating system

### 💰 P2 - Wallet Feature
- [ ] Earnings history
- [ ] Payment methods management
- [ ] Transaction receipts
- [ ] Withdrawal requests

### 🗺️ P3 - Traveler Feature Enhancement
- [ ] Trip booking flow
- [ ] Driver tracking
- [ ] Trip history
- [ ] Rating & reviews

### 📊 P4 - Admin & Analytics
- [ ] Admin dashboard (web)
- [ ] Trip analytics
- [ ] Driver performance metrics
- [ ] Revenue reports

### 🔔 P5 - Notifications
- [ ] Push notifications (FCM)
- [ ] Trip updates
- [ ] Payment notifications

### 🌐 P6 - Advanced Features
- [ ] Real-time map integration
- [ ] Route optimization
- [ ] Multi-language support
- [ ] Dark mode

## Development Rules

### Do's
- ✅ Work inside `lib/features/` for feature-specific code
- ✅ Reuse `lib/core/` widgets and themes
- ✅ Use `flutter_bloc` (Cubit) for state management
- ✅ Follow Clean Architecture pattern
- ✅ Keep features modular and isolated

### Don'ts
- ❌ Don't modify `pubspec.yaml` without approval
- ❌ Don't modify `main.dart` or `app_router.dart`
- ❌ Don't touch Auth or Traveler features (unless assigned)
- ❌ Don't add new packages without approval
- ❌ Don't break existing functionality

## Firestore Collections

```
drivers/
  ├── userId (string)
  ├── isOnline (boolean)
  ├── queuePosition (number)
  ├── tripsCompleted (number)
  ├── earnings (number)
  └── rating (number)

trips/
  ├── tripId (string)
  ├── driverId (string)
  ├── passengerId (string)
  ├── status (string: pending/active/completed)
  ├── seats (number)
  └── createdAt (timestamp)
```

## Tech Stack

| Component | Technology |
|-----------|------------|
| Framework | Flutter |
| State | flutter_bloc |
| DI | get_it |
| Backend | Firebase Auth + Firestore |
| QR | qr_flutter |

## Quick Start for New Agent

1. Read `PROJECT_HANDOFF.md` for architecture details
2. Check `lib/features/driver/` for current progress
3. Fix folder naming issue if not done
4. Start with Phase 2 (Dashboard) implementation

## Contact & Context

- **Project Type:** Ride-sharing / Transportation app
- **Target Users:** Drivers and Passengers
- **Key Feature:** Real-time trip management, driver-passenger matching
