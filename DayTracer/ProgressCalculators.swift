//
//  ProgressCalculators.swift
//  DayTracer
//
//  Created by murate on 2023/12/10.
//

import Foundation

struct ProgressCalculators {
    static func calculateYearProgress(for date: Date) -> Double {
        let yearStart = Calendar.current.date(from: Calendar.current.dateComponents([.year], from: date))!
        let yearEnd = Calendar.current.date(from: Calendar.current.dateComponents([.year], from: Calendar.current.date(byAdding: .year, value: 1, to: yearStart)!))!
        let totalSeconds = yearEnd.timeIntervalSince(yearStart)
        let elapsedSeconds = date.timeIntervalSince(yearStart)
        return elapsedSeconds / totalSeconds
    }
    
    static func calculateDayProgress(for date: Date) -> Double {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        let totalSeconds = endOfDay.timeIntervalSince(startOfDay)
        let elapsedSeconds = date.timeIntervalSince(startOfDay)
        return elapsedSeconds / totalSeconds
    }
    
    static func calculateWeekProgress(for date: Date, calendar: Calendar = .current) -> Double {
        guard let interval = calendar.dateInterval(of: .weekOfYear, for: date) else { return 0 }
        let totalSeconds = interval.end.timeIntervalSince(interval.start)
        let elapsedSeconds = date.timeIntervalSince(interval.start)
        return elapsedSeconds / totalSeconds
    }

    static func calculateMonthProgress(for date: Date) -> Double {
        let calendar = Calendar.current
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        let monthEnd = calendar.date(byAdding: DateComponents(month: 1, second: -1), to: monthStart)!
        let totalSeconds = monthEnd.timeIntervalSince(monthStart)
        let elapsedSeconds = date.timeIntervalSince(monthStart)
        return elapsedSeconds / totalSeconds
    }

    // MARK: - 期間（DateInterval）ヘルパー
    // ウィジェットの Text(timerInterval:) / ProgressView(timerInterval:) に渡す期間。
    // 進捗計算と同じ境界を返す（境界がズレると数値とバーが食い違う）。

    static func dayInterval(for date: Date) -> DateInterval {
        let start = Calendar.current.startOfDay(for: date)
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start)!
        return DateInterval(start: start, end: end)
    }

    static func weekInterval(for date: Date, calendar: Calendar = .current) -> DateInterval {
        calendar.dateInterval(of: .weekOfYear, for: date) ?? DateInterval(start: date, duration: 0)
    }

    static func monthInterval(for date: Date) -> DateInterval {
        let calendar = Calendar.current
        let start = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        let end = calendar.date(byAdding: .month, value: 1, to: start)!
        return DateInterval(start: start, end: end)
    }

    static func yearInterval(for date: Date) -> DateInterval {
        let calendar = Calendar.current
        let start = calendar.date(from: calendar.dateComponents([.year], from: date))!
        let end = calendar.date(byAdding: .year, value: 1, to: start)!
        return DateInterval(start: start, end: end)
    }

    // MARK: - 「残り」表示のためのヘルパー

    /// 年末までの残り時間を（日, 時, 分, 秒）に分解する。「残り163日 04:12:08」表示用。
    static func remainingTimeOfYear(for date: Date) -> (days: Int, hours: Int, minutes: Int, seconds: Int) {
        let end = yearInterval(for: date).end
        let remaining = max(0, Int(end.timeIntervalSince(date)))
        return (remaining / 86400, (remaining % 86400) / 3600, (remaining % 3600) / 60, remaining % 60)
    }

    /// その年の通算日（1月1日 = 1）。年間グリッドの「今日」判定に使う。
    static func dayOfYear(for date: Date) -> Int {
        Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1
    }

    /// その年の総日数（365 / 366）。
    static func daysInYear(for date: Date) -> Int {
        Calendar.current.range(of: .day, in: .year, for: date)?.count ?? 365
    }

    /// その1日が年に占める重み（= 1 / その年の日数）。「この日は年の0.27%だった」表示用。
    static func dayWeightOfYear(for date: Date) -> Double {
        1.0 / Double(daysInYear(for: date))
    }
}
