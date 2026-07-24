# 作業ログ (Work Log)

DayTracer の作業履歴。**新しい作業を上に追記**する（逆時系列）。
1エントリの形式: 日付 ／ 概要 ／ 詳細 ／ 検証 ／ コミット。

運用ルールは [CLAUDE.md](../CLAUDE.md) の「必須ワークフロー / Definition of Done」を参照。

---

## 2026-07-24

### フェーズ3: CloudKit 同期の有効化
- **概要**: 使途記録（SwiftData `DiaryRecord`）に CloudKit private database 同期を追加。ログイン UI なしのまま、iCloud サインイン中の端末間で自動同期・自動復元になる。
- **詳細**:
  - コンテナ `iCloud.com.junkyfly.DayTracer` を Xcode から登録（本人作業。初回は名前末尾の混入スペースで登録に失敗 → 手打ちで再登録して解消）。
  - 両 entitlements（`DayTracer.entitlements` / `DayTracerDebug.entitlements`）の `icloud-container-identifiers` にコンテナ ID を追加。
  - `DayTracerApp`: `ModelConfiguration` に `cloudKitDatabase: .private("iCloud.com.junkyfly.DayTracer")` を指定。
  - `Info.plist`: `UIBackgroundModes: remote-notification` を再追加（CloudKit のサイレントプッシュ受信用。Firebase 撤去時に削除していたもの）。
  - `SettingsView` のデータ説明を「この端末 + iCloud」に更新。
- **検証**: 未実施（Linux 環境、課題 #9 と同様）。Mac で要確認: Debug ビルド → 記録を1件保存 → CloudKit Console の Development 環境に `CD_DiaryRecord` レコード型が生成されること → 可能なら2台目端末で同期確認。**リリース前に Production へのスキーマデプロイ必須（課題 #15・新規）**。
- **コミット**: （このエントリと同じコミット）

### フェーズ2: Firebase 依存の全撤去（オフラインファースト化）
- **概要**: Firebase / Firestore / GoogleSignIn を依存ごと削除し、使途記録を SwiftData ローカル保存へ移行。ログイン概念を廃止し、外部パッケージ依存ゼロに。実機ビルドで出ていた gRPC-C++ の `CFBundleIdentifier` エラーも依存撤去により根治。
- **詳細**:
  - 新規 `DiaryRecord.swift`（SwiftData モデル、CloudKit 互換設計）。旧 `Item.swift` を置き換え（課題 #7 解消）。
  - 削除: `AuthenticationManager.swift` / `DiaryRepository.swift`（Firestore 版）/ `LoginView` / `UserSettingsView` / `ProfileImageView` / AppDelegate（Firebase 初期化・GIDSignIn URL 処理）。
  - `NotesView` 刷新: `@Query` + `modelContext` で CRUD、DS トークン適用、プロンプト「今日は年の◯%。何に使った？」。投稿/削除時に `SharedNoteStore` へ最新記録を書き `WidgetCenter.reloadAllTimelines()`。
  - `HomeView`: `DiaryRepository` 経由の取得を `@Query` に置き換え（最新3件と365日グリッドの記録日）。
  - `SettingsView`: 認証セクション削除、「データ」セクション（ローカル保存の説明）を追加。
  - `DayTracerApp`: Firebase/GoogleSignIn 起動コード削除、スキーマを `DiaryRecord` に変更、`.modelContainer()` を WindowGroup に付与（従来は未注入だった）。
  - `project.pbxproj`: firebase-ios-sdk / GoogleSignIn-iOS のパッケージ参照・プロダクト依存・Frameworks エントリ・GoogleService-Info.plist 参照を全削除。
  - `Info.plist`: Google URL スキームと `UIBackgroundModes: remote-notification` を削除。
  - 注意: 旧 Firestore 上の記録は移行していない（課題 #13）。CloudKit 同期は未有効化（課題 #14）。
- **検証**: **未実施**（Linux 環境に Xcode なし、課題 #9 と同様）。Mac で要確認: 両ターゲットビルド → テスト19件 → 投稿/削除→ウィジェット反映、既存インストールからのアップデートで SwiftData ストアが正常に開くこと。
- **コミット**: （このエントリと同じコミット）

