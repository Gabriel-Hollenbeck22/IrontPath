<p align="center">
  <img src="docs/screenshots/app-icon.png" alt="IronPath Logo" width="120" height="120">
</p>

<h1 align="center">IronPath</h1>

<p align="center">
  <strong>Your Intelligent Fitness Companion</strong>
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#screenshots">Screenshots</a> •
  <a href="#tech-stack">Tech Stack</a> •
  <a href="#architecture">Architecture</a> •
  <a href="#getting-started">Getting Started</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Swift-5.10-orange?logo=swift" alt="Swift 5.10">
  <img src="https://img.shields.io/badge/SwiftUI-iOS%2017+-blue?logo=apple" alt="SwiftUI">
  <img src="https://img.shields.io/badge/SwiftData-Persistence-purple" alt="SwiftData">
  <img src="https://img.shields.io/badge/HealthKit-Integration-red?logo=apple" alt="HealthKit">
  <img src="https://img.shields.io/badge/WidgetKit-Widgets-cyan" alt="WidgetKit">
</p>

---

## Overview

IronPath is a comprehensive fitness tracking iOS app that combines intelligent workout logging with nutrition management. Using science-backed algorithms, it analyzes correlations between your workouts, nutrition, sleep, and recovery to provide personalized recommendations.

## Features

### 💪 Smart Workout Tracking
- **Progressive Overload Detection**: Automatically identifies when you're ready to increase weight
- **Volume Tracking**: Monitor total workout volume with per-muscle group breakdowns
- **Exercise Library**: 100+ exercises with muscle group targeting
- **Workout Templates**: Pre-built programs (PPL, Upper/Lower, Full Body) or create your own
- **Rest Timer**: Configurable rest periods with haptic notifications

### 🍎 Nutrition Management
- **Barcode Scanning**: Quickly log foods using camera (Open Food Facts API)
- **Macro Tracking**: Real-time protein, carbs, and fat monitoring
- **Custom Recipes**: Build and save your favorite meals
- **Calorie Reports**: Daily, weekly, and monthly visualizations
- **Micronutrient Tracking**: Complete vitamin and mineral logging

### 📊 Intelligent Insights
- **Recovery Score**: Calculated from sleep, protein intake, and rest days
- **Smart Suggestions**: Science-backed recommendations like:
  - "Strength plateauing? Add 40g carbs on training days"
  - "Hit 8+ reps 3x in a row - time to progress weight"
  - "High leg volume yesterday - upper body recommended"
- **Correlation Charts**: Visualize relationships between nutrition and performance

### 🔥 Gamification
- **Streak Tracking**: Workout and nutrition logging streaks
- **Milestone Celebrations**: Animated celebrations for achievements
- **Progress Charts**: Track your journey over time

### ❤️ Apple Ecosystem Integration
- **HealthKit**: Sync weight, sleep, and activity data
- **Widgets**: Home screen widgets for streaks and daily progress
- **Notifications**: Smart reminders for workouts and meal logging

## Screenshots

<p align="center">
  <img src="docs/screenshots/dashboard.png" width="200" alt="Dashboard">
  <img src="docs/screenshots/workout.png" width="200" alt="Workout">
  <img src="docs/screenshots/nutrition.png" width="200" alt="Nutrition">
  <img src="docs/screenshots/analytics.png" width="200" alt="Analytics">
</p>

> *Add your own screenshots by running the app in Simulator and using `Cmd+S` to save*

## Tech Stack

| Technology | Usage |
|------------|-------|
| **Swift 5.10** | Primary language |
| **SwiftUI** | Declarative UI framework |
| **SwiftData** | Data persistence (iOS 17+) |
| **Swift Charts** | Data visualization |
| **HealthKit** | Health data integration |
| **WidgetKit** | Home screen widgets |
| **AVFoundation** | Barcode scanning |

## Architecture

```
IronPath/
├── Models/                    # SwiftData models
│   ├── Core/                  # UserProfile, DailySummary, StreakData
│   ├── Workout/               # Workout, Exercise, WorkoutSet
│   └── Nutrition/             # FoodItem, LoggedFood, Recipe
├── Views/                     # SwiftUI views by feature
│   ├── Dashboard/
│   ├── Workout/
│   ├── Nutrition/
│   ├── Reports/
│   ├── Profile/
│   └── Onboarding/
├── Services/                  # Business logic
│   ├── IntegrationEngine      # Recovery scores, smart suggestions
│   ├── NutritionService       # Food logging, API integration
│   ├── WorkoutManager         # Workout session management
│   ├── HealthKitManager       # Apple Health sync
│   └── NotificationManager    # Local notifications
├── Components/                # Reusable UI components
│   ├── Common/                # Cards, buttons, empty states
│   ├── Workout/               # Exercise rows, rest timer
│   └── Nutrition/             # Food rows
├── Theme/                     # Design system
│   ├── Colors
│   ├── Typography
│   ├── CardStyles
│   └── ButtonStyles
└── Utilities/                 # Helpers
    ├── FormatHelpers
    └── HapticManager
```

### Data Flow

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│   SwiftUI View  │────▶│     Service      │────▶│   SwiftData    │
│  (Presentation) │     │  (Business Logic)│     │  (Persistence)  │
└─────────────────┘     └──────────────────┘     └─────────────────┘
         │                       │                        │
         │                       ▼                        │
         │              ┌──────────────────┐              │
         │              │  IntegrationEngine│              │
         │              │  (Correlations)   │              │
         │              └──────────────────┘              │
         │                       │                        │
         └───────────────────────┴────────────────────────┘
                    HealthKit / Widgets / Notifications
```

## Getting Started

### Requirements
- iOS 17.0+
- Xcode 15.0+

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/IronPath.git
cd IronPath
```

2. Open in Xcode:
```bash
open IronPath/IronPath.xcodeproj
```

3. Build and run (`Cmd + R`)

### Widget Setup (Optional)

To enable widgets:
1. Add the Widget Extension target in Xcode
2. Configure App Groups for both targets
3. See `IronPathWidget/WIDGET_SETUP.md` for details

### Testing

```bash
# Run all tests
xcodebuild test -scheme IronPath -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Key Implementation Details

### Recovery Score Algorithm
```swift
recoveryScore = (sleepFactor * 0.4) + (proteinFactor * 0.35) + (restFactor * 0.25)
```
- **Sleep Factor**: Percentage of sleep goal achieved
- **Protein Factor**: Percentage of protein target hit
- **Rest Factor**: Days since last workout (48hrs = fully rested)

### BMR Calculation (Mifflin-St Jeor)
```swift
// Male: BMR = 10*weight(kg) + 6.25*height(cm) - 5*age + 5
// Female: BMR = 10*weight(kg) + 6.25*height(cm) - 5*age - 161
// Then multiply by activity level (1.2 - 1.9)
```

### Progressive Overload Detection
The app tracks when you hit 8+ reps at the same weight for 3 consecutive sessions, then suggests increasing weight by 5 lbs.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Nutrition data powered by [Open Food Facts](https://world.openfoodfacts.org/)
- Icons from SF Symbols
- Inspired by apps like Cronometer, MacroFactor, and Stronger

---

<p align="center">
  Made with ❤️ by Gabriel Hollenbeck
</p>
