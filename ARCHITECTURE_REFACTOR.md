# Architecture Update: Separation of Concerns

## Overview
Refactored the application to separate Map-related state management from Location tracking state management for better code organization and maintainability.

## Changes Made

### 1. New Files Created

#### `lib/cubit/map_cubit.dart`
- **Responsibility**: Manages all map-related state (markers display, address loading)
- **Dependencies**: `StorageService`, `LocationService`
- **Key Methods**:
  - `initialize(markers)`: Initialize map with markers
  - `updateMarkers(markers)`: Update map when new location markers are added
  - `loadMarkerAddress(index)`: Fetch and display address for a marker

#### `lib/cubit/map_state.dart`
- **States**:
  - `MapInitial`: Initial state
  - `MapLoaded`: Map loaded with markers
  - `MarkerAddressLoading`: Loading address for a specific marker

### 2. Modified Files

#### `lib/cubit/location_state.dart`
**Removed**:
- `mapMarkers` field from `LocationLoaded`
- `MarkerAddressLoading` state (moved to `MapState`)
- Google Maps imports

**Kept**:
- `markers`: List of location data
- `isTracking`: Tracking status
- All error states

#### `lib/cubit/location_cubit.dart`
**Removed**:
- `_createMapMarkers()` method
- `loadMarkerAddress()` method
- Geocoding imports
- Google Maps imports

**Added**:
- `onMarkersUpdated` callback to notify `MapCubit`

**Modified**:
- `initialize()`: Notifies MapCubit after loading markers
- `_onNewMarkerAdded()`: Notifies MapCubit when new marker is added
- `resetRoute()`: Notifies MapCubit when markers are cleared

#### `lib/services/location_service.dart`
**Added**:
- `updateMarker(index, marker)`: Update specific marker (for address updates)

#### `lib/bloc_providers.dart`
**Changes**:
- Now provides both `LocationCubit` and `MapCubit`
- Sets up communication between cubits via `onMarkersUpdated` callback

#### `lib/screens/map_screen.dart`
**Changes**:
- Now uses two BlocBuilders: one for `LocationCubit`, one for `MapCubit`
- `LocationCubit` handles: tracking status, marker count, permissions
- `MapCubit` handles: map markers display, address dialogs

## Benefits

### 1. **Separation of Concerns**
- Location tracking logic is isolated from map display logic
- Each Cubit has a single, well-defined responsibility

### 2. **Better Testability**
- Can test location tracking without map UI dependencies
- Can test map display without location tracking complexity

### 3. **Improved Maintainability**
- Changes to map features don't affect location tracking
- Changes to tracking logic don't affect map display
- Easier to understand and modify each component

### 4. **Scalability**
- Easy to add new map features (e.g., polylines, heatmaps)
- Easy to add new location features (e.g., geofencing)
- Can replace map implementation without touching location logic

## Data Flow

```
User Action (Start Tracking)
    ↓
LocationCubit.startTracking()
    ↓
LocationService.startTracking()
    ↓
New Position Detected
    ↓
LocationService.onMarkerAdded callback
    ↓
LocationCubit._onNewMarkerAdded()
    ↓
LocationCubit.onMarkersUpdated callback
    ↓
MapCubit.updateMarkers()
    ↓
MapState updated
    ↓
UI Rebuilds
```

## State Management Flow

### LocationCubit States
```
LocationInitial
    ↓ initialize()
LocationLoading
    ↓ markers loaded
LocationLoaded(markers, isTracking)
    ↓ startTracking()
LocationLoaded(markers, isTracking: true)
    ↓ new marker
LocationLoaded(updated markers, isTracking: true)
```

### MapCubit States
```
MapInitial
    ↓ initialize(markers)
MapLoaded(mapMarkers, markers)
    ↓ marker tapped
MarkerAddressLoading(...)
    ↓ address fetched
MapLoaded(updated mapMarkers, updated markers)
```

## Testing Strategy

### LocationCubit Tests
- Test tracking start/stop
- Test marker addition
- Test permission handling
- Mock LocationService and StorageService

### MapCubit Tests
- Test marker display
- Test address loading
- Test marker updates
- Mock StorageService and LocationService

### Integration Tests
- Test callback communication between cubits
- Test UI updates from both cubits
- Test error scenarios

## Migration Notes

If you have existing code that references:
- `LocationLoaded.mapMarkers` → Use `MapLoaded.mapMarkers` instead
- `LocationCubit.loadMarkerAddress()` → Use `MapCubit.loadMarkerAddress()` instead
- `MarkerAddressLoading` state from LocationState → Now in MapState

## Future Improvements

1. **Add Polyline Support** in MapCubit for route visualization
2. **Add Clustering** in MapCubit for many markers
3. **Add Offline Maps** support in MapCubit
4. **Add Location History** feature in LocationCubit
5. **Add Export Routes** feature using both cubits