### UI・プロダクト再設計フェーズ1: 「残り時間の計器盤」化
- **概要**: コンセプトを「経過率の表示」から「残量（残り時間）の計器盤」へ再定義し、ホーム画面とウィジェット全サイズを刷新。masume のデザイン運用（単一トークン enum・リテラル禁止・両ターゲット共有）を輸入しつつ、世界観は対極（ダーク盤面・等幅数字・アンバー単色）に振った。
- **詳細**:
  - `DesignTokens.swift`（新規・両ターゲット共有、`project.pbxproj` 手編集で登録）: `DS.Colors / Fonts / Metrics`。
  - `ProgressViews.swift`: `DrainBarView`（消費済み=暗い斜線ハッチ、残量=アンバー）と `StripedPattern` に刷新。旧グラデーションバー/リングは全用途置き換えのため削除。
  - `HomeView` 全面書き換え: ヒーロー=年の残り%（小数6桁、`TimelineView(.animation)` 約20fps）＋「残り◯日 hh:mm:ss」、DAY/WEEK/MONTH 残量バー（小数4桁）、365日グリッド（記録日=アンバー/経過=暗色/今日=白/未来=輪郭）、使途記録（各記録に「= 年の0.27%」の重み）。
  - `ContentView`: 旧ブルーテーマの UIAppearance を削除、`preferredColorScheme(.dark)` 固定＋アンバー tint。
  - ウィジェット3サイズ刷新: `Text(timerInterval:)` / `ProgressView(timerInterval:countsDown:)` で今日の残りをタイムライン更新なしに毎秒駆動。ロック画面3種は「残り」表記へ反転。盤面色の `containerBackground`。
  - `ProgressCalculators`: `dayInterval/weekInterval/monthInterval/yearInterval`、`remainingTimeOfYear`、`dayOfYear/daysInYear/dayWeightOfYear` を追加（テスト8件追加、計19件）。
- **検証**: **未実施（要注意）**。実装環境（リモートLinux）に Xcode/Swift ツールチェーンが無く、`xcodebuild` によるビルド・テストを実行できなかった。次に Mac で開く際に必ず: 両ターゲットのビルド → テスト19件 → シミュレータでホーム/ウィジェット表示（特に `timerInterval` 系の描画と pbxproj 登録）を確認すること（課題 #9）。
- **コミット**: （このエントリと同じコミット）

## 2026-06-21

### 表示設定（週の始まり・日付/時刻形式）
- **概要**: グローバル対応として、表示形式を Settings で設定可能に（アプリ・ウィジェット共通）。
- **詳細**:
  - `AppSettings`（App Group 共有・両ターゲット）を新規作成し、「週の始まり」「日付形式」「時刻形式(12/24h)」を保存。`SharedConfig.defaults` を追加。
  - Settings に「表示」セクション（3 Picker）＋変更時の `WidgetCenter.reloadAllTimelines()`。
  - 日付形式は6種: 数字順（YMD/MDY/DMY）＋月名つき（`June 20, 2026`）＋曜日つき（`Friday, June 20, 2026`）＋システム。Picker ラベルはサンプル日付を端末ロケールで整形して実例表示。
  - 適用: `HomeView`（日付・時計・週進捗）、`NotesView`（タイムスタンプ）、ウィジェット（時刻）。`calculateWeekProgress` に `calendar` 引数を追加（テスト1件追加、計11件）。
  - 関数シグネチャ変更でビルドのインクリメンタル不整合が発生 → DerivedData の該当中間生成物を削除して解消（コードは正常）。
- **検証**: 両ターゲット ビルド成功 / `ProgressCalculatorsTests` 11件合格。実機での反映は要確認。
- **コミット**: （このエントリと同じコミット）

## 2026-06-20

### Quick wins（ダークモード・短い日記・週進捗・ロック画面ウィジェット）
- **概要**: 低コストで完成度と"らしさ"を上げる4点。
- **詳細**:
  - ダークモード対応: `HomeView` の白カード/背景をシステム色に。
  - 短い日記の制約: `NotesView` に 30文字上限・1日1投稿・文字数カウンタ。
  - 週進捗: `ProgressCalculators.calculateWeekProgress` 追加＋`HomeView` に Week バー＋テスト2件。
  - ロック画面ウィジェット: 円形/長方形/インラインの3種（`supportedFamilies` 拡張・`Gauge`）。
- **検証**: 両ターゲット ビルド成功 / `ProgressCalculatorsTests` 10件合格。実機表示は要確認。
- **コミット**: （このエントリと同じコミット）

### 認証状態のバグ修正（Settings のサインイン表示）
- **概要**: 実機テストで「ログイン済みなのに Settings がサインイン画面のまま」を発見し修正。
- **詳細**:
  - 原因: 認証状態のソースが2系統（Notes/Home は `Auth.auth().currentUser` 直接、Settings は `AuthenticationManager.isSignedIn`）で、後者が同期不足だった。
  - 修正: `AuthenticationManager` を起動時に `currentUser` から即時反映＋ `AppDelegate` で起動時にリスナー有効化。`googleAuth()` の強制アンラップも `guard` 化（課題 #6）。
