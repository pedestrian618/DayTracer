//
//  DayTracerWidgets.swift
//  DayTracerWidgets
//　ウィジェットのビューとロジックを定義するファイルです
//  Created by murate on 2023/11/19.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    // Providerの関数では、SimpleEntryの新しいイニシャライザを使用します。
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration)
    }
    // Providerのtimelineメソッド内でSimpleEntryを作成する際に、yearProgressも計算して初期化します。
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []

        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }
}

//struct SimpleEntry: TimelineEntry {
//    let date: Date
//    let configuration: ConfigurationAppIntent
//    let yearProgress: Double // 年間の経過割合を追加
//}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let yearProgress: Double

    // 日付を基にしてイニシャライザ内で年間の進捗を計算する
    init(date: Date, configuration: ConfigurationAppIntent) {
        self.date = date
        self.configuration = configuration
        self.yearProgress = SimpleEntry.calculateYearProgress(for: date)
    }

    // 年間の進捗を計算するヘルパーメソッドを静的メソッドとしてSimpleEntryに移動
    static func calculateYearProgress(for date: Date) -> Double {
        let yearStart = Calendar.current.date(from: Calendar.current.dateComponents([.year], from: date))!
        let yearEnd = Calendar.current.date(from: Calendar.current.dateComponents([.year], from: Calendar.current.date(byAdding: .year, value: 1, to: date)!))!
        let totalDays = Calendar.current.dateComponents([.day], from: yearStart, to: yearEnd).day!
        let elapsedDays = Calendar.current.dateComponents([.day], from: yearStart, to: date).day!
        return Double(elapsedDays) / Double(totalDays)
    }
}


struct DayTracerWidgetsEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text("Time:")
            Text(entry.date, style: .time)
            
            Text("Year Progress:")
                        ProgressView(value: entry.yearProgress)
                            .progressViewStyle(LinearProgressViewStyle())
                            .scaleEffect(x: 1, y: 2, anchor: .center) // オプションでプログレスバーのスタイルを調整

            Text("Favorite Emoji:")
            Text(entry.configuration.favoriteEmoji)
        }
    }
}

struct DayTracerWidgets: Widget {
    let kind: String = "DayTracerWidgets"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            DayTracerWidgetsEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
    }
}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "😀"
        return intent
    }
    
    fileprivate static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "🤩"
        return intent
    }
}

#Preview(as: .systemSmall) {
    DayTracerWidgets()
} timeline: {
    SimpleEntry(date: .now, configuration: .smiley)
    SimpleEntry(date: .now, configuration: .starEyes)
}
