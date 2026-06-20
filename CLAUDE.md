# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## ⚠️ 必須ワークフロー / Definition of Done（最初に読むこと）

コードを変更したら、**コミット前に必ず以下を全て実施する**（テストとドキュメント更新の漏れ防止。ユーザーの明示要望 2026-06-20）:

1. **ビルド確認** — アプリ＋ウィジェット両ターゲットがコンパイルできること（`-scheme DayTracer` のビルドで両方ビルドされる）。
2. **テスト実行** — `xcodebuild test`（下記 Testing 参照）。失敗は直すか、直せない場合は明示的に報告する。
3. **`docs/overview.md` を更新** — 挙動・画面・データモデル・依存・既知の課題に変化があれば反映し、冒頭の「最終更新」日を更新する。
4. **`docs/worklog.md` に追記** — 1作業ごとに「日付／やったこと／検証結果／コミット」を1エントリ追記する。
5. **既知の課題表を更新** — 新しいバグ・設計課題を見つけたら `docs/overview.md` の課題表に追記。解消したら印を付ける。
6. **`CLAUDE.md` を同期** — 高レベルなアーキテクチャ変更があれば本ファイルも更新する。

> これは「省略可」ではない。コミット前チェックリストとして毎回確認すること。

## Project Overview

DayTracer is an iOS SwiftUI application that tracks time progress throughout the day, month, and year. The app features a main dashboard showing real-time progress bars, a notes section for diary entries, and customizable widgets for the iOS home screen.

### Key Technologies
- **SwiftUI**: Primary UI framework
- **SwiftData**: Core Data successor for local data persistence
- **WidgetKit**: iOS home screen widgets with multiple sizes (small, medium, large)
- **Firebase**: Authentication (Google Sign-In) and backend services
- **App Groups**: Shared data between main app and widget extension (`group.junkyfly.daytracer.notes`)

## Documentation Maintenance (IMPORTANT)

- The repository keeps a living spec at `docs/overview.md` describing the app's *intent* (what/why), screen structure, data flow, and known tech debt.
- **Whenever you change code in a way that affects behavior, screens, data model, dependencies, or known issues, update `docs/overview.md` in the same change.** Bump its "最終更新" date.
- When you discover a new bug or design issue, add it to the "既知の課題 / 技術的負債" table in `docs/overview.md` rather than only mentioning it in chat.
- Maintain a running work log in `docs/worklog.md` — append one entry per change (date, summary, verification result, commit hash). Newest entry on top.
- Keep this `CLAUDE.md` in sync when the high-level architecture changes.

## Testing

- Unit tests live in `DayTracerTests/`. `ProgressCalculators` is covered in `DayTracerTests/DayTracerTests.swift`.
- Run tests with: `xcodebuild test -project DayTracer.xcodeproj -scheme DayTracer -destination 'platform=iOS Simulator,name=iPhone 15'` (adjust the simulator name to one that is installed; iOS 17.0 runtime is available).
- When adding a *new* test file, it must be added to the `DayTracerTests` target in Xcode (drag into the test target) — creating the file on disk alone will NOT register it in `project.pbxproj`, so the tests will silently not run.
- Prefer testing pure logic (like `ProgressCalculators`). Build dates with `Calendar.current` inside tests so they are timezone-stable.

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