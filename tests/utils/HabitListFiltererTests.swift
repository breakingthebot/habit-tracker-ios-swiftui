//
// HabitListFiltererTests.swift
// Unit tests for habit list search and today-status filtering behavior.
// Connects to: src/utils/HabitListFilterer.swift, src/models/HabitListFilter.swift
// Created: 2026-07-02
//

import XCTest
@testable import HabitTracker

final class HabitListFiltererTests: XCTestCase {
  /// Verifies that search text matches habits case-insensitively.
  func testFilteredHabitsMatchesSearchTextCaseInsensitively() {
    let walkID = UUID()
    let habits = [
      Habit(id: walkID, name: "Walk Outside", createdAt: Date(), completedDayKeys: []),
      Habit(id: UUID(), name: "Read", createdAt: Date(), completedDayKeys: [])
    ]

    let filteredHabits = HabitListFilterer.filteredHabits(
      habits: habits,
      searchText: "walk",
      filter: .all,
      completedTodayIDs: []
    )

    XCTAssertEqual(filteredHabits.map(\.id), [walkID])
  }

  /// Verifies that the completed-today filter only returns completed habits.
  func testFilteredHabitsReturnsOnlyCompletedTodayWhenRequested() {
    let completedID = UUID()
    let openID = UUID()
    let habits = [
      Habit(id: completedID, name: "Walk", createdAt: Date(), completedDayKeys: []),
      Habit(id: openID, name: "Read", createdAt: Date(), completedDayKeys: [])
    ]

    let filteredHabits = HabitListFilterer.filteredHabits(
      habits: habits,
      searchText: "",
      filter: .completedToday,
      completedTodayIDs: [completedID]
    )

    XCTAssertEqual(filteredHabits.map(\.id), [completedID])
  }

  /// Verifies that the open-today filter excludes completed habits.
  func testFilteredHabitsReturnsOnlyOpenTodayWhenRequested() {
    let completedID = UUID()
    let openID = UUID()
    let habits = [
      Habit(id: completedID, name: "Walk", createdAt: Date(), completedDayKeys: []),
      Habit(id: openID, name: "Read", createdAt: Date(), completedDayKeys: [])
    ]

    let filteredHabits = HabitListFilterer.filteredHabits(
      habits: habits,
      searchText: "",
      filter: .openToday,
      completedTodayIDs: [completedID]
    )

    XCTAssertEqual(filteredHabits.map(\.id), [openID])
  }
}
