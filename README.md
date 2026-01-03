# ran. 🏃‍♂️

A **comic book-styled iOS running app** that gamifies your fitness journey. Track runs, earn achievements, compete with friends, and level up your runner avatar.

![iOS 17+](https://img.shields.io/badge/iOS-17.0+-000000?style=flat&logo=apple)
![Swift 5.9](https://img.shields.io/badge/Swift-5.9-FA7343?style=flat&logo=swift)
![SwiftUI](https://img.shields.io/badge/SwiftUI-blue?style=flat&logo=swift)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=flat&logo=firebase&logoColor=black)

---

## 📖 What is ran.?

**ran.** is a fitness tracking app with a unique **comic book / zine aesthetic**. Instead of boring stats screens, you get:

- 🎨 **Bold comic-style UI** with ink borders, halftone patterns, and action panels
- 🏆 **Gamification** — earn XP, level up, unlock achievements
- 👥 **Squad system** — challenge friends, track streaks, send nudges
- 🗺️ **Mission system** — complete running challenges for rewards
- ✨ **iOS 26 Liquid Glass** — uses the native `.glassEffect()` API on supported devices

---

## 🏗️ Project Structure

```
MyRunningApp/
├── Sources/MyRunningApp/
│   ├── ContentView.swift          # App entry point (@main)
│   ├── Core/                      # Core utilities & managers
│   │   ├── RanColors.swift        # Color system (light/dark mode)
│   │   ├── HealthManager.swift    # HealthKit integration
│   │   └── FirebaseManager.swift  # Auth & Firestore operations
│   ├── Navigation/
│   │   └── NavigationViews.swift  # Tab bar & main navigation
│   ├── Shared/
│   │   └── Components.swift       # Reusable UI components
│   └── Features/                  # Feature modules
│       ├── Authentication/        # Login/signup flows
│       ├── Welcome/               # Onboarding wizard
│       ├── Run/                   # Active run tracking + history
│       ├── Mission/               # Running challenges
│       ├── Rewards/               # Achievements & trophies
│       ├── Squad/                 # Friends & social features
│       └── Profile/               # User profile & customization
├── Package.swift                  # Swift Package Manager config
└── MyRunningApp.xcodeproj/        # Xcode project
```

---

## 🔧 Tech Stack

| Component | Technology |
|-----------|------------|
| **UI Framework** | SwiftUI |
| **Min iOS Version** | iOS 17.0 |
| **Backend** | Firebase (Auth + Firestore) |
| **Health Data** | HealthKit |
| **Location** | CoreLocation |
| **Motion** | CoreMotion |

---

## 🚀 Getting Started

### Prerequisites

- **Xcode 15+** (for iOS 17 SDK)
- **macOS Sonoma 14+** recommended
- **Apple Developer Account** (for HealthKit capabilities)
- **Firebase Project** with iOS app configured

### Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/ran.git
   cd ran/MyRunningApp
   ```

2. **Open in Xcode**
   ```bash
   open MyRunningApp.xcodeproj
   ```

3. **Configure Firebase**
   - Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
   - Add an iOS app with bundle ID: `com.dann.ran`
   - Download `GoogleService-Info.plist` and replace the existing one in `Sources/MyRunningApp/`

4. **Build & Run**
   - Select your device/simulator
   - Press `Cmd+R` to build and run

---

## 🎨 Design System

### RanColors

The app uses a centralized color system that adapts to light/dark mode:

```swift
let colors = RanColors(scheme: colorScheme)

colors.ink     // Text color (black/white)
colors.paper   // Background
colors.panel   // Card backgrounds
colors.accent  // Yellow highlights
colors.action  // Red CTAs
colors.sky     // Blue accents
```

### Comic Panel Modifier

Apply the signature comic book look to any view:

```swift
Text("POW!")
  .comicPanel(color: colors.accent, ink: colors.ink)
```

---

## 📱 Features Overview

### 1. Run Tracking
- Real-time GPS tracking with route visualization
- HealthKit integration for heart rate, calories, distance
- Pace calculation and performance metrics
- Run history with map playback

### 2. Missions
- Daily/weekly running challenges
- XP rewards for completion
- Progress tracking with visual indicators

### 3. Squad (Social)
- Add friends via invite codes
- Direct duel streaks (mutual accountability)
- Squad missions (collaborative goals)
- Activity feed & nudge system

### 4. Achievements
- Milestone badges (5K, 10K, marathon)
- Streak achievements
- Special event trophies

### 5. Profile & Customization
- Avatar color selection
- Character lab for personalization
- Stats overview (total distance, workouts, streaks)

---

## 📂 Key Files Explained

| File | Purpose |
|------|---------|
| `ContentView.swift` | App entry, contains `@main` |
| `NavigationViews.swift` | Tab bar, main container, auth flow routing |
| `RanColors.swift` | Color palette + HapticManager |
| `HealthManager.swift` | HealthKit queries, workout saving, live tracking |
| `FirebaseManager.swift` | Auth, Firestore CRUD, run data sync |
| `Components.swift` | Reusable components (ComicPanel, SpeedLines, etc.) |

---

## 🔐 Firebase Data Model

```
Firestore Structure:
└── agents/
    └── {userId}/
        ├── displayName: String
        ├── inviteCode: String
        ├── stats: { totalDistance, totalWorkouts, currentStreak }
        ├── preferences: { runnerType, avatarColor, weeklyGoal }
        └── runs/ (subcollection)
            └── {runId}/
                ├── date: Timestamp
                ├── distance: Number (km)
                ├── duration: Number (seconds)
                ├── pace: Number (min/km)
                ├── calories: Number
                ├── averageHeartRate: Number
                └── pathCoordinates: [{ lat, lng }]
```

---

## ⚙️ Build Configurations

| Config | Purpose |
|--------|---------|
| **Debug** | Development builds, verbose logging |
| **Release** | Production builds, optimized |

The app uses these entitlements:
- `com.apple.developer.healthkit` — HealthKit access
- Background location updates for run tracking

---

## 🧪 Testing

Currently, the app relies on manual testing:

1. **Onboarding Flow** — Verify welcome wizard completes
2. **Run Tracking** — Start/stop run, verify data saves
3. **Social Features** — Add friend via code, verify connection
4. **Offline Mode** — Test Firestore offline persistence

---

## 🎯 iOS 26 Features

The app includes iOS 26-specific features:
- **Liquid Glass Tab Bar** using `.glassEffect(.regular.interactive())`
- Falls back to comic-style tab bar on iOS < 26

---

## 📄 License

This project is private. All rights reserved.

---

## 🤝 Contributing

1. Create a feature branch: `git checkout -b feature/amazing-feature`
2. Commit changes: `git commit -m 'Add amazing feature'`
3. Push to branch: `git push origin feature/amazing-feature`
4. Open a Pull Request

---

**Built with ❤️ and SwiftUI**
