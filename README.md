# 💧 Water Tracker

A beautiful and intuitive iOS app to help you stay hydrated throughout the day. Track your water intake, set personalized goals, view detailed statistics, and receive smart reminders to maintain optimal hydration.

## ✨ Features

### 🎯 **Smart Progress Tracking**
- Real-time daily progress visualization with animated progress bars
- Circular progress indicators showing goal completion percentage
- Instant feedback when you reach your daily hydration goals

### 📊 **Interactive Analytics**
- Beautiful charts showing your hydration trends over time
- Weekly and monthly view options for comprehensive insights
- Statistical summaries including averages, best days, and success rates
- Color-coded visualizations (green for goal achievement, blue for progress)

### ⚡ **Quick Water Logging**
- One-tap quick add buttons for common container sizes (8 oz, 40 oz)
- Custom entry option with precise amount control
- Chronological history of all water intake entries
- Swipe-to-delete functionality for easy entry management

### 🔔 **Smart Notifications**
- Personalized hydration reminders throughout the day
- Intelligent notifications that adapt based on your current progress
- Customizable reminder schedule (start time, end time, intervals)
- Dynamic reminder content showing remaining water needed

### ⚙️ **Personalized Settings**
- Adjustable daily water goals (17-169 fl oz range)
- Flexible notification scheduling options
- Easy toggle for reminder on/off functionality
- Automatic permission handling for notifications

## 🛠 **Technical Stack**

- **SwiftUI**: Modern, declarative user interface
- **SwiftData**: Persistent data storage and management
- **Swift Charts**: Native charting framework for beautiful visualizations
- **UserNotifications**: Smart reminder system
- **iOS 17+**: Latest iOS features and optimizations
- **MVVM Architecture**: Clean separation of concerns with ViewModels

## 📱 **Screenshots**

*Screenshots coming soon - capturing the beautiful UI in action!*

## 🚀 **Getting Started**

### Prerequisites
- Xcode 15.0 or later
- iOS 17.0 or later
- macOS Sonoma or later for development

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/WaterTracker.git
   cd WaterTracker
   ```

2. **Open in Xcode**
   ```bash
   open WaterTracker.xcodeproj
   ```

3. **Build and run**
   - Select your target device or simulator
   - Press `Cmd + R` to build and run the app

### First Time Setup
1. Launch the app on your device
2. Set your daily water intake goal in Settings
3. Enable notifications for hydration reminders (optional)
4. Start logging your water intake!

## 📖 **How to Use**

### Logging Water Intake
- **Quick Add**: Tap the 8 oz or 40 oz buttons for instant logging
- **Custom Amount**: Use the "+" button to add precise amounts
- **View History**: Scroll through your chronological intake history

### Viewing Statistics
- Tap the chart icon in the navigation bar
- Switch between weekly and monthly views
- Track your progress trends and goal achievement rates

### Customizing Settings
- Tap the gear icon to access settings
- Adjust your daily goal using the stepper control
- Configure notification preferences and timing

### Managing Notifications
- Enable reminders in Settings for automatic hydration prompts
- Set your preferred reminder schedule (start/end times and intervals)
- Receive smart notifications that show your remaining daily intake

## 🏗 **Project Structure (MVVM Architecture)**

```
WaterTracker/
├── 📱 App/
│   └── WaterTrackerApp.swift          # App entry point & configuration
├── 🎨 Views/
│   ├── ContentView.swift              # Main dashboard UI
│   ├── StatsView.swift                # Analytics & charts UI
│   ├── SettingsView.swift             # Configuration screen UI
│   ├── AddWaterEntryView.swift        # Manual entry form UI
│   └── WaterEntryDetailView.swift     # Entry details UI
├── 🧠 ViewModels/
│   ├── ContentViewModel.swift         # Main dashboard business logic
│   ├── StatsViewModel.swift           # Analytics calculations & data
│   └── SettingsViewModel.swift        # Settings management logic
├── 💾 Models/
│   ├── WaterEntry.swift               # Water intake data model
│   └── Settings.swift                 # App preferences model
├── 🔧 Services/
│   └── NotificationService.swift      # Notification management
└── 🎨 Assets/
    └── Assets.xcassets/               # App icons & images
```

## 🔧 **Key Components**

### MVVM Architecture
- **Models**: Data structures (`WaterEntry`, `Settings`)
- **Views**: SwiftUI views focused purely on UI presentation
- **ViewModels**: Business logic, data processing, and state management
- **Services**: Utility services for notifications and other shared functionality

### Data Models
- **WaterEntry**: Stores intake amount and timestamp
- **Settings**: Manages user preferences and goals

### ViewModels
- **ContentViewModel**: Handles water entry management, progress calculations
- **StatsViewModel**: Manages chart data, statistics calculations
- **SettingsViewModel**: Controls app configuration and notification scheduling

### Views
- **ContentView**: Dashboard with progress tracking and quick actions
- **StatsView**: Interactive charts and analytics display
- **SettingsView**: Goal and notification configuration interface
- **AddWaterEntryView**: Manual water entry form

### Services
- **NotificationService**: Centralized notification management and scheduling

## 🎨 **Design Philosophy**

- **Clean & Intuitive**: Minimalist design focused on ease of use
- **Water Theme**: Consistent blue color scheme representing hydration
- **Immediate Feedback**: Instant visual updates and animations
- **Accessibility First**: Clear labels and semantic UI elements
- **MVVM Pattern**: Clean separation of concerns for maintainability

## 🚀 **Future Enhancements**

- [ ] Apple Watch companion app
- [ ] HealthKit integration for comprehensive health tracking
- [ ] Social sharing and challenges with friends
- [ ] Advanced analytics with hydration patterns
- [ ] Multiple container presets for different users
- [ ] Dark mode optimization
- [ ] Widgets for iOS home screen

## 🤝 **Contributing**

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 💡 **Inspiration**

Created to help people maintain healthy hydration habits with a beautiful, easy-to-use interface. Stay healthy, stay hydrated! 💧

---

**Made with ❤️ and SwiftUI using MVVM Architecture**

*Drink water, code better!* 🚰✨ 