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

DayTracer is an iOS SwiftUI application that visualizes time being spent — a "remaining-time instrument panel" for people who live with urgency. The main dashboard shows the **remaining** percentage of the year (6 decimal places, continuously ticking), remaining bars for day/week/month, a 365-day year grid, and a "使途記録" (time-spend log, formerly notes). Widgets use `Text(timerInterval:)` / `ProgressView(timerInterval:)` so they keep moving every second without timeline reloads.

**Design system**: `DayTracer/DesignTokens.swift` (`enum DS { Colors / Fonts / Metrics }`) is shared by both targets. Do NOT write literal colors/font sizes in views — go through DS tokens. Palette is a dark panel + white monospaced numerals + one amber accent used only for "remaining time". Sister app masume (paper/ink, soft) is deliberately the opposite pole.

### Key Technologies
- **SwiftUI**: Primary UI framework
- **SwiftData**: Core Data successor for local data persistence
- **WidgetKit**: iOS home screen widgets with multiple sizes (small, medium, large)
- **App Groups**: Shared data between main app and widget extension (`group.junkyfly.daytracer.notes`)
- **No external packages**: Firebase / Firestore / GoogleSignIn were fully removed on 2026-07-24. Apple frameworks only. Do not re-introduce third-party dependencies casually.

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
- **DayTracerApp.swift**: Main app entry point; builds the SwiftData `ModelContainer` (schema: `DiaryRecord`) and handles the `daytracer://notes` deep link
- **ContentView.swift**: Tab-based navigation container (Home, Notes, Settings), locked to dark mode
- **DiaryRecord.swift**: SwiftData model for the time-spend log (local storage; CloudKit-compatible design, sync not yet enabled)

### Main Views
- **HomeView.swift**: The instrument panel — remaining-year hero number, drain bars, 365-day grid, latest log entries (via `@Query`)
- **NotesView.swift**: Time-spend log CRUD via SwiftData (`@Query` + `modelContext`); 30-char limit, one entry per day; syncs the latest entry to the App Group and reloads widget timelines
- **WelcomeView.swift**: Initial onboarding screen
- **SettingsView.swift**: Display settings (week start, date/time format) shared with widgets; no auth

### Progress System
- **ProgressCalculators.swift**: Centralized logic for day/week/month/year progress, plus `DateInterval` helpers (`dayInterval` etc.) for widget `timerInterval` APIs and "remaining" helpers (`remainingTimeOfYear`, `dayOfYear`, `daysInYear`, `dayWeightOfYear`)
- **ProgressViews.swift**: Shared drain-style components — `DrainBarView` (spent side dark + hatched, remaining side amber) and `StripedPattern` (45° Canvas hatch)
- **DesignTokens.swift**: `enum DS` design tokens (colors/fonts/metrics), shared with the widget target

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
- HomeView drives continuous updates with `TimelineView` (clock at 1s, hero number/bars at ~20fps); widgets use system-driven `timerInterval` APIs
- Progress values are between 0.0 and 1.0

### Custom UI Components
- Drain-style progress bars (`DrainBarView`): remaining time glows amber, spent time is dark with a hatched texture
- All styling goes through `DS` design tokens (`DesignTokens.swift`); the app is locked to dark mode (`preferredColorScheme(.dark)` in ContentView) with amber as the single accent/tint
- Numerals are always monospaced so continuously ticking digits don't shift layout

### Data & Persistence
- Diary/log entries live in SwiftData (`DiaryRecord`) with CloudKit private-database sync (container `iCloud.com.junkyfly.DayTracer`); works offline / signed-out as plain local storage
- No authentication anywhere — the app must remain fully usable without any account
- CloudKit constraints on `DiaryRecord`: every property needs a default value, no unique constraints
- Before any TestFlight/App Store build: deploy schema changes to Production in the CloudKit Console (issue #15 in `docs/overview.md`)