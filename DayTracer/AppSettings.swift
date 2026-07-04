//
//  AppSettings.swift
//  DayTracer
//
//  アプリとウィジェットで共有する「表示設定」（週の始まり・日付/時刻の形式）。
//  App Group の UserDefaults に保存し、両ターゲットが同じ設定を参照する。
//

import Foundation

// MARK: - 設定の選択肢

enum WeekStart: String, CaseIterable, Identifiable {
    case system, sunday, monday, saturday
    var id: String { rawValue }
    var label: String {
        switch self {
        case .system: return "システム"
        case .sunday: return "日曜"
        case .monday: return "月曜"
        case .saturday: return "土曜"
        }
    }
    /// Calendar.firstWeekday（1=日 … 7=土）。system は nil（端末設定に従う）。
    var firstWeekday: Int? {
        switch self {
        case .system: return nil
        case .sunday: return 1
        case .monday: return 2
        case .saturday: return 7
        }
    }
}

enum TimeFormatOption: String, CaseIterable, Identifiable {
    case system, twentyFour, twelveHour
    var id: String { rawValue }
    var label: String {
        switch self {
        case .system: return "システム"
        case .twentyFour: return "24時間 (13:45)"
        case .twelveHour: return "12時間 (1:45 PM)"
        }
    }
}

enum DateStyleOption: String, CaseIterable, Identifiable {
    case system   // 端末ロケールの medium
    case ymd      // 2026/06/20
    case mdy      // 06/20/2026
    case dmy      // 20/06/2026
    case monthName // 月名つき（ロケール依存）: June 20, 2026 / 2026年6月20日
    case full      // 曜日つき: Friday, June 20, 2026

    var id: String { rawValue }

    /// この形式の DateFormatter を生成する。
    func makeFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        switch self {
        case .system:
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
        case .ymd:
            formatter.dateFormat = "yyyy/MM/dd"
        case .mdy:
            formatter.dateFormat = "MM/dd/yyyy"
        case .dmy:
            formatter.dateFormat = "dd/MM/yyyy"
        case .monthName:
            formatter.dateStyle = .long
            formatter.timeStyle = .none
        case .full:
            formatter.dateStyle = .full
            formatter.timeStyle = .none
        }
        return formatter
    }

    /// Picker 用ラベル。サンプル日付を端末ロケールで整形し、実際の見え方を示す。
    var label: String {
        let sample = Calendar.current.date(from: DateComponents(year: 2026, month: 6, day: 20)) ?? Date()
        let example = makeFormatter().string(from: sample)
        return self == .system ? "システム（\(example)）" : example
    }
}

// MARK: - 設定アクセス

/// 表示設定の読み出しと、設定に従ったフォーマット生成。
enum AppSettings {
    enum Keys {
        static let weekStart = "settings.weekStart"
        static let timeFormat = "settings.timeFormat"
        static let dateStyle = "settings.dateStyle"
        static let dayStartMinutes = "settings.dayStartMinutes"
        static let dayEndMinutes = "settings.dayEndMinutes"
    }

    /// 活動時間（日バーの窓）のデフォルト。0:00→24:00 ＝ 従来挙動・他メーターと整合。
    static let defaultDayStartMinutes = 0
    static let defaultDayEndMinutes = 1440

    private static var defaults: UserDefaults? { SharedConfig.defaults }

    static var weekStart: WeekStart {
        WeekStart(rawValue: defaults?.string(forKey: Keys.weekStart) ?? "") ?? .system
    }
    static var timeFormat: TimeFormatOption {
        TimeFormatOption(rawValue: defaults?.string(forKey: Keys.timeFormat) ?? "") ?? .system
    }
    static var dateStyle: DateStyleOption {
        DateStyleOption(rawValue: defaults?.string(forKey: Keys.dateStyle) ?? "") ?? .system
    }

    /// 日バー（活動時間）の開始時刻。その日の midnight からの分数。未設定なら 0（=0:00）。
    static var dayStartMinutes: Int {
        guard let d = defaults, d.object(forKey: Keys.dayStartMinutes) != nil else {
            return defaultDayStartMinutes
        }
        return d.integer(forKey: Keys.dayStartMinutes)
    }
    /// 日バー（活動時間）の終了時刻。分数。1440 超（翌日跨ぎ）を許可。未設定なら 1440（=24:00）。
    static var dayEndMinutes: Int {
        guard let d = defaults, d.object(forKey: Keys.dayEndMinutes) != nil else {
            return defaultDayEndMinutes
        }
        return d.integer(forKey: Keys.dayEndMinutes)
    }

    /// 週の始まり設定を反映したカレンダー。
    static var calendar: Calendar {
        var c = Calendar.current
        if let firstWeekday = weekStart.firstWeekday {
            c.firstWeekday = firstWeekday
        }
        return c
    }

    /// 設定された活動時間の窓を反映した日進捗。アプリ・ウィジェットはこの窓口を経由して
    /// 「日の境界」を一箇所に集約する（個別の窓計算を散らさない）。
    static func dayProgress(for date: Date) -> Double {
        ProgressCalculators.calculateDayProgress(for: date,
                                                 startMinutes: dayStartMinutes,
                                                 endMinutes: dayEndMinutes)
    }

    /// 設定に従った時刻文字列。
    static func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        switch timeFormat {
        case .system:
            formatter.timeStyle = .short
            formatter.dateStyle = .none
        case .twentyFour:
            formatter.dateFormat = "HH:mm"
        case .twelveHour:
            formatter.dateFormat = "h:mm a"
        }
        return formatter.string(from: date)
    }

    /// 設定に従った日付文字列。
    static func dateString(from date: Date) -> String {
        dateStyle.makeFormatter().string(from: date)
    }

    /// 日付＋時刻（ノートのタイムスタンプ表示用）。
    static func dateTimeString(from date: Date) -> String {
        "\(dateString(from: date)) \(timeString(from: date))"
    }
}
