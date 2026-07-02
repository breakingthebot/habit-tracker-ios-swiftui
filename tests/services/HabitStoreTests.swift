//
// HabitStoreTests.swift
// Unit tests for habit creation and completion state updates.
// Connects to: src/services/HabitStore.swift, src/models/Habit.swift
// Created: 2026-07-01
//

import XCTest
@testable import HabitTracker

@MainActor
final class HabitStoreTests: XCTestCase {
  /// Verifies that valid trimmed names create new habits.
  func testAddHabitTrimsNameAndClearsError() {
    let store = HabitStore(isLoading: false)

    store.addHabit(named: "  Read for 20 minutes  ")

    XCTAssertEqual(store.habits.count, 1)
    XCTAssertEqual(store.habits.first?.name, "Read for 20 minutes")
    XCTAssertNil(store.errorMessage)
  }

  /// Verifies that empty names are rejected with a user-facing error.
  func testAddHabitRejectsEmptyName() {
    let store = HabitStore(isLoading: false)

    store.addHabit(named: "   ")

    XCTAssertTrue(store.habits.isEmpty)
    XCTAssertEqual(store.errorMessage, "Enter a habit name before saving.")
  }

  /// Verifies that toggling completion adds and removes today's normalized day key.
  func testToggleCompletionFlipsTodayState() {
    let today = Date()
    let store = HabitStore(
      habits: [
        Habit(id: UUID(), name: "Stretch", createdAt: today, completedDayKeys: [])
      ],
      isLoading: false
    )

    guard let habit = store.habits.first else {
      XCTFail("Expected a habit")
      return
    }

    store.toggleCompletion(for: habit, on: today)
    XCTAssertTrue(store.isCompletedToday(store.habits[0]))

    store.toggleCompletion(for: store.habits[0], on: today)
    XCTAssertFalse(store.isCompletedToday(store.habits[0]))
  }
}
