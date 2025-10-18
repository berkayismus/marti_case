# LocationCubit State Flow

## State Transitions with isTracking

### 1. Initialize (App Start)
```
LocationInitial → LocationLoading → LocationLoaded(isTracking: _locationService.isTracking)
```
- Checks actual service state
- Preserves tracking status if app was closed during tracking

### 2. Start Tracking
```
LocationLoaded(isTracking: false) → LocationLoaded(isTracking: true)
```
- User presses "Takibi Başlat"
- **State is updated FIRST** with isTracking: true
- Then service starts listening to location updates
- This prevents race conditions with marker callbacks

### 3. Stop Tracking
```
LocationLoaded(isTracking: true) → LocationLoaded(isTracking: false)
```
- User presses "Takibi Durdur"
- Service stops listening
- State explicitly sets isTracking: false

### 4. New Marker Added (During Tracking)
```
LocationLoaded(isTracking: true) 
→ LocationLoaded(isTracking: true, updated markers)
```
- **FIXED**: Now uses `_locationService.isTracking` (source of truth)
- Only updates markers and mapMarkers
- Tracking state taken directly from service to avoid race conditions

### 5. Load Marker Address
```
LocationLoaded → MarkerAddressLoading → LocationLoaded
```
- All states preserve isTracking from currentState
- User taps marker to see address
- Dialog shows, address loads, returns to LocationLoaded

### 6. Reset Route
```
LocationLoaded(any isTracking) → LocationLoaded(isTracking: false)
```
- Stops tracking if active
- Clears all markers
- Sets isTracking: false

## Key Fixes Applied

### Fix 1: Race Condition in startTracking()
**Problem**: `startTracking()` was emitting `isTracking: true` AFTER calling `_locationService.startTracking()`, but the service immediately added a marker which triggered `_onNewMarkerAdded` callback, creating a race condition.

**Solution**: Emit `isTracking: true` BEFORE calling service:

```dart
Future<void> startTracking() async {
  final currentState = state;
  if (currentState is! LocationLoaded) return;

  // ✅ Update state FIRST
  emit(currentState.copyWith(isTracking: true));

  try {
    await _locationService.startTracking();
  } catch (e) {
    // Revert on error
    emit(currentState.copyWith(isTracking: false));
  }
}
```

### Fix 2: Source of Truth for isTracking
**Problem**: When new markers were added, `isTracking` state was taken from `currentState`, which could be stale or out of sync.

**Solution**: Use `_locationService.isTracking` as the single source of truth:

```dart
emit(
  currentState.copyWith(
    markers: List.from(_locationService.markers),
    mapMarkers: mapMarkers,
    isTracking: _locationService.isTracking, // ✅ Get from service
  ),
);
```

This ensures that when location updates trigger new markers while tracking is active, the UI continues to show the "Takibi Durdur" button instead of reverting to "Takibi Başlat".
