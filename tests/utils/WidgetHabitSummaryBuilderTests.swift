//
// WidgetHabitSummaryBuilderTests.swift
// Unit tests for compact widget summary ranking and completion counts.
// Connects to: src/widgets/WidgetHabitSummaryBuilder.swift, src/widgets/WidgetHabitSummary.swift, src/models/Habit.swift
// Created: 2026-07-02
//

import XCTest
@testable import HabitTracker

final class WidgetHabitSummaryBuilderTests: XCTestCase {
  private var calendar: Calendar!
  private var referenceDate: Date!

  override func setUp() {
    super.setUp()
    calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = .gmt
    referenceDate = calendar.date(from: DateComponents(year: 2026, month: 7, day: 2, hour: 9))!
  }

  /// Verifies that an empty habit list returns the dedicated empty widget state.
  func testBuildSummaryReturnsEmptyStateWhenHabitsMissing() {
    let summary = WidgetHabitSummaryBuilder.buildSummary(
      habits: [],
      referenceDate: referenceDate,
      calendar: calendar
    )

    XCTAssertEqual(summary, .empty)
  }

  /// Verifies that the widget summary counts completed habits and ranks open habits first.
  func testBuildSummaryRanksOpenHabitsAheadOfCompletedOnes() {
    let habits = [
      Habit(
        id: UUID(),
        name: "Read",
        createdAt: referenceDate,
        completedDayKeys: ["2026-06-30", "2026-07-01"]
      ),
      Habit(
        id: UUID(),
        name: "Walk",
        createdAt: referenceDate,
        completedDayKeys: ["2026-07-01", "2026-07-02"]
      ),
      Habit(
        id: UUID(),
        name: "Meditate",
        createdAt: referenceDate,
        completedDayKeys: []
      ),
      Habit(
        id: UUID(),
        name: "Journal",
        createdAt: referenceDate,
        completedDayKeys: ["2026-06-29", "2026-06-30", "2026-07-01"]
      )
    ]

    let summary = WidgetHabitSummaryBuilder.buildSummary(
      habits: habits,
      referenceDate: referenceDate,
      calendar: calendar
    )

    XCTAssertEqual(summary.completedTodayCount, 1)
    XCTAssertEqual(summary.totalHabitCount, 4)
    XCTAssertEqual(summary.leadingHabits.map(\.name), ["Journal", "Read", "Meditate"])
  }
}
