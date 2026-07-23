# DayTracer 仕様概要

> このドキュメントは「コードを読めば分かること」ではなく、**何を・なぜ作っているか**（意図）を残すためのものです。
> コードを変更したら、関連する記述をここも更新してください（運用ルールは `CLAUDE.md` 参照）。

最終更新: 2026-07-23

---

## 1. アプリ概要

DayTracer は、**「残り時間の計器盤」**。1日・1週・1ヶ月・1年の時間が刻一刻と削られていく様子をリアルタイムに可視化する iOS アプリ。

- **コンセプト（2026-07-23 再定義）**: ターゲットは「生き急いでいる人・意識の高い人」。表示の主軸は経過率ではなく**残量**（「残り 44.5786%」「残り163日 04:12:08」）。小数点以下まで常に動き続ける数字で、時間が失われていく焦りを演出する。
- **世界観**: ダークな計器盤。ほぼ黒の盤面＋白の等幅数字＋差し色1色（アンバー＝残り時間）。姉妹アプリ masume（紙とインク・ゆるさ）と意図的に対極を張る。
- **ノートの位置づけ**: 単なる日記ではなく**「使途記録」**——削られたその1日（年の約0.27%）を何に使ったかの記録。ノートを使わなくても本体（残量表示）は完結する。

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
- **HomeView（2026-07-23 全面刷新）**: ダーク計器盤。構成は上から (1) 時計（秒はアンバー）、(2) ヒーロー＝年の残り%（小数6桁、`TimelineView(.animation)` で約20fps駆動）＋「残り◯日 hh:mm:ss」カウントダウン＋残量バー、(3) DAY/WEEK/MONTH の残量バー（小数4桁）、(4) 365日グリッド `YEAR IN DAYS`（記録した日=アンバー、過ぎた日=暗色、今日=白、未来=輪郭のみ。記録日数と分母も表示）、(5) 使途記録（最新3件。各記録に「= 年の0.27%」の重みスタンプ）。常時駆動が必要な区画だけを `TimelineView` 配下に置き、グリッド・記録一覧は再描画しない。`ContentView` でアプリ全体を `preferredColorScheme(.dark)` に固定。
- **NotesView**: Firestore コレクション `diaryEntries` に対して CRUD。投稿時に最新ノートを App Group の共有コンテナへ保存（ウィジェット連携用）。
- **SettingsView**: `AuthenticationManager.shared` を監視。未ログイン時は `LoginView`、ログイン時は `UserSettingsView`（メール表示・サインアウト）。加えて「表示」セクションで週の始まり・日付/時刻形式を設定（`AppSettings`、アプリ・ウィジェット共通）。

---

## 3. データと永続化

3系統が混在している（歴史的経緯）:

1. **SwiftData (`Item`)** — `DayTracerApp` で `ModelContainer` を構築。スキーマは `Item`（`timestamp: Date`）のみ。**現状ほぼ未使用**（プレビューと初期テンプレートの名残）。
2. **Firestore (`diaryEntries`)** — 日記の本体。`{ text, date: Timestamp, userId }`。`userId` で絞り込み、`date` 降順で取得。
3. **App Group 共有 UserDefaults** — `group.junkyfly.daytracer.notes`。キー `latestNoteText` / `latestNoteDate` に最新ノートを保存し、ウィジェットへ受け渡す。**アクセスは `SharedConfig`（suite 名・キー名）と `SharedNoteStore`（read/write）に集約**され、アプリ・ウィジェット両ターゲットで共有（Phase 2）。表示設定（週の始まり・日付/時刻形式）も同じ共有 UserDefaults に `AppSettings` 経由で保存し、両ターゲットが参照（2026-06-21）。

---

## 4. 認証

- `AuthenticationManager`（シングルトン, `ObservableObject`）が Firebase Auth の状態を保持。
- Google サインイン（`GoogleSignIn`）→ Firebase クレデンシャルに変換してログイン。
- `AppDelegate` で `FirebaseApp.configure()` と URL ハンドリング。

---

## 5. ウィジェット

