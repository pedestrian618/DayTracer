# DayTracer 仕様概要

> このドキュメントは「コードを読めば分かること」ではなく、**何を・なぜ作っているか**（意図）を残すためのものです。
> コードを変更したら、関連する記述をここも更新してください（運用ルールは `CLAUDE.md` 参照）。

最終更新: 2026-06-20

---

## 1. アプリ概要

DayTracer は、1日・1ヶ月・1年の「経過率」をリアルタイムに可視化する iOS アプリ。
ダッシュボードに進捗バーを表示し、日記（ノート）を記録でき、ホーム画面ウィジェットでも進捗を確認できる。

- 対象: iOS 17.0 以上（`IPHONEOS_DEPLOYMENT_TARGET = 17.0`）
- 言語/UI: Swift 5 / SwiftUI
- 開発環境: Xcode 15.0（依存は当時のバージョンにピン留め。下記「制約」参照）

---

## 2. 画面構成

起動フロー: `DayTracerApp` → `WelcomeView`（スプラッシュ）→ `ContentView`（タブ）

`ContentView` は3タブの `TabView`:

| タブ | View | 役割 |
|---|---|---|
| Home | `HomeView` | 日付・現在時刻、日/月/年の進捗、最新ノート一覧 |
| Notes | `NotesView` | 日記の閲覧・投稿・削除（Firestore 連携） |
| Settings | `SettingsView` | サインイン状態の表示、Google サインイン / サインアウト |

### 各画面の意図
- **WelcomeView**: `welcomeImage` を約1.5秒表示してフェードアウトするスプラッシュ。`showWelcomeScreen` バインディングで `ContentView` に遷移。
- **HomeView**: 1秒ごとの `Timer.publish` で時刻と進捗を更新。日進捗は円形ゲージ、年/月進捗は横バー。最新ノートは `DiaryRepository`（Firestore）から最新3件を取得して表示。
- **NotesView**: Firestore コレクション `diaryEntries` に対して CRUD。投稿時に最新ノートを App Group の共有コンテナへ保存（ウィジェット連携用）。
- **SettingsView**: `AuthenticationManager.shared` を監視。未ログイン時は `LoginView`、ログイン時は `UserSettingsView`（メール表示・サインアウト）。

---

## 3. データと永続化

3系統が混在している（歴史的経緯）:

1. **SwiftData (`Item`)** — `DayTracerApp` で `ModelContainer` を構築。スキーマは `Item`（`timestamp: Date`）のみ。**現状ほぼ未使用**（プレビューと初期テンプレートの名残）。
2. **Firestore (`diaryEntries`)** — 日記の本体。`{ text, date: Timestamp, userId }`。`userId` で絞り込み、`date` 降順で取得。
3. **App Group 共有 UserDefaults** — `group.junkyfly.daytracer.notes`。キー `latestNoteText` / `latestNoteDate` に最新ノートを保存し、ウィジェットへ受け渡す。**アクセスは `SharedConfig`（suite 名・キー名）と `SharedNoteStore`（read/write）に集約**され、アプリ・ウィジェット両ターゲットで共有（Phase 2）。

---

## 4. 認証

- `AuthenticationManager`（シングルトン, `ObservableObject`）が Firebase Auth の状態を保持。
- Google サインイン（`GoogleSignIn`）→ Firebase クレデンシャルに変換してログイン。
- `AppDelegate` で `FirebaseApp.configure()` と URL ハンドリング。

---

## 5. ウィジェット

- 別ターゲット `DayTracerWidgets/`。小・中・大の3サイズ。
- `Provider`（Timeline Provider）が毎分更新。
- App Group 経由で最新ノートと進捗を表示。
- 「Take Notes」ボタン（中・大）と小ウィジェットのタップで `daytracer://notes` を開き、アプリの Notes タブへ遷移（`AppRouter` + `.onOpenURL`）。

---

## 6. 進捗計算ロジック（`ProgressCalculators`）

純粋な計算（副作用なし）。`Calendar.current` 基準。

- `calculateDayProgress(for:)` — 当日 0:00 からの経過率。
- `calculateMonthProgress(for:)` — 月初からの経過率。
- `calculateYearProgress(for:)` — 年初からの経過率。

戻り値は基本 0.0〜1.0。**テスト対象**（`DayTracerTests`）。

---

## 7. 既知の課題 / 技術的負債

> 2026-06-20 時点でコードを精査して確認した内容。優先度は目安。

| # | 内容 | 影響 | 優先度 |
|---|---|---|---|
| 1 | ~~**`DiaryView.swift` が孤立**~~ — ✅ Phase 1（2026-06-20）で削除済。「短い日記」向けロジックは下記 §9 に記録。 | 混乱の元。死にコード | ✅ 解消 |
| 2 | ~~**HomeView の「Latest Notes」がモック**~~ — ✅ Phase 3 で実データ化。`DiaryRepository` 経由で Firestore から最新3件を取得。 | 表示が常にダミー | ✅ 解消 |
| 3 | ~~**ノートのモデルが2系統**~~ — ✅ Phase 3 で `Note`（モック）を廃止し `DiaryEntry` に一本化。 | 整合性・保守性 | ✅ 解消 |
| 4 | **WelcomeView が毎起動で表示** — `showWelcomeScreen` が `@State` 初期値 `true` で永続化なし。スプラッシュとしては許容だが意図の明確化が必要。 | 仕様判断待ち | 低 |
| 5 | ~~**コメントアウト済みの旧コード**~~ — ✅ Phase 1 で除去済（ContentView/DayTracerApp/Widgets/AppIntent ほか）。 | 可読性 | ✅ 解消 |
| 6 | ~~**強制アンラップ** が `AuthenticationManager.googleAuth()`~~ — ✅ 2026-06-20 に `windows.first!`/`rootViewController!` を `guard` 化。 | クラッシュ要因 | ✅ 解消 |
| 7 | **SwiftData(`Item`) がほぼ未使用** — 役割が定まっていない。日記を SwiftData に寄せるか、削除するか要判断。 | 設計の宙ぶらりん | 中 |
| 8 | ~~**Settings がログイン済みでも「Sign in to continue」表示**~~ — ✅ 2026-06-20 解消。認証状態のソースが2系統に分かれていた（Notes/Home は `currentUser` 直接、Settings は別フラグ）。`AuthenticationManager` を起動時に `currentUser` から即時反映するよう修正。 | サインイン状態の誤表示 | ✅ 解消 |

