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
    
    /// 1日の進捗。
    ///
    /// 「活動時間」モデル: 日バーは深夜0時ではなく `startMinutes`（その日の midnight からの分数）で
    /// 0% にリセットし、`endMinutes - startMinutes` の長さで 0→100% へ進む。窓の終端を過ぎてから
    /// 次のリセットまでは 100% に張り付く（＝「今日はもう終わり」）。
    ///
    /// - `endMinutes` は 1440 超を許可（例: 07:00→翌01:00 は start=420 / end=1500）。
    ///   窓の重複を避けるため呼び出し側で `endMinutes - startMinutes <= 1440` を保証すること。
    /// - デフォルト（0 / 1440）では深夜0時起点・24h・張り付きなしとなり、従来の挙動と完全一致する
    ///   （月/年/週と整合）。窓を変えた場合のみ日バーだけがローカルに非整合な動きになる（設計上の許容）。
    static func calculateDayProgress(for date: Date,
                                     startMinutes: Int = 0,
                                     endMinutes: Int = 1440,
                                     calendar: Calendar = .current) -> Double {
        let span = endMinutes - startMinutes
        guard span > 0 else { return 0 }

        let midnight = calendar.startOfDay(for: date)
        // その日の開始時刻。まだ到達していなければ「前日の開始」が現在サイクルの起点。
        let todayStart = calendar.date(byAdding: .minute, value: startMinutes, to: midnight)!
        let cycleStart = date >= todayStart
            ? todayStart
            : calendar.date(byAdding: .day, value: -1, to: todayStart)!

        let elapsedSeconds = date.timeIntervalSince(cycleStart)
        let totalSeconds = Double(span) * 60
        return min(max(elapsedSeconds / totalSeconds, 0), 1)
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
}
