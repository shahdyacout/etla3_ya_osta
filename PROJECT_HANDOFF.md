# Project Handoff: etla3_ya_osta

## Architecture
- **Framework:** Flutter
- **Pattern:** Clean Architecture (Domain, Data, Presentation)
- **State Management:** `flutter_bloc` (Cubit)
- **Backend:** Firebase (Auth, Firestore)

## Core Components
- **Either Type:** Manually implemented in `lib/core/error/failures.dart` (Left/Right).
- **UseCases:** Follows `UseCase<Type, Params>` interface found in `lib/features/Auth/domain/usecases/usecase.dart`.
- **Failures:** Standardized in `lib/core/error/failures.dart`.

## Current Progress (Driver Feature)
### Phase 1: Completed
- Driver Online/Offline status logic implemented.
- Firestore field `isOnline` in `drivers` collection.
- Repository and Data Source for status updates implemented.
- `DriverCubit` manages status transitions.

### Known Issue
- **Critical:** The folder `lib/features/ driver/` has a leading space in the name. This must be refactored to `lib/features/driver/` before proceeding with UI or further logic.

## Phase 2 & 3 Plan
1. **Dashboard:**
   - Online/Offline Toggle.
   - Queue Position (Stream listener from Firestore `drivers` collection).
2. **Passenger Verification:**
   - QR Scanner integration.
   - Validation of passenger UID in the `trips` collection.
   - Real-time seat occupancy updates.
3. **Performance Summary:**
   - Real-time display of: Trips Completed, Total Earnings, and Rating.

## Development Constraints
- Work strictly inside `lib/features/driver`.
- Do not modify `pubspec.yaml`, `main.dart`, or `app_router.dart`.
- Do not touch Auth or Traveler features.
- Reuse `lib/core/` widgets and themes.
- Use `flutter_bloc` (Cubit) only.
- No new packages; stick to current dependencies (cloud_firestore, firebase_auth, etc.).
