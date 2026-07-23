//
//  DayTracerSmallView.swift
//  DayTracer
//
//  小ウィジェット: 年の残り%（毎分更新）＋ 今日の残り時間（毎秒、システム駆動）。
//  Text(timerInterval:) / ProgressView(timerInterval:) はタイムライン更新なしで
//  システム側が動かし続けるため、「常に削られている」演出ができる。
//

import WidgetKit
import SwiftUI

struct DayTracerWidgetsSmallView: View {
    var entry: Provider.Entry

    var body: some View {
        let yearRemaining = (1 - entry.yearProgress) * 100
        let dayInterval = ProgressCalculators.dayInterval(for: entry.date)
        VStack(alignment: .leading, spacing: 4) {
            Text("YEAR 残り")
                .font(DS.Fonts.sectionLabel)
                .foregroundStyle(DS.Colors.label)
            Text(String(format: "%.4f%%", yearRemaining))
                .font(DS.Fonts.numeral(19))
                .foregroundStyle(DS.Colors.remaining)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            DrainBarView(progress: entry.yearProgress)
                .frame(height: DS.Metrics.barHeightThin)

            Spacer(minLength: 8)

            Text("DAY 残り")
                .font(DS.Fonts.sectionLabel)
                .foregroundStyle(DS.Colors.label)
            Text(timerInterval: dayInterval.start...dayInterval.end, countsDown: true)
                .font(DS.Fonts.numeral(17))
                .foregroundStyle(DS.Colors.numeral)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            ProgressView(timerInterval: dayInterval.start...dayInterval.end, countsDown: true) {
            } currentValueLabel: {
            }
            .progressViewStyle(.linear)
            .tint(DS.Colors.remaining)
        }
        .widgetURL(URL(string: "daytracer://notes"))
    }
}