- 別ターゲット `DayTracerWidgets/`。小・中・大の3サイズ。2026-07-23 に「残量の計器盤」へ全面刷新（ダーク盤面固定）。
- **常時駆動の仕組み**: `Text(timerInterval:countsDown:)`（今日の残り時間が毎秒カウントダウン）と `ProgressView(timerInterval:countsDown:)`（今日の残量バーが連続的に減っていく）は **タイムライン更新なしで OS が描画し続ける**（iOS 16+）。これが「ウィジェットでも常に動き続ける」演出の中核。期間は `ProgressCalculators.dayInterval(for:)` で進捗計算と同じ境界を渡す。
- 年の残り%（小数4桁）は従来どおり `Provider` の毎分タイムライン更新で刻む（毎分 約0.0002% 動くので4桁目が毎分変わる）。
- 小: YEAR残り%＋残量バー / DAY残りカウントダウン＋システム駆動バー。中: 時計＋YEAR＋DAY。大: 時計＋YEAR＋DAY/WEEK/MONTH＋最新の使途記録＋「今日を記録する」。
- タップ/リンクで `daytracer://notes` → Notes タブ（`AppRouter` + `.onOpenURL`）。
- ロック画面ウィジェット（円形/長方形/インライン）は「残り」表記に反転（例: `Day残42% · Year残45%`）。

---

## 6. 進捗計算ロジック（`ProgressCalculators`）

純粋な計算（副作用なし）。`Calendar.current` 基準。

- `calculateDayProgress(for:)` — 当日 0:00 からの経過率。
- `calculateWeekProgress(for:calendar:)` — 週初めからの経過率。`calendar`（既定 `.current`）で週の始まりを指定でき、`AppSettings` の設定を反映できる。
- `calculateMonthProgress(for:)` — 月初からの経過率。
- `calculateYearProgress(for:)` — 年初からの経過率。
- **期間ヘルパー（2026-07-23 追加）**: `dayInterval` / `weekInterval` / `monthInterval` / `yearInterval` — ウィジェットの `timerInterval` 系 API に渡す `DateInterval`。進捗計算と同じ境界を返す。
- **「残り」表示ヘルパー（同上）**: `remainingTimeOfYear`（年末まで 日/時/分/秒）、`dayOfYear` / `daysInYear`（365日グリッド用）、`dayWeightOfYear`（1日が年に占める重み。使途記録の「= 年の0.27%」表示用）。

戻り値は基本 0.0〜1.0。**テスト対象**（`DayTracerTests`）。

---

## 6.5 デザインシステム（`DesignTokens.swift` / 2026-07-23 導入）

masume の運用（単一トークン enum＋リテラル禁止）を輸入し、世界観は対極に振った。

- `enum DS { Colors / Fonts / Metrics }` に色・フォント・寸法を集約。**View にリテラルの色・フォントサイズを書かない**（新規コードはトークン経由で指定する）。
- **アプリ・ウィジェット両ターゲットでソース共有**（`project.pbxproj` の両 Sources に登録）し、盤面の世界観を統一。
- パレット: `panel`（ほぼ黒の盤面）/ `surface` / `line` / `numeral`（白い数字）/ `label`（グレー補助）/ **`remaining`（アンバー＝唯一の差し色。「残り時間」にだけ使う）** / `spent`（消費済み）/ `hatch`（斜線）。
- フォント: 数字は全て等幅（`DS.Fonts.numeral(size:weight:)`）。桁が動き続けてもガタつかない。用途別トークン（hero / countdown / barValue / sectionLabel / clock ほか）。
- 共有コンポーネント（`ProgressViews.swift`）: `DrainBarView`（消費済み側を暗い斜線ハッチ、残量側だけアンバーに光らせるバー）、`StripedPattern`（Canvas による45°斜線）。旧 `CustomLinearProgressGradientView` / `CustomCircleProgressGradientView` は全用途が置き換わったため削除。

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
| 9 | **2026-07-23 のUI刷新はビルド・テスト未実行** — 実装環境（Linux）に Xcode/Swift が無く `xcodebuild` を実行できなかった。特に `project.pbxproj` の手編集（`DesignTokens.swift` 登録）と `timerInterval` 系 API の実機描画は要確認。 | コンパイル・表示の未検証 | **高** |
| 10 | **ウィジェットの色設定（AppIntent）が新デザインで未使用** — 計器盤はアンバー単色になったため `selectedColor` / `selectedSubColor` が表示に反映されない。設定UIだけ残っている。選択肢をアクセント色差し替えとして再接続するか、設定ごと削除するか要判断。 | 設定が効かない | 中 |
| 11 | **WelcomeView / NotesView / SettingsView が新世界観に未追随** — ダーク固定にはなるが、トークン（DS）未適用でトーンが揃っていない。文言も英日混在のまま。 | 世界観の不統一 | 中 |
| 12 | **365日グリッドの「今日」が日付跨ぎで自動更新されない** — グリッドは `onAppear` 時の日付で描画（毎フレーム再描画を避けるため）。0時を跨いだら再表示まで前日のまま。 | 表示のズレ（軽微） | 低 |

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

