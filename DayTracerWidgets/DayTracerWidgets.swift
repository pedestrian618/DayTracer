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
        SimpleEntry(date: Date())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date())
    }
    // Providerのtimelineメソッド内でSimpleEntryを作成する際に、yearProgressも計算して初期化します。
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []

        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let yearProgress: Double
    let dayProgress: Double

    // 日付を基にしてイニシャライザ内で年間の進捗を計算する
    init(date: Date) {
            self.date = date
            self.yearProgress = ProgressCalculators.calculateYearProgress(for: date)
            self.dayProgress = ProgressCalculators.calculateDayProgress(for: date)
    }
}


struct DayTracerWidgetsEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var widgetFamily

    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            DayTracerWidgetsSmallView(entry: entry)
        case .systemMedium:
            DayTracerWidgetsMediumView(entry: entry)
        default:
            DayTracerWidgetsSmallView(entry: entry)
        }
//        VStack {
//            Text("Time:")
//            Text(entry.date, style: .time)
//            
//            Text("Year Progress:")
//            ProgressView(value: entry.yearProgress)
//                .progressViewStyle(LinearProgressViewStyle())
//                .scaleEffect(x: 1, y: 2, anchor: .center) // オプションでプログレスバーのスタイルを調整
//        }
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




//extension ConfigurationAppIntent {
//    fileprivate static var smiley: ConfigurationAppIntent {
//        let intent = ConfigurationAppIntent()
//        intent.favoriteEmoji = "😀"
//        return intent
//    }
//    
//    fileprivate static var starEyes: ConfigurationAppIntent {
//        let intent = ConfigurationAppIntent()
//        intent.favoriteEmoji = "🤩"
//        return intent
//    }
//}

#Preview(as: .systemSmall) {
    DayTracerWidgets()
} timeline: {
    SimpleEntry(date: .now)
    SimpleEntry(date: .now)
}
