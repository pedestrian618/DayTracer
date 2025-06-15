# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

DayTracer is an iOS SwiftUI application that tracks time progress throughout the day, month, and year. The app features a main dashboard showing real-time progress bars, a notes section for diary entries, and customizable widgets for the iOS home screen.

### Key Technologies
- **SwiftUI**: Primary UI framework
- **SwiftData**: Core Data successor for local data persistence
- **WidgetKit**: iOS home screen widgets with multiple sizes (small, medium, large)
- **Firebase**: Authentication (Google Sign-In) and backend services
- **App Groups**: Shared data between main app and widget extension (`group.junkyfly.daytracer.notes`)

## Architecture

### Core App Structure
- **DayTracerApp.swift**: Main app entry point with Firebase configuration and welcome screen logic
- **ContentView.swift**: Tab-based navigation container (Home, Notes, Settings)
- **Item.swift**: SwiftData model for persistent storage

### Main Views
- **HomeView.swift**: Dashboard displaying real-time progress calculations and latest notes
- **NotesView.swift**: Diary/notes management interface
- **WelcomeView.swift**: Initial onboarding screen
- **SettingsView.swift**: App configuration

### Progress System
- **ProgressCalculators.swift**: Centralized logic for calculating day/month/year progress percentages
- **ProgressViews.swift**: Custom SwiftUI components for linear and circular progress bars with gradient support

### Widget Extension
- **DayTracerWidgets/**: Separate target for iOS home screen widgets
- **DayTracerWidgets.swift**: Main widget configuration and timeline provider
- **DayTracerWidgetsSmallView.swift, DayTracerWidgetsMediumView.swift, DayTracerWidgetsLargeView.swift**: Size-specific widget layouts
- **AppIntent.swift**: Widget configuration intents for user customization

## Development Commands

### Building and Running
```bash
# Build the project (use Xcode)
xcodebuild -project DayTracer.xcodeproj -scheme DayTracer build

# Run tests
xcodebuild test -project DayTracer.xcodeproj -scheme DayTracer -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Widget Development
Widgets are built as a separate extension target and require:
- Shared App Group for data persistence between main app and widgets
- Timeline providers for automatic widget updates
- Size-specific view implementations

## Key Development Notes

### Shared Data Between App and Widgets
- Uses App Groups with identifier `group.junkyfly.daytracer.notes`
- Widget timeline updates every minute via `Provider` class
- Latest notes are shared via UserDefaults in the shared container

### Progress Calculations
- All progress calculations are handled by `ProgressCalculators` utility class
- Real-time updates occur every second in HomeView via Timer.publish
- Progress values are between 0.0 and 1.0

### Custom UI Components
- Gradient-enabled progress bars (both linear and circular)
- Custom color theming system with `DayTracerBlue` brand color
- Translucent navigation and tab bars with custom appearance

### Firebase Integration
- Google Sign-In authentication configured in AppDelegate
- Firebase configuration occurs in application launch
- Authentication state managed through AuthenticationManager.swift