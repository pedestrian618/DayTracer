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
}