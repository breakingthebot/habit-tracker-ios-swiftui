//
// HabitHistoryBuilderTests.swift
// Unit tests for recent history timelines and completion-date sorting.
// Connects to: src/utils/HabitHistoryBuilder.swift, src/models/HabitHistoryDay.swift
// Created: 2026-07-02
//

import XCTest
@testable import HabitTracker

final class HabitHistoryBuilderTests: XCTestCase {
  private var calendar: Calendar!
  private var anchorDate: Date!

  override func setUp() {
    super.setUp()
    calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = .gmt
    anchorDate = calendar.date(from: DateComponents(year: 2026, month: 7, day: 2))
  }

  /// Verifies that recent history is returned newest first with completion flags.
  func testRecentDaysBuildsNewestFirstTimeline() {
    let history = HabitHistoryBuilder.recentDays(
      completedDayKeys: ["2026-07-02", "2026-06-30"],
      referenceDate: anchorDate,
      dayCount: 4,
      calendar: calendar
    )

    XCTAssertEqual(history.map(\.dayKey), ["2026-07-02", "2026-07-01", "2026-06-30", "2026-06-29"])
    XCTAssertEqual(history.map(\.isCompleted), [true, false, true, false])
  }

  /// Verifies that completion dates are sorted from newest to oldest.
  func testCompletionDatesSortsNewestFirst() {
    let completionDates = HabitHistoryBuilder.completionDates(
      completedDayKeys: ["2026-06-30", "2026-07-02", "2026-07-01"],
      calendar: calendar
    )

    XCTAssertEqual(
      completionDates.map { DateValueFormatter.dayKey(for: $0, calendar: calendar) },
      ["2026-07-02", "2026-07-01", "2026-06-30"]
    )
  }

  /// Verifies that invalid day counts return an empty timeline.
  func testRecentDaysReturnsEmptyArrayForNonPositiveCount() {
    let history = HabitHistoryBuilder.recentDays(
      completedDayKeys: ["2026-07-02"],
      referenceDate: anchorDate,
      dayCount: 0,
      calendar: calendar
    )

    XCTAssertTrue(history.isEmpty)
  }
}
