//
// StreakCalculatorTests.swift
// Unit tests for consecutive streak calculation rules.
// Connects to: src/utils/StreakCalculator.swift
// Created: 2026-07-01
//

import XCTest
@testable import HabitTracker

final class StreakCalculatorTests: XCTestCase {
  private var calendar: Calendar!
  private var anchorDate: Date!

  override func setUp() {
    super.setUp()
    calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
    anchorDate = calendar.date(from: DateComponents(year: 2026, month: 7, day: 1))
  }

  /// Verifies that a streak counts backward from today when today is complete.
  func testCurrentStreakCountsBackFromToday() {
    let completedDayKeys: Set<String> = [
      "2026-06-29",
      "2026-06-30",
      "2026-07-01"
    ]

    let streak = StreakCalculator.currentStreak(
      completedDayKeys: completedDayKeys,
      asOf: anchorDate,
      calendar: calendar
    )

    XCTAssertEqual(streak, 3)
  }

  /// Verifies that a streak can continue from yesterday when today is missed.
  func testCurrentStreakFallsBackToYesterday() {
    let completedDayKeys: Set<String> = [
      "2026-06-29",
      "2026-06-30"
    ]

    let streak = StreakCalculator.currentStreak(
      completedDayKeys: completedDayKeys,
      asOf: anchorDate,
      calendar: calendar
    )

    XCTAssertEqual(streak, 2)
  }

  /// Verifies that a missing recent completion resets the streak.
  func testCurrentStreakReturnsZeroWhenRecentDaysAreMissing() {
    let completedDayKeys: Set<String> = [
      "2026-06-25",
      "2026-06-27"
    ]

    let streak = StreakCalculator.currentStreak(
      completedDayKeys: completedDayKeys,
      asOf: anchorDate,
      calendar: calendar
    )

    XCTAssertEqual(streak, 0)
  }
}
