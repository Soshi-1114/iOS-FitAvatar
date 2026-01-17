# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

FitAvatar is an iOS fitness application built with SwiftUI that combines workout tracking with a gamified avatar system. Users track workouts and earn XP to grow their avatar, with body-part specific stat progression.

## Build & Development Commands

### Building the Project
```bash
# Build the app
xcodebuild -scheme FitAvatar -configuration Debug build

# Build for testing
xcodebuild -scheme FitAvatar -configuration Debug build-for-testing

# Clean build folder
xcodebuild clean -scheme FitAvatar
```

### Running Tests
```bash
# Run all unit tests
xcodebuild test -scheme FitAvatar -destination 'platform=iOS Simulator,name=iPhone 15'

# Run specific test target
xcodebuild test -scheme FitAvatar -only-testing:FitAvatarTests -destination 'platform=iOS Simulator,name=iPhone 15'

# Run UI tests
xcodebuild test -scheme FitAvatar -only-testing:FitAvatarUITests -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Opening the Project
```bash
# Open in Xcode
open FitAvatar.xcodeproj
```

## Architecture

### Navigation Structure
The app uses a tab-based architecture with `MainTabView` as the root navigation component:
- **HomeView**: Dashboard showing avatar, today's workouts, and quick workout shortcuts
- **WorkoutView**: Exercise library and workout management
- **StatisticsView**: Training history, radar chart visualization, and progress tracking
- **SettingsView**: App configuration including appearance, notifications, goals, and data export

Entry point: `FitAvatarApp.swift` → `ContentView.swift` → `MainTabView.swift`

### Data Layer

#### Persistence Strategy
The app uses **UserDefaults for data persistence** (not Core Data, despite Core Data boilerplate existing in the project). The Core Data model (`FitAvatar.xcdatamodeld`) and `PersistenceController` exist but are not actively used.

**Primary Data Store**: `AppData` singleton class manages all app state:
- Workout history (`[WorkoutRecord]`)
- Avatar stats (`AvatarStats`)
- User preferences (name, goals, settings)
- Data is automatically saved to UserDefaults via `@Published` property observers

#### Key Data Models
- **Exercise** (`FitAvatar/Models/Exercise.swift`): Exercise definitions with categories, difficulty, target muscles, and instructions. Contains `sampleExercises` static property for development.
- **WorkoutRecord** (`AppData.swift`): Represents completed workouts with sets, duration, XP earned, and date
- **AvatarStats** (`AvatarStats.swift`): Body-part specific stats (arms, shoulders, abs, back, legs) with XP and level calculations
- **AppData** (`AppData.swift`): Global singleton managing all app state and UserDefaults persistence

### State Management
- **AppData.shared**: Global singleton accessed throughout the app
- **@Published properties**: Automatically trigger UI updates and UserDefaults persistence
- **Core Data context**: Injected via environment but not actively used for data storage

### View Organization & File Duplication

**CRITICAL**: There is ongoing refactoring that has created duplicate files:

- **Root directory** (`FitAvatar/*.swift`): Contains the **active** view files referenced in `project.pbxproj`
- **Views subdirectory** (`FitAvatar/Views/*.swift`): Contains duplicate/outdated view files NOT in the build

**When modifying views, ALWAYS edit the root-level files**, not the Views subdirectory versions. Verify by checking `FitAvatar.xcodeproj/project.pbxproj` to confirm which file is actually compiled.

Active view files (in root `FitAvatar/` directory):
- `MainTabView.swift`
- `HomeView.swift`
- `WorkoutView.swift`
- `StatisticsView.swift`
- `SettingsView.swift`
- `WorkoutRecordView.swift`
- `AvatarDetailView.swift`

### Navigation Best Practices

**SwiftUI Navigation**: Use `@Environment(\.dismiss)` instead of the older `@Environment(\.presentationMode)` pattern:

```swift
// ✅ Correct (iOS 15+)
@Environment(\.dismiss) private var dismiss
dismiss()

// ❌ Avoid (deprecated pattern)
@Environment(\.presentationMode) var presentationMode
presentationMode.wrappedValue.dismiss()
```

**Timing for cascading dismissals**: When dismissing multiple navigation levels, use appropriate delays to avoid navigation stack conflicts:
- Immediate dismiss: `dismiss()`
- Delayed callback after dismiss: `DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)`

See `NAVIGATION_FIX.md` for detailed explanation of navigation timing issues and solutions.

### Gamification System

**Avatar Growth**: Workouts earn XP that increases body-part specific stats:
- Each workout records XP based on sets/duration
- XP is distributed to relevant body parts (e.g., push-ups → arms + shoulders)
- Each stat levels up every 100 points
- RadarChartView visualizes current stat distribution

**XP Calculation**: Defined in `WorkoutRecordView.swift`

### Language
The app UI is **entirely in Japanese**. When adding strings or modifying UI text, maintain consistency with Japanese language throughout.

## Key Technologies
- **SwiftUI**: Declarative UI framework
- **UserDefaults**: Primary persistence mechanism
- **Combine**: For reactive state management via `@Published`
- **iOS Deployment Target**: iOS 17.5+
- **Swift Version**: 5.0
- **Xcode Version**: 15.4

## Common Patterns

### Adding a New Exercise
Add to `Exercise.sampleExercises` array in `FitAvatar/Models/Exercise.swift`:
```swift
Exercise(
    name: "エクササイズ名",
    category: .upperBody,
    targetMuscles: ["筋肉1", "筋肉2"],
    difficultyLevel: .beginner,
    instructions: "手順の説明",
    imageName: "sf.symbol.name"
)
```

### Recording a Workout
1. `WorkoutRecordView` handles workout tracking with timer/interval functionality
2. On completion, creates `WorkoutRecord` and adds to `AppData.shared.workoutHistory`
3. XP is calculated and distributed to relevant body parts via `AppData.shared.addXPToStats()`
4. Data is automatically persisted to UserDefaults

### Data Export/Import
`AppData` provides `exportData()` and `importData(_:)` methods for JSON-based backup/restore functionality.

## Development Notes

- **No Core Data**: Despite boilerplate files existing, the app uses UserDefaults exclusively
- **Singleton pattern**: `AppData.shared` is the single source of truth for app state
- **File duplication**: Always modify root-level view files, not Views subdirectory
- **SwiftUI previews**: Use `PersistenceController.preview` (even though it's unused in production)
- **Sample data**: `Exercise.sampleExercises` and `WorkoutHistory.sampleData` available for testing
