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

    // MARK: - Day Progress (活動時間モデル)

    /// デフォルト窓（0/1440）は引数なし版と完全一致し、従来挙動を保つ。
    func testDayProgress_defaultWindow_matchesLegacy() {
        let samples = [
            makeDate(year: 2024, month: 6, day: 15, hour: 0),
            makeDate(year: 2024, month: 6, day: 15, hour: 7, minute: 23),
            makeDate(year: 2024, month: 6, day: 15, hour: 23, minute: 59, second: 59),
        ]
        for date in samples {
            let legacy = ProgressCalculators.calculateDayProgress(for: date)
            let explicit = ProgressCalculators.calculateDayProgress(for: date, startMinutes: 0, endMinutes: 1440)
            XCTAssertEqual(legacy, explicit, accuracy: 1e-12)
        }
    }

    /// 07:00→25:00（翌1:00）窓。開始でリセット・中間で半分・終了到達で100%。
    func testDayProgress_window0700to2500() {
        let start = 7 * 60      // 07:00
        let end = 25 * 60       // 翌 01:00
        // 07:00 ちょうど → 0%
        XCTAssertEqual(
            ProgressCalculators.calculateDayProgress(for: makeDate(year: 2024, month: 6, day: 15, hour: 7),
                                                     startMinutes: start, endMinutes: end),
            0.0, accuracy: 1e-9)
        // 16:00 → 9h / 18h = 0.5
        XCTAssertEqual(
            ProgressCalculators.calculateDayProgress(for: makeDate(year: 2024, month: 6, day: 15, hour: 16),
                                                     startMinutes: start, endMinutes: end),
            0.5, accuracy: 1e-6)
        // 翌 00:30（前日 07:00 起点で 17.5h / 18h）→ まだ 100% 未満
        XCTAssertEqual(
            ProgressCalculators.calculateDayProgress(for: makeDate(year: 2024, month: 6, day: 16, hour: 0, minute: 30),
                                                     startMinutes: start, endMinutes: end),
            17.5 / 18.0, accuracy: 1e-6)
        // 翌 01:00（終了）以降は 100% 張り付き
        XCTAssertEqual(
            ProgressCalculators.calculateDayProgress(for: makeDate(year: 2024, month: 6, day: 16, hour: 1),
                                                     startMinutes: start, endMinutes: end),
            1.0, accuracy: 1e-9)
        // 翌 02:00（窓外）も 100%
        XCTAssertEqual(
            ProgressCalculators.calculateDayProgress(for: makeDate(year: 2024, month: 6, day: 16, hour: 2),
                                                     startMinutes: start, endMinutes: end),
            1.0, accuracy: 1e-9)
    }

    /// 06:00→22:00（16h）窓。開始前・終了後はクランプされる（張り付き）。
    func testDayProgress_window0600to2200_clamps() {
        let start = 6 * 60
        let end = 22 * 60
        // 05:00（開始前）→ 前日サイクルが満了済みで 100%
        XCTAssertEqual(
            ProgressCalculators.calculateDayProgress(for: makeDate(year: 2024, month: 6, day: 15, hour: 5),
                                                     startMinutes: start, endMinutes: end),
            1.0, accuracy: 1e-9)
        // 14:00 → 8h / 16h = 0.5
        XCTAssertEqual(
            ProgressCalculators.calculateDayProgress(for: makeDate(year: 2024, month: 6, day: 15, hour: 14),
                                                     startMinutes: start, endMinutes: end),
            0.5, accuracy: 1e-6)
        // 23:00（終了後）→ 100%
        XCTAssertEqual(
            ProgressCalculators.calculateDayProgress(for: makeDate(year: 2024, month: 6, day: 15, hour: 23),
                                                     startMinutes: start, endMinutes: end),
            1.0, accuracy: 1e-9)
    }

    /// 不正な窓（end <= start）は 0 を返して落ちない。
    func testDayProgress_invalidWindow_returnsZero() {
        let date = makeDate(year: 2024, month: 6, day: 15, hour: 12)
        XCTAssertEqual(
            ProgressCalculators.calculateDayProgress(for: date, startMinutes: 600, endMinutes: 600),
            0.0, accuracy: 1e-12)
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

    func testWeekProgress_respectsFirstWeekday() {
        func cal(firstWeekday: Int) -> Calendar {
            var c = Calendar(identifier: .gregorian)
            c.timeZone = TimeZone.current
            c.firstWeekday = firstWeekday
            return c
        }
        let wednesday = makeDate(year: 2024, month: 6, day: 12, hour: 12)
        let sundayStart = ProgressCalculators.calculateWeekProgress(for: wednesday, calendar: cal(firstWeekday: 1))
        let mondayStart = ProgressCalculators.calculateWeekProgress(for: wednesday, calendar: cal(firstWeekday: 2))
        XCTAssertTrue((0.0...1.0).contains(sundayStart))
        XCTAssertTrue((0.0...1.0).contains(mondayStart))
        XCTAssertNotEqual(sundayStart, mondayStart)
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
