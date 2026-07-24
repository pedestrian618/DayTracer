//
//  NotesView.swift
//  DayTracer
//
//  使途記録: 削られた1日（年の約0.27%）を何に使ったかを1行で残す。
//  保存は SwiftData ローカル（Firestore 依存は 2026-07-24 撤去）。
//  制約: 30文字上限・1日1件。投稿時に App Group へ最新記録を書き、ウィジェットへ反映する。
//

import SwiftUI
import SwiftData
import WidgetKit

// MARK: - Date Extension
extension Date {
    /// 表示設定（日付・時刻形式）に従ったタイムスタンプ文字列。
    func formatted() -> String {
        return AppSettings.dateTimeString(from: self)
    }

    func isSameDay(as otherDate: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: otherDate)
    }
}

// MARK: - Notes View
struct NotesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DiaryRecord.date, order: .reverse) private var records: [DiaryRecord]

    @State private var newDiaryText: String = ""
    @FocusState private var isTextFieldFocused: Bool

    /// 「短い記録」を保つための1件あたりの最大文字数。
    private let maxNoteLength = 30

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if records.isEmpty {
                    emptyState
                } else {
                    recordList
                }
                inputArea
            }
            .background(DS.Colors.panel.ignoresSafeArea())
            .navigationTitle("使途記録")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var recordList: some View {
        List {
            ForEach(records) { record in
                VStack(alignment: .leading, spacing: 4) {
                    Text(record.text)
                        .font(DS.Fonts.body)
                        .foregroundStyle(DS.Colors.numeral)
                    HStack {
                        Text(record.date.formatted())
                        Spacer()
                        Text(String(format: "= 年の%.2f%%",
                                    ProgressCalculators.dayWeightOfYear(for: record.date) * 100))
                    }
                    .font(DS.Fonts.caption)
                    .foregroundStyle(DS.Colors.label)
                }
                .listRowBackground(DS.Colors.surface)
            }
            .onDelete(perform: deleteRecords)
        }
        .scrollContentBackground(.hidden)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Spacer()
            Text("まだ記録がありません")
                .font(DS.Fonts.body)
                .foregroundStyle(DS.Colors.numeral)
            Text("1日1行、30文字。その日を何に使ったかだけ残す。")
                .font(DS.Fonts.caption)
                .foregroundStyle(DS.Colors.label)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - 入力エリア（短い記録の制約つき）
    private var inputArea: some View {
        VStack(spacing: 4) {
            HStack {
                TextField(todayPrompt, text: $newDiaryText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.vertical, 8)
                    .focused($isTextFieldFocused)
                    .disabled(hasPostedToday)
                    .onChange(of: newDiaryText) { _, newValue in
                        // 文字数上限を超えたら切り詰める（短い記録の制約）
                        if newValue.count > maxNoteLength {
                            newDiaryText = String(newValue.prefix(maxNoteLength))
                        }
                    }

                Button(action: addNewRecord) {
                    Text("記録")
                        .font(DS.Fonts.caption)
                        .foregroundStyle(DS.Colors.panel)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(DS.Colors.remaining)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .disabled(newDiaryText.isEmpty || hasPostedToday)
            }

            HStack {
                if hasPostedToday {
                    Text("今日の分は記録済み")
                        .font(DS.Fonts.caption)
                        .foregroundStyle(DS.Colors.label)
                }
                Spacer()
                Text("\(newDiaryText.count)/\(maxNoteLength)")
                    .font(DS.Fonts.caption)
                    .foregroundStyle(newDiaryText.count >= maxNoteLength ? DS.Colors.remaining : DS.Colors.label)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }

    /// 入力プロンプト: 今日が年に占める重みを添えて問いかける。
    private var todayPrompt: String {
        String(format: "今日は年の%.2f%%。何に使った？",
               ProgressCalculators.dayWeightOfYear(for: Date()) * 100)
    }

    // MARK: - CRUD

    private func addNewRecord() {
        modelContext.insert(DiaryRecord(text: newDiaryText))
        newDiaryText = ""
        isTextFieldFocused = false
        syncLatestToWidget()
    }

    private func deleteRecords(at offsets: IndexSet) {
        offsets.forEach { modelContext.delete(records[$0]) }
        syncLatestToWidget()
    }

    /// 1日1件の制約: 最新記録の日付が今日なら true。
    private var hasPostedToday: Bool {
        guard let latest = records.first else { return false }
        return latest.date.isSameDay(as: Date())
    }

    /// App Group の共有コンテナへ最新記録を書き、ウィジェットのタイムラインを更新する。
    /// modelContext から直接引くので、直前の insert / delete も反映される。
    private func syncLatestToWidget() {
        var descriptor = FetchDescriptor<DiaryRecord>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        descriptor.fetchLimit = 1
        let latest = (try? modelContext.fetch(descriptor))?.first
        SharedNoteStore().saveLatestNote(text: latest?.text ?? "",
                                         date: latest.map { $0.date.formatted() } ?? "")
        WidgetCenter.shared.reloadAllTimelines()
    }
}
