//
//  SettingsView.swift
//  DayTracer
//
//  表示設定（アプリ・ウィジェット共通）。
//  認証・アカウント機能は 2026-07-24 の Firebase 撤去で削除した。
//  データはローカル保存（iCloud バックアップで端末移行）。CloudKit 同期は今後の候補。
//

import SwiftUI
import WidgetKit

struct SettingsView: View {
    @AppStorage(AppSettings.Keys.weekStart, store: SharedConfig.defaults) private var weekStart: WeekStart = .system
    @AppStorage(AppSettings.Keys.timeFormat, store: SharedConfig.defaults) private var timeFormat: TimeFormatOption = .system
    @AppStorage(AppSettings.Keys.dateStyle, store: SharedConfig.defaults) private var dateStyle: DateStyleOption = .system

    var body: some View {
        NavigationStack {
            List {
                // 表示設定（アプリ・ウィジェット共通）
                Section(header: Text("表示 / Display")) {
                    Picker("週の始まり", selection: $weekStart) {
                        ForEach(WeekStart.allCases) { Text($0.label).tag($0) }
                    }
                    Picker("時刻の表示", selection: $timeFormat) {
                        ForEach(TimeFormatOption.allCases) { Text($0.label).tag($0) }
                    }
                    Picker("日付の表示", selection: $dateStyle) {
                        ForEach(DateStyleOption.allCases) { Text($0.label).tag($0) }
                    }
                }

                Section(header: Text("データ"), footer: Text("使途記録はこの端末に保存されます。iCloudバックアップ／端末間転送で新しい端末へ引き継がれます。")) {
                    LabeledContent("保存先", value: "この端末（ローカル）")
                }
            }
            .navigationTitle("Settings")
            .onChange(of: weekStart) { _, _ in reloadWidgets() }
            .onChange(of: timeFormat) { _, _ in reloadWidgets() }
            .onChange(of: dateStyle) { _, _ in reloadWidgets() }
        }
    }

    /// 設定変更をウィジェットへ反映する。
    private func reloadWidgets() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}
