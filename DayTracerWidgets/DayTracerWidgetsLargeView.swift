//
//  DayTracerWidgetsLargeView.swift
//  DayTracerWidgetsExtension
//
//  大ウィジェット: 計器盤のフル表示。年ヒーロー＋日/週/月の残量バー＋最新の使途記録。
//

import SwiftUI
import WidgetKit

struct DayTracerWidgetsLargeView: View {
    var entry: Provider.Entry

    var body: some View {
        let yearRemaining = (1 - entry.yearProgress) * 100
        let dayInterval = ProgressCalculators.dayInterval(for: entry.date)
        let weekProgress = ProgressCalculators.calculateWeekProgress(for: entry.date, calendar: AppSettings.calendar)
        let remaining = ProgressCalculators.remainingTimeOfYear(for: entry.date)

        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(AppSettings.timeString(from: entry.date))
                        .font(DS.Fonts.numeral(30))
                        .foregroundStyle(DS.Colors.numeral)
                    Text(entry.date.formattedAsDayMonthDate())
                        .font(DS.Fonts.date)
                        .foregroundStyle(DS.Colors.label)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("YEAR 残り")
                        .font(DS.Fonts.sectionLabel)
                        .foregroundStyle(DS.Colors.label)
                    Text(String(format: "%.4f%%", yearRemaining))
                        .font(DS.Fonts.numeral(24))
                        .foregroundStyle(DS.Colors.remaining)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Text("残り \(remaining.days)日")
                        .font(DS.Fonts.sectionLabel)
                        .foregroundStyle(DS.Colors.label)
                }
            }

            DrainBarView(progress: entry.yearProgress)
                .frame(height: DS.Metrics.barHeightThin)

            // DAY はシステム駆動のカウントダウンとバーで毎秒動き続ける
            HStack(spacing: 8) {
                Text("DAY 残り")
                    .font(DS.Fonts.sectionLabel)
                    .foregroundStyle(DS.Colors.label)
                Text(timerInterval: dayInterval.start...dayInterval.end, countsDown: true)
                    .font(DS.Fonts.numeral(15))
                    .foregroundStyle(DS.Colors.numeral)
                    .lineLimit(1)
                    .frame(width: 84, alignment: .leading)
                ProgressView(timerInterval: dayInterval.start...dayInterval.end, countsDown: true) {
                } currentValueLabel: {
                }
                .progressViewStyle(.linear)
                .tint(DS.Colors.remaining)
            }

            drainRow(label: "WEEK", progress: weekProgress)
            drainRow(label: "MONTH", progress: entry.monthProgress)

            Spacer(minLength: 4)

            // 最新の使途記録
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("使途記録")
                        .font(DS.Fonts.sectionLabel)
                        .foregroundStyle(DS.Colors.label)
                    Spacer()
                    Text(entry.latestNoteDate)
                        .font(DS.Fonts.caption)
                        .foregroundStyle(DS.Colors.label)
                }
                Text(entry.latestNoteText.isEmpty ? "まだ記録がありません" : entry.latestNoteText)
                    .font(DS.Fonts.body)
                    .foregroundStyle(DS.Colors.numeral)
                    .lineLimit(2)
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(DS.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: DS.Metrics.cardCorner))

            Link(destination: URL(string: "daytracer://notes")!) {
                HStack(spacing: 6) {
                    Image(systemName: "pencil.line")
                    Text("今日を記録する")
                        .font(DS.Fonts.caption)
                }
                .foregroundStyle(DS.Colors.remaining)
            }
        }
    }

    private func drainRow(label: String, progress: Double) -> some View {
        HStack(spacing: 8) {
            Text(label)
                .font(DS.Fonts.sectionLabel)
                .foregroundStyle(DS.Colors.label)
                .frame(width: 44, alignment: .leading)
            DrainBarView(progress: progress)
                .frame(height: DS.Metrics.barHeightThin)
            Text(String(format: "%.4f%%", (1 - progress) * 100))
                .font(DS.Fonts.numeral(12, weight: .semibold))
                .foregroundStyle(DS.Colors.numeral)
                .frame(width: 76, alignment: .trailing)
        }
    }
}
