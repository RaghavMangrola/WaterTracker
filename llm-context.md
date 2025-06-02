# LLM Context: Water Tracker iOS App

## Project Overview
Water Tracker is a SwiftUI-based iOS application for tracking daily water intake. The app follows MVVM (Model-View-ViewModel) architecture pattern with clean separation of concerns. It uses SwiftData for persistent storage and provides features including intake logging, progress tracking, statistics with charts, goal setting, and push notifications.

## Architecture & Frameworks
- **SwiftUI**: Modern declarative UI framework
- **SwiftData**: Core Data replacement for data persistence
- **Swift Charts**: Native charting framework for visualizations
- **UserNotifications**: Push notification system for hydration reminders
- **Foundation**: Date/time handling and calendar operations
- **MVVM Pattern**: Clean architecture with ViewModels handling business logic

## Data Models

### WaterEntry
```swift
@Model
class WaterEntry {
    var amount: Int        // Water amount in fluid ounces
    var timestamp: Date    // When the entry was recorded
}
```

### Settings
```swift
@Model  
class Settings {
    var dailyGoal: Int                // Daily water goal in fluid ounces (default: 100)
    var notificationsEnabled: Bool    // Whether reminders are enabled
    var notificationStartTime: Date   // When to start daily reminders (default: 8 AM)
    var notificationEndTime: Date     // When to stop daily reminders (default: 10 PM)
    var notificationInterval: Int     // Hours between reminders (1-4 hours)
}
```

## MVVM Architecture Structure

### File Structure
```
WaterTracker/
├── App/
│   └── WaterTrackerApp.swift          # App entry point, SwiftData configuration
├── Views/
│   ├── ContentView.swift              # Main dashboard UI
│   ├── StatsView.swift                # Statistics with interactive charts
│   ├── SettingsView.swift             # App configuration screen
│   ├── AddWaterEntryView.swift        # Manual water entry form
│   └── WaterEntryDetailView.swift     # Individual entry details
├── ViewModels/
│   ├── ContentViewModel.swift         # Main dashboard business logic
│   ├── StatsViewModel.swift           # Statistics calculations & chart data
│   └── SettingsViewModel.swift        # Settings management & notifications
├── Models/
│   ├── WaterEntry.swift               # Water entry data model
│   └── Settings.swift                 # Settings data model
├── Services/
│   └── NotificationService.swift      # Notification management service
└── Assets.xcassets/                   # App icons and assets
```

## ViewModels & Business Logic

### ContentViewModel
- **Responsibilities**: Water entry management, progress calculations, data fetching
- **Key Properties**: `waterEntries`, `todayIntake`, `progressPercentage`, `remainingOz`
- **Key Methods**: `addWater()`, `deleteEntries()`, `loadWaterEntries()`
- **State Management**: Uses `@Observable` for SwiftUI integration

### StatsViewModel
- **Responsibilities**: Chart data preparation, statistics calculations
- **Key Properties**: `chartData`, `averageIntake`, `bestDay`, `goalAchievementRate`
- **Key Methods**: `loadWaterEntries()`, `togglePeriod()`
- **Data Processing**: Aggregates daily totals for weekly/monthly views

### SettingsViewModel
- **Responsibilities**: Settings management, notification scheduling
- **Key Properties**: `currentSettings`, `showingAlert`, `alertMessage`
- **Key Methods**: `updateDailyGoal()`, `toggleNotifications()`, `scheduleNotifications()`
- **Integration**: Works with NotificationService for reminder management

## Services Layer

### NotificationService
- **Pattern**: Singleton service for centralized notification management
- **Responsibilities**: Permission requests, notification scheduling, cancellation
- **Key Methods**: `requestPermission()`, `scheduleHydrationReminders()`, `cancelAllNotifications()`
- **Integration**: Used by SettingsViewModel for notification operations

## Views & UI Components

### ContentView (Main Dashboard)
- **Pure UI**: No business logic, delegates to ContentViewModel
- **Features**: Progress tracking, quick add buttons, entry list
- **Navigation**: Links to Statistics and Settings
- **Real-time Updates**: Observes ViewModel state changes

### StatsView (Analytics Dashboard)
- **Pure UI**: Delegates all calculations to StatsViewModel
- **Features**: Interactive charts, progress visualization, statistical summary
- **Charts**: Uses Swift Charts with week/month toggle
- **Data Binding**: Reactive updates when ViewModel data changes

### SettingsView (Configuration)
- **Pure UI**: Delegates all logic to SettingsViewModel
- **Features**: Goal management, notification controls, scheduling
- **Form Handling**: SwiftUI Form with proper data binding
- **Error Handling**: Shows alerts for notification permission issues

## Data Flow & State Management
- **SwiftData Integration**: Automatic persistence with ModelContext
- **Environment Objects**: ModelContext passed through view hierarchy
- **Observable ViewModels**: Use `@Observable` for reactive UI updates
- **Unidirectional Flow**: Views → ViewModels → Models → Services
- **Error Handling**: Graceful fallbacks for data operations

## Business Logic

### Progress Calculation
```swift
// Today's total intake from all entries
var todayIntake: Int {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    return waterEntries
        .filter { calendar.isDate($0.timestamp, inSameDayAs: today) }
        .reduce(0) { $0 + $1.amount }
}

// Progress percentage (capped at 100%)
var progressPercentage: Double {
    min(Double(todayIntake) / Double(currentSettings.dailyGoal), 1.0)
}
```

### Chart Data Processing
- **Weekly View**: Last 7 days of daily totals
- **Monthly View**: Last 30 days of daily totals
- **Data Aggregation**: Groups entries by day and sums amounts
- **Missing Days**: Shows 0 oz for days with no entries

### Notification System
- **Smart Scheduling**: Calculates remaining water needs in real-time
- **Time-based Triggers**: Respects user-defined start/end times
- **Dynamic Content**: Updates notification text based on current progress
- **Service Integration**: Uses NotificationService for all operations

## MVVM Benefits & Patterns
- **Separation of Concerns**: Views handle UI, ViewModels handle logic
- **Testability**: Business logic isolated in ViewModels
- **Reusability**: ViewModels can be reused across different views
- **Maintainability**: Clear boundaries between layers
- **Data Binding**: Reactive updates with `@Observable`

## UI/UX Design Patterns
- **Card-based Layout**: Modern, clean visual hierarchy
- **Progressive Disclosure**: Advanced settings only shown when relevant
- **Immediate Feedback**: Animations and visual updates on user actions
- **Accessibility**: Semantic markup and clear visual indicators
- **Consistent Theming**: Blue water theme throughout the app

## Technical Considerations
- **Units**: All water measurements in fluid ounces (US)
- **Date Handling**: Uses Calendar for proper timezone and date calculations
- **Memory Management**: Leverages SwiftUI's automatic view lifecycle
- **Performance**: Efficient data fetching with FetchDescriptor queries
- **Data Migration**: Handles legacy data format conversions automatically

## Common Operations
1. **Adding Water**: View → ViewModel → Model → Context Save
2. **Viewing Progress**: ViewModel fetches → Calculates → Updates UI
3. **Generating Charts**: ViewModel processes data → Creates chart models
4. **Setting Goals**: ViewModel updates settings → Reschedules notifications
5. **Managing Notifications**: ViewModel → Service → System notifications

## Development Notes
- **Testing**: Uses in-memory ModelContainer for previews and testing
- **Error Recovery**: Fallback mechanisms for data operations
- **Code Organization**: MVVM structure with clear layer separation
- **Maintainability**: Well-structured, documented, and type-safe code
- **Scalability**: Easy to add new features following established patterns 