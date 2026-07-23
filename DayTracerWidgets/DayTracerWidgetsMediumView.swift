//
//  DayTracerWidgetsMidiumView.swift
//  DayTracerWidgetsExtension
//
//  中ウィジェット: 時計＋年の残り%＋今日の残りカウントダウン（毎秒、システム駆動）。
//

import SwiftUI
import WidgetKit

struct DayTracerWidgetsMediumView: View {
    var entry: Provider.Entry

    var body: some View {
        let yearRemaining = (1 - entry.yearProgress) * 100
        let dayInterval = ProgressCalculators.dayInterval(for: entry.date)
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(AppSettings.timeString(from: entry.date))
                        .font(DS.Fonts.numeral(28))
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
                        .font(DS.Fonts.numeral(22))
                        .foregroundStyle(DS.Colors.remaining)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            }

            DrainBarView(progress: entry.yearProgress)
                .frame(height: DS.Metrics.barHeightThin)

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

                Link(destination: URL(string: "daytracer://notes")!) {
                    Image(systemName: "pencil.line")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(DS.Colors.remaining)
                }
            }
        }
    }
}

extension Date {
    func formattedAsDayMonthDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE MMMM d" // 「短縮曜日 月 日」のフォーマット
        return dateFormatter.string(from: self)
    }
}
