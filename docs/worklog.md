# 作業ログ (Work Log)

DayTracer の作業履歴。**新しい作業を上に追記**する（逆時系列）。
1エントリの形式: 日付 ／ 概要 ／ 詳細 ／ 検証 ／ コミット。

運用ルールは [CLAUDE.md](../CLAUDE.md) の「必須ワークフロー / Definition of Done」を参照。

---

## 2026-07-04

### 活動時間（日バーのユーザー定義）
- **概要**: 日の進捗バーを、深夜0時固定ではなくユーザー指定の「活動時間」窓で進むように変更。「生活時間帯と%が合わず気持ち悪い」を解消。
- **詳細**:
  - モデル: 日バーは 0時から切り離し、開始時刻でリセット → 長さ（`end-start`）で 0→100% → 次の開始まで 100% 張り付き。25:00（翌1:00）等の翌日跨ぎ対応。月/年/週/ノート所属日は 0:00 基準のまま（日バーだけ非整合を許容）。デフォルト 0:00・24h は従来と完全一致。
  - `ProgressCalculators.calculateDayProgress` に `startMinutes`/`endMinutes`/`calendar`（既定値つきで後方互換）を追加。窓 = `end-start`、`min(max(elapsed/span,0),1)` でクランプ＝張り付きが自然に出る。
  - `AppSettings`: `dayStartMinutes`/`dayEndMinutes`（App Group 共有、未設定は 0/1440）＋ 窓口 `dayProgress(for:)`。`HomeView`・ウィジェット timeline を窓口経由に統一（「日の境界」を1箇所に集約）。
  - `SettingsView`: 「活動時間」セクション。開始 DatePicker ＋ 長さ Picker（1–24h）で保持し `end-start<=24h` を構造的に保証。終了時刻はキャプション表示（翌日跨ぎ・24:00 を明示）。変更時 `reloadAllTimelines()`。
  - テスト追加（`DayTracerTests`）: デフォルト窓＝レガシー一致 / 07:00→25:00 窓 / 06:00→22:00 クランプ / 不正窓で 0。
- **検証**: 両ターゲット ビルド成功 / 単体16件＋UIテスト合格。実機での見え方は要確認。
- **コミット**: 91bb432

---

## 2026-06-21

### ホーム上部（ヘッダー）のリファイン
- **概要**: HomeView 上部の「ごちゃつき」を解消し、洗練された印象に。プログレスバー下段は据え置き。
- **詳細**:
  - 原因整理: 書体3種（rounded/monospaced/default）混在・サイズ4段・青が2か所（秒と円）・フル日付が大きすぎて3〜4行に折返し・全数値が小数2桁。
  - 変更（`headerSection`）: カード化（`secondarySystemGroupedBackground`・角丸16）／書体を `.rounded` に統一／日付は15pt `.secondary` の1行（`lineLimit(1)`＋`minimumScaleFactor`）／時刻を主役（48pt）・秒は `.secondary` の添え字でベースライン揃え（旧 `.offset` 廃止）／青アクセントは日進捗の円のみ＋「Today」ラベル。
  - コンセプト維持: 日進捗だけ小数3桁（`%.3f`）＋`monospacedDigit` で、最後の桁がほぼ毎秒進む“オドメーター”表示（桁幅固定で揺れない）。動かない週/月/年バーは整数%に丸め＋`.rounded`/`monospacedDigit`。
- **検証**: 両ターゲット ビルド成功 / `ProgressCalculatorsTests` 11件＋UIテスト合格。実機での見え方は要確認。
- **コミット**: c2f6c16

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