- **検証**: 両ターゲット ビルド成功 / `ProgressCalculatorsTests` 8件合格。実機での Settings 表示は要確認。
- **コミット**: （このエントリと同じコミット）

### Phase 3（一部）: 機能のつながり（ディープリンク・実データ化）
- **概要**: ウィジェット→アプリのディープリンクと、HomeView のモック→実データ化。
- **詳細**:
  - `AppRouter`（タブ選択を保持）を追加し、`DayTracerApp` の `.onOpenURL` で `daytracer://notes` を Notes タブへ。ウィジェットは「Take Notes」を `Link`、小サイズに `.widgetURL` を付与（URLスキームは Info.plist に登録済みだった）。
  - `DiaryRepository`（Firestore アクセス集約）を新規作成しアプリターゲットに登録。`HomeView` のモック `Note` を廃止し最新3件を実データ表示。`NotesView` の一覧取得も同リポジトリに統一。
  - 未使用の `LiveActivity`（絵文字テンプレ）を削除（ファイル・pbxproj・`WidgetBundle` 登録）。
- **検証**: 両ターゲット ビルド成功 / `ProgressCalculatorsTests` 8件合格。実行時の挙動（タップ遷移・Firestore 取得）は要シミュレータ確認。
- **コミット**: （このエントリと同じコミット）

### Phase 2: 依存の集約（App Group 共通化）
- **概要**: 散らばっていた App Group の文字列を1箇所に集約し、アプリ↔ウィジェットの結合を明確化。
- **詳細**:
  - 新規 `SharedConfig.swift`（suite 名・キー名）、`SharedNoteStore.swift`（最新ノートの read/write）を作成。
  - `project.pbxproj` を手編集し、両ターゲット（アプリ＋ウィジェット拡張）に登録。
  - `NotesView`（書く側）・`Provider`（読む側）のベタ書き `UserDefaults` を共有コードに差し替え。
- **検証**: `plutil -lint` OK / 両ターゲット ビルド成功 / `ProgressCalculatorsTests` 8件合格。
- **コミット**: （このエントリと同じコミット）

### Phase 1: コード整理（掃除）
- **概要**: 久々の開発再開にあたり、つぎはぎで増えたデッドコードを一掃。
- **詳細**:
  - 孤立ファイル削除: `DiaryView.swift`・`SwiftUIView.swift`（どちらもビルド対象外）
  - 未使用の非グラデ進捗ビュー2つを削除（`CustomLinearProgressView` / `CustomCircleProgressView`）
  - コメントアウト済み旧コード・重複ヘッダ・未使用変数 `currentMonth` を除去（アプリ＋ウィジェット）
- **検証**: アプリ＋ウィジェット両ターゲット ビルド成功 / `ProgressCalculatorsTests` 8件合格。
- **コミット**: `6b7b350`（`origin/feature/claudecode` に push 済み）

### ドキュメント・テスト基盤の整備
- **概要**: AI協働のための土台づくり。
- **詳細**:
  - `docs/overview.md` を新規作成（仕様概要・依存・既知の課題）
  - `ProgressCalculators` の単体テストを追加（Xcode テンプレを置換）
  - `CLAUDE.md` にドキュメント保守・テストの規約、および必須ワークフローを追記
- **検証**: テスト合格。
- **コミット**: `6b7b350` ほか

### 環境確認
- Xcode 15.0 / iOS 17.0 シミュレーター / 依存は Firebase 10.18.0 等にピン留め。
- 最新化は保留（Xcode 16.4 は macOS Sequoia 必須、現状は Sonoma 14.6.1）。SPM の「Update to Latest」は実行しないこと。

### 次の予定
- **次フェーズ: ウィジェット強化** — インタラクティブWidgetでクイック投稿（iOS17）、StandBy 対応、本物の Live Activity（拡張マトリクスの ⑥/⑩）。
- **任意**: 短い日記の更なる強化（気分タグ・編集/検索・カレンダー表示）。
- **任意**: ほぼ未使用の SwiftData `Item` の扱いを決める（課題 #7）。
- 実機/シミュレータで各機能を動作確認（ダークモード・短い日記・週進捗・ロック画面ウィジェット・表示設定の反映）。
- **要検討（重要）**: 保存方式の方針 = オフラインファースト＋任意ログイン（バックアップ/同期）。詳細は overview.md §9。
