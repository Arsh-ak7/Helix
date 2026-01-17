# Helix App Runbook

## Feature: Create Routine - Reordering

### Status
- [x] Design
- [x] Implementation
- [ ] Verification

### Context
Users currently select exercises in a specific order, but cannot change that order without deselecting and reselecting. A routine builder needs to allow flexible sequencing of exercises.

### Design
1.  **UI Layout**:
    - Split the `List` in `CreateRoutineView` into two sections:
        - **Section 1: "Sequence"**: Displays the `selectedExercises` list.
            - Supports **Drag & Drop** reordering.
            - Supports **Swipe to Delete**.
            - Shows index numbers (1, 2, 3...) to indicate order.
        - **Section 2: "Library"**: Displays the full `filteredExercises` list.
            - Behaves as an "Add/Remove" picker.
            - Items already in "Sequence" show a checkmark.
            - Tapping an item toggles its presence in "Sequence".

2.  **Logic**:
    - `moveExercise(from:to:)`: Updates the `selectedExercises` array using standard SwiftUI `move(fromOffsets:toOffset:)`.
    - `removeExercise(at:)`: Removes items from specific indices (for swipe-to-delete).

3.  **UX Enhancements**:
    - If "Sequence" is empty, hide the section or show a placeholder text.
    - Use `EditButton()` in toolbar to toggle explicit edit mode (optional, but good for accessibility).

## Enhanced Exercise Discovery & Details (Jan 2026)

### Status
- [ ] Model & Seeding Updates
- [ ] Enhanced Exercise List (Thumbnails & Tags)
- [ ] Advanced Detail View (Grid, Gallery, Secondary Muscles)

### Design
1.  **Model**: Add `force`, `level`, `mechanic`, `secondaryMuscles`, and `category` to `Exercise`.
2.  **Seed**: Update `DataManager` to map all JSON fields. Handle the multiple images array.
3.  **List UI**:
    - Add `AsyncImage` thumbnails (50x50) to `ExerciseListView`.
    - Add horizontal badges for `Equipment` and `Level`.
4.  **Detail UI**:
    - **Gallery**: `TabView` with `PageTabViewStyle` for the `images` array.
    - **Info Grid**: 4 cards showing Category, Level, Force, and Mechanic.
    - **Muscles**: Visual distinction between Primary and Secondary.


## Codebase Audit & Missing Features (Jan 2026)

### Critical Issues
- [ ] **Destructive Syncing:** `DataManager.syncExercises` deletes all exercises to reset, which is risky.
- [ ] **Safety Dialogs:** Missing confirmation for "Delete Workout" in `ActiveWorkoutView`.

### Architectural Improvements
- [ ] **Routine Extensibility:** `RoutineExercise` needs `targetSets`, `targetReps`, `targetRestTime`.
- [ ] **Supersets:** Current flat model doesn't support grouping exercises.
- [ ] **Set Metadata:** `WorkoutSet` needs `rpe` (Int) and `setType` (Enum: Warmup, Normal, Drop).

### Feature Roadmap (Prioritized)
1.  **Routine Editing:** Ability to edit an existing routine (reusing the new Reordering UI).
2.  **RPE & Set Types:** Add RPE slider and Warmup toggle to `ActiveWorkoutView`.
3.  **Variable Rest Timer:** Allow custom rest timers per exercise instead of hardcoded 90s.
4.  **Superset Support:** UI and Model updates to group exercises.

