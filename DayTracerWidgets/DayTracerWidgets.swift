//
//  DayTracerWidgets.swift
//  DayTracerWidgets
//　ウィジェットのビューとロジックを定義するファイルです
//  Created by murate on 2023/11/19.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    
    // 共有 UserDefaults から最新のノートを取得するためのヘルパー関数
    func getLatestNote() -> (text: String, date: String) {
        let sharedDefaults = UserDefaults(suiteName: "group.junkyfly.daytracer.notes")
        let text = sharedDefaults?.string(forKey: "latestNoteText") ?? "No Note.Let’s take your diary"
        let date = sharedDefaults?.string(forKey: "latestNoteDate") ?? ""
        return (text, date)
    }
    
    // Providerの関数では、SimpleEntryの新しいイニシャライザを使用します。
    func placeholder(in context: Context) -> SimpleEntry {
        let (noteText, noteDate) = getLatestNote()
        return SimpleEntry(date: Date(), selectedColor: .blue, selectedSubColor: .blue, latestNoteText: noteText, latestNoteDate: noteDate)
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        // ColorSettings
        let selectedColor = getColor(from: configuration.selectedColor)
        let selectedSubColor = getColor(from: configuration.selectedSubColor)
        let (noteText, noteDate) = getLatestNote()
        return SimpleEntry(date: Date(), selectedColor: selectedColor, selectedSubColor: selectedSubColor, latestNoteText: noteText, latestNoteDate: noteDate)
    }
    
    // Providerのtimelineメソッド内でSimpleEntryを作成する際に、yearProgressも計算して初期化します。
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []

        let currentDate = Date()
        let calendar = Calendar.current
        // let currentMinute = calendar.component(.minute, from: currentDate)
        let currentSecond = calendar.component(.second, from: currentDate)
        
        // ColorSettings
        let selectedColor = getColor(from: configuration.selectedColor)
        let selectedSubColor = getColor(from: configuration.selectedSubColor)

        // 次の分までの秒数を計算
        let secondsUntilNextMinute = 60 - currentSecond

        for minuteOffset in 0..<15 {
            if let entryDate = calendar.date(byAdding: .second, value: secondsUntilNextMinute + (minuteOffset * 60), to: currentDate) {
                            let (noteText, noteDate) = getLatestNote()
                            let entry = SimpleEntry(date: entryDate, selectedColor: selectedColor, selectedSubColor: selectedSubColor, latestNoteText: noteText, latestNoteDate: noteDate)
                            entries.append(entry)
                        }
            }

        // 最初のエントリーが現在時刻の次の分から始まるように設定
        return Timeline(entries: entries, policy: .after(entries.first?.date ?? currentDate))
    }
    // ColorOption enumをColorに変換するためのヘルパー関数
    func getColor(from colorOption: ColorOption) -> Color {
        switch colorOption {
        case .red:
            return .red
        case .green:
            return .green
        case .blue:
            return .blue
        case .yellow:
            return .yellow
        case .purple:
            return .purple
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let yearProgress: Double
    let dayProgress: Double
    let monthProgress: Double
    let selectedColor: Color
    let selectedSubColor: Color
    let latestNoteText: String
    let latestNoteDate: String

    // 日付を基にしてイニシャライザ内で年間の進捗を計算する
    init(date: Date, selectedColor: Color, selectedSubColor:Color, latestNoteText: String, latestNoteDate: String) {
            self.date = date
            self.yearProgress = ProgressCalculators.calculateYearProgress(for: date)
            self.dayProgress = ProgressCalculators.calculateDayProgress(for: date)
            self.monthProgress=ProgressCalculators.calculateMonthProgress(for: date)
            self.selectedColor = selectedColor
            self.selectedSubColor = selectedSubColor
            self.latestNoteText = latestNoteText
            self.latestNoteDate = latestNoteDate
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
        case .systemLarge:
            DayTracerWidgetsLargeView(entry: entry)
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
    SimpleEntry(date: .now, selectedColor: .blue, selectedSubColor:.blue,latestNoteText: "Sample Note Text 1", latestNoteDate: "12/12/2023")
    SimpleEntry(date: .now, selectedColor: .green, selectedSubColor:.blue,latestNoteText: "Sample Note Text 2", latestNoteDate: "12/12/2023")
}