---

## 7.5 整理ログ（Phase 1 / 2026-06-20）

リスクゼロの掃除を実施（アプリ・ウィジェット両ターゲットのビルド成功＋テスト合格を確認）:

- 削除: `DiaryView.swift`（孤立・ビルド対象外）、`SwiftUIView.swift`（"Hello, World!" の雛形）
- 削除: 未使用の `CustomLinearProgressView` / `CustomCircleProgressView`（非グラデ版、参照ゼロ）
- 除去: `ContentView` / `DayTracerApp` / `DayTracerWidgets` / `AppIntent` / Medium・Large View のコメントアウト済み旧コード、重複ヘッダ、未使用変数 `currentMonth`

→ 課題 #1・#5 は解消。

### Phase 2: 依存の集約（2026-06-20）

- 新規: `SharedConfig.swift`（App Group の suite 名・キー名を集約）、`SharedNoteStore.swift`（最新ノートの read/write をラップ）。`project.pbxproj` を編集し、アプリ・ウィジェット両ターゲットに登録。
- 差し替え: `NotesView`（書く側）と `Provider`（読む側）のベタ書き `UserDefaults` アクセスを共有コードに統一。文字列の二重管理を解消。
- 検証: 両ターゲット ビルド成功 / テスト8件合格。

### Phase 3: 機能のつながり（2026-06-20）

- ディープリンク: ウィジェットの「Take Notes」/ 小ウィジェットのタップ → `daytracer://notes` → Notes タブへ。`AppRouter`（新規）と `DayTracerApp.onOpenURL`、各ウィジェットの `Link` / `.widgetURL` で実現（URLスキームは Info.plist に登録済みだった）。
- HomeView 実データ化: モックの `Note` を廃止し、`DiaryRepository`（新規・Firestore アクセス集約）で最新3件を表示。`NotesView` の一覧取得も同リポジトリに統一。
- LiveActivity 削除: 未使用の絵文字テンプレ（`DayTracerWidgetsLiveActivity.swift`）をファイル・pbxproj・`WidgetBundle` 登録ごと削除。
- 検証: 両ターゲット ビルド成功 / テスト8件合格（実行時のタップ遷移・Firestore 取得は要シミュレータ確認）。

### 認証状態の修正（2026-06-20）

- 症状: Firestore のノートは読めている（＝ Firebase 的にはサインイン済み）のに、Settings は「Sign in to continue」のまま。
- 原因: 認証状態のソースが2系統 —— Notes/Home は `Auth.auth().currentUser` を直接参照、Settings は別フラグ `AuthenticationManager.isSignedIn` を参照しており、後者が実態と同期しきれていなかった。
- 修正: `AuthenticationManager` が起動時に `currentUser` から状態を即時反映するようにし、`AppDelegate` で起動時にリスナーを有効化。あわせて `googleAuth()` の強制アンラップを `guard` 化（課題 #6）。
- 検証: 両ターゲット ビルド成功 / テスト8件合格（実機での Settings 表示は要確認）。

## 8. 制約・注意点

- **依存は Xcode 15.0 世代にピン留め**: Firebase 10.18.0 / GoogleSignIn 7.0.0 等。Xcode で「Update to Latest Package Versions」を実行すると Xcode 15.0 で弾かれる恐れがあるため避ける。
- リンカ警告 `ignoring duplicate libraries: '-lc++', '-lsqlite3', '-lz'` は Xcode 15 + SPM の既知の無害な警告。

---

## 9. 今後の改善候補（メモ）

- **保存方式の方針（要検討・本人の希望）**: 「オフラインファースト＋任意ログイン」を目指す。ログインなしでもローカルに保存して使え、ログインすればバックアップ＆複数端末同期になる構成。現状は日記が Firestore 必須（未ログインだと保存・表示できない）。ローカル層（SwiftData `Item` の活用 / App Group）＋ Firestore 同期の二層構成が候補。課題 #7 とも関連。
- 課題 #7: ほぼ未使用の SwiftData `Item` の扱い（日記を寄せる or 削除）を決める。
- **「短い日記」の仕様を `NotesView` に取り込む**: 削除した `DiaryView.swift`（git 履歴に残存）が持っていた「1投稿あたり30文字制限」「1日1投稿（`hasPostedToday`）」は "短い日記" というアプリの狙いに合致。`NotesView` への移植を検討。
- テスト拡充: 現在は `ProgressCalculators` のみ。認証やノート CRUD は要モック設計。
