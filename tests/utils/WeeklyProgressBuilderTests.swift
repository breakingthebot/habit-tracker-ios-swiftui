//
// WeeklyProgressBuilderTests.swift
// Unit tests for weekly dashboard aggregation and ordering logic.
// Connects to: src/utils/WeeklyProgressBuilder.swift, src/models/WeeklyProgressSummary.swift, src/models/WeeklyHabitProgress.swift
// Created: 2026-07-02
//

import XCTest
@testable import HabitTracker

final class WeeklyProgressBuilderTests: XCTestCase {
  private var calendar: Calendar!
  private var anchorDate: Date!

  override func setUp() {
    super.setUp()
    calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = .gmt
    calendar.firstWeekday = 1
    anchorDate = calendar.date(from: DateComponents(year: 2026, month: 7, day: 2))
  }

  /// Verifies that current week dates are returned from the first weekday through the seventh day.
  func testCurrentWeekDatesReturnsSevenOrderedDates() {
    let dates = WeeklyProgressBuilder.currentWeekDates(referenceDate: anchorDate, calendar: calendar)

    XCTAssertEqual(
      dates.map { DateValueFormatter.dayKey(for: $0, calendar: calendar) },
      ["2026-06-28", "2026-06-29", "2026-06-30", "2026-07-01", "2026-07-02", "2026-07-03", "2026-07-04"]
    )
  }

  /// Verifies that overall summary counts completed and scheduled check-ins across all habits.
  func testOverallSummaryCountsWeeklyCheckIns() {
    let habits = [
      Habit(id: UUID(), name: "Walk", createdAt: anchorDate, completedDayKeys: ["2026-06-28", "2026-07-02"]),
      Habit(id: UUID(), name: "Read", createdAt: anchorDate, completedDayKeys: ["2026-06-29"])
    ]

    let summary = WeeklyProgressBuilder.overallSummary(
      habits: habits,
      referenceDate: anchorDate,
      calendar: calendar
    )

    XCTAssertEqual(summary.completedCheckIns, 3)
    XCTAssertEqual(summary.scheduledCheckIns, 14)
    XCTAssertEqual(summary.habitsCompletedToday, 1)
    XCTAssertEqual(summary.totalHabits, 2)
  }

  /// Verifies that per-habit progress is sorted by strongest weekly completion first.
  func testHabitProgressSortsByCompletedDaysDescending() {
    let habits = [
      Habit(id: UUID(), name: "Read", createdAt: anchorDate, completedDayKeys: ["2026-06-29"]),
      Habit(id: UUID(), name: "Walk", createdAt: anchorDate, completedDayKeys: ["2026-06-28", "2026-07-02"])
    ]

    let progressRows = WeeklyProgressBuilder.habitProgress(
      habits: habits,
      referenceDate: anchorDate,
      calendar: calendar
    )

    XCTAssertEqual(progressRows.map(\.habitName), ["Walk", "Read"])
    XCTAssertEqual(progressRows.map(\.completedDays), [2, 1])
  }
}