### Quick wins（2026-06-20）

- ダークモード対応: `HomeView` のノートカード/背景をシステム色（`secondarySystemGroupedBackground` / `systemGroupedBackground`）へ。白カードの浮きを解消。
- 短い日記の制約: `NotesView` に「30文字上限」「1日1投稿（`hasPostedToday`）」＋文字数カウンタを追加（削除した `DiaryView` の意図を移植）。
- 週進捗: `ProgressCalculators.calculateWeekProgress` を追加し、`HomeView` に Week バーを表示。テスト2件追加（計10件）。
- ロック画面ウィジェット: 円形/長方形/インラインの3種に対応（`supportedFamilies` 拡張＋`Gauge` 表示）。
- 検証: 両ターゲット ビルド成功 / テスト10件合格（実機での表示は要確認）。

### 表示設定 / i18n（2026-06-21）

- `AppSettings`（新規・両ターゲット共有）で「週の始まり」「日付形式（数字順 / 月名 / 曜日つき の6種）」「時刻形式(12/24h)」を App Group の UserDefaults に保存。
- Settings に「表示」セクション（3 Picker）を追加。変更時に `WidgetCenter.reloadAllTimelines()` でウィジェットへ反映。
- 適用: `HomeView`（日付・時計・週進捗）、`NotesView`/`DiaryEntryView`（タイムスタンプ）、ウィジェット（時刻表示）。`ProgressCalculators.calculateWeekProgress` に `calendar` 引数を追加。
- 検証: 両ターゲット ビルド成功 / テスト11件合格（週の firstWeekday テストを追加）。実機での反映は要確認。

## 8. 制約・注意点

- **依存は Xcode 15.0 世代にピン留め**: Firebase 10.18.0 / GoogleSignIn 7.0.0 等。Xcode で「Update to Latest Package Versions」を実行すると Xcode 15.0 で弾かれる恐れがあるため避ける。
- リンカ警告 `ignoring duplicate libraries: '-lc++', '-lsqlite3', '-lz'` は Xcode 15 + SPM の既知の無害な警告。

---

## 9. 今後の改善候補（メモ）

- **保存方式の方針（要検討・本人の希望）**: 「オフラインファースト＋任意ログイン」を目指す。ログインなしでもローカルに保存して使え、ログインすればバックアップ＆複数端末同期になる構成。現状は日記が Firestore 必須（未ログインだと保存・表示できない）。ローカル層（SwiftData `Item` の活用 / App Group）＋ Firestore 同期の二層構成が候補。課題 #7 とも関連。
- 課題 #7: ほぼ未使用の SwiftData `Item` の扱い（日記を寄せる or 削除）を決める。
- ~~**「短い日記」の仕様を `NotesView` に取り込む**~~ — ✅ 2026-06-20 実装（30文字上限・1日1投稿・文字数カウンタ）。次の候補は気分（emoji）タグ・編集/検索・カレンダー表示。
- **NotesView を「使途記録」として刷新**: 入力プロンプトを「今日は年の0.27%。何に使った？」に、DS トークン適用、記録率（経過日のうち記録できた日の割合）の表示。ホームの365日グリッドとの往復導線。
- **ゴール/デッドライン機能**: ユーザー定義の目標日（試験日・四半期末など）への残量バーを日/週/月/年と同じ視覚言語で追加。「焦り」を自分の締切に接続する。
- 課題 #10: ウィジェットの色設定（AppIntent）の再接続 or 削除。
- 演出の磨き込み: 今日セルのパルス、`accessibilityReduceMotion` での駆動停止（masume の規律を踏襲）。
- テスト拡充: 現在は `ProgressCalculators` のみ。認証やノート CRUD は要モック設計。
- UI ローカライズ: 英語ラベルと日本語が混在。コピーのトーン（非敬体・短文）統一と String Catalog 化。
