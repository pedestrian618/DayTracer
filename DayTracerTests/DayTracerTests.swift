//
//  DayTracerTests.swift
//  DayTracerTests
//
//  Created by murate on 2023/12/02.
//

import XCTest
@testable import DayTracer

/// `ProgressCalculators` の単体テスト。
///
/// 計算は `Calendar.current` 基準なので、テスト側も同じカレンダーで日付を組み立てて
/// タイムゾーン差で壊れないようにしている。検証日は DST 切替を含まない日付を選んでいる。
final class ProgressCalculatorsTests: XCTestCase {

    private let calendar = Calendar.current

    /// 指定した年月日・時分秒の Date を現在のカレンダーで生成するヘルパー。
    private func makeDate(year: Int, month: Int, day: Int,
                          hour: Int = 0, minute: Int = 0, second: Int = 0) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.second = second
        return calendar.date(from: components)!
    }

    // MARK: - Day Progress

    func testDayProgress_atStartOfDay_isZero() {
        let start = calendar.startOfDay(for: makeDate(year: 2024, month: 6, day: 15))
        XCTAssertEqual(ProgressCalculators.calculateDayProgress(for: start), 0.0, accuracy: 1e-9)
    }

    func testDayProgress_atNoon_isHalf() {
        let noon = makeDate(year: 2024, month: 6, day: 15, hour: 12)
        XCTAssertEqual(ProgressCalculators.calculateDayProgress(for: noon), 0.5, accuracy: 1e-6)
    }

    func testDayProgress_atSixPM_isThreeQuarters() {
        let evening = makeDate(year: 2024, month: 6, day: 15, hour: 18)
        XCTAssertEqual(ProgressCalculators.calculateDayProgress(for: evening), 0.75, accuracy: 1e-6)
    }

    // MARK: - Month Progress

    func testMonthProgress_atStartOfMonth_isZero() {
        let start = makeDate(year: 2024, month: 6, day: 1)
        XCTAssertEqual(ProgressCalculators.calculateMonthProgress(for: start), 0.0, accuracy: 1e-9)
    }

    func testMonthProgress_atMidMonth_isAboutHalf() {
        // 6月は30日。16日0時で15日経過 ≒ 半分。
        let mid = makeDate(year: 2024, month: 6, day: 16)
        XCTAssertEqual(ProgressCalculators.calculateMonthProgress(for: mid), 0.5, accuracy: 1e-3)
    }

    // MARK: - Year Progress

    func testYearProgress_atStartOfYear_isZero() {
        let start = makeDate(year: 2024, month: 1, day: 1)
        XCTAssertEqual(ProgressCalculators.calculateYearProgress(for: start), 0.0, accuracy: 1e-9)
    }

    func testYearProgress_atMidYear_isHalf() {
        // 2024 はうるう年（366日）。7/2 0時 = 183日経過 = ちょうど半分。
        let mid = makeDate(year: 2024, month: 7, day: 2)
        XCTAssertEqual(ProgressCalculators.calculateYearProgress(for: mid), 0.5, accuracy: 1e-6)
    }

    // MARK: - Week Progress

    func testWeekProgress_atStartOfWeek_isZero() {
        let someDate = makeDate(year: 2024, month: 6, day: 12, hour: 15)
        let interval = calendar.dateInterval(of: .weekOfYear, for: someDate)!
        XCTAssertEqual(ProgressCalculators.calculateWeekProgress(for: interval.start), 0.0, accuracy: 1e-9)
    }

    func testWeekProgress_atMidWeek_isAboutHalf() {
        let someDate = makeDate(year: 2024, month: 6, day: 12, hour: 15)
        let interval = calendar.dateInterval(of: .weekOfYear, for: someDate)!
        let mid = interval.start.addingTimeInterval(interval.duration / 2)
        XCTAssertEqual(ProgressCalculators.calculateWeekProgress(for: mid), 0.5, accuracy: 1e-6)
    }

    // MARK: - 範囲チェック

    func testAllProgressValues_areWithinValidRange() {
        let samples = [
            makeDate(year: 2024, month: 1, day: 1),
            makeDate(year: 2024, month: 6, day: 15, hour: 12, minute: 30),
            makeDate(year: 2024, month: 12, day: 31, hour: 23, minute: 59, second: 59),
            makeDate(year: 2023, month: 2, day: 28, hour: 9),
        ]
        for date in samples {
            let day = ProgressCalculators.calculateDayProgress(for: date)
            let week = ProgressCalculators.calculateWeekProgress(for: date)
            let month = ProgressCalculators.calculateMonthProgress(for: date)
            let year = ProgressCalculators.calculateYearProgress(for: date)
            XCTAssertTrue((0.0...1.0).contains(day), "day progress out of range: \(day)")
            XCTAssertTrue((0.0...1.0).contains(week), "week progress out of range: \(week)")
            XCTAssertTrue((0.0...1.0).contains(month), "month progress out of range: \(month)")
            XCTAssertTrue((0.0...1.0).contains(year), "year progress out of range: \(year)")
        }
    }
}
