# 作業ログ (Work Log)

DayTracer の作業履歴。**新しい作業を上に追記**する（逆時系列）。
1エントリの形式: 日付 ／ 概要 ／ 詳細 ／ 検証 ／ コミット。

運用ルールは [CLAUDE.md](../CLAUDE.md) の「必須ワークフロー / Definition of Done」を参照。

---

## 2026-06-20

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
- **任意**: 削除済み `DiaryView` が持っていた「30文字制限・1日1投稿」を `NotesView` へ移植（短い日記の強化）。
- **任意**: ほぼ未使用の SwiftData `Item` の扱いを決める（課題 #7）。
- 実機/シミュレータで、ディープリンク遷移と HomeView の実データ表示を動作確認。
