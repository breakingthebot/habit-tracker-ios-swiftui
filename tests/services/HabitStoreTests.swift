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
    let persistence = TestHabitPersistence()
    let store = HabitStore(isLoading: false, persistence: persistence)

    store.addHabit(named: "  Read for 20 minutes  ")

    XCTAssertEqual(store.habits.count, 1)
    XCTAssertEqual(store.habits.first?.name, "Read for 20 minutes")
    XCTAssertNil(store.errorMessage)
    XCTAssertEqual(persistence.savedHabits.count, 1)
  }

  /// Verifies that empty names are rejected with a user-facing error.
  func testAddHabitRejectsEmptyName() {
    let store = HabitStore(isLoading: false, persistence: TestHabitPersistence())

    store.addHabit(named: "   ")

    XCTAssertTrue(store.habits.isEmpty)
    XCTAssertEqual(store.errorMessage, "Enter a habit name before saving.")
  }

  /// Verifies that toggling completion adds and removes today's normalized day key.
  func testToggleCompletionFlipsTodayState() {
    let today = Date()
    let persistence = TestHabitPersistence()
    let store = HabitStore(
      habits: [
        Habit(id: UUID(), name: "Stretch", createdAt: today, completedDayKeys: [])
      ],
      isLoading: false,
      persistence: persistence
    )

    guard let habit = store.habits.first else {
      XCTFail("Expected a habit")
      return
    }

    store.toggleCompletion(for: habit, on: today)
    XCTAssertTrue(store.isCompletedToday(store.habits[0]))

    store.toggleCompletion(for: store.habits[0], on: today)
    XCTAssertFalse(store.isCompletedToday(store.habits[0]))
    XCTAssertEqual(persistence.saveCallCount, 2)
  }

  /// Verifies that persisted habits are loaded during startup.
  func testLoadInitialHabitsUsesPersistenceResults() async {
    let expectedHabits = [
      Habit(id: UUID(), name: "Journal", createdAt: Date(), completedDayKeys: ["2026-07-01"])
    ]
    let store = HabitStore(
      isLoading: false,
      persistence: TestHabitPersistence(initialHabits: expectedHabits)
    )

    await store.loadInitialHabits()

    XCTAssertEqual(store.habits, expectedHabits)
    XCTAssertFalse(store.isLoading)
    XCTAssertNil(store.errorMessage)
  }

  /// Verifies that load failures surface a startup error message.
  func testLoadInitialHabitsShowsErrorWhenPersistenceFails() async {
    let store = HabitStore(
      isLoading: false,
      persistence: TestHabitPersistence(loadShouldFail: true)
    )

    await store.loadInitialHabits()

    XCTAssertTrue(store.habits.isEmpty)
    XCTAssertFalse(store.isLoading)
    XCTAssertEqual(store.errorMessage, "Saved habits could not be loaded.")
  }

  /// Verifies that save failures surface a user-facing persistence error.
  func testAddHabitShowsErrorWhenSavingFails() {
    let store = HabitStore(
      isLoading: false,
      persistence: TestHabitPersistence(saveShouldFail: true)
    )

    store.addHabit(named: "Read")

    XCTAssertTrue(store.habits.isEmpty)
    XCTAssertEqual(store.errorMessage, "Your changes could not be saved.")
  }
}

private enum TestPersistenceError: Error {
  case failed
}

private final class TestHabitPersistence: HabitPersisting {
  private(set) var savedHabits: [Habit]
  private(set) var saveCallCount: Int
  private let saveShouldFail: Bool
  private let loadShouldFail: Bool

  init(
    initialHabits: [Habit] = [],
    saveShouldFail: Bool = false,
    loadShouldFail: Bool = false
  ) {
    savedHabits = initialHabits
    saveCallCount = 0
    self.saveShouldFail = saveShouldFail
    self.loadShouldFail = loadShouldFail
  }

  /// Loads habits from the test double.
  func loadHabits() throws -> [Habit] {
    if loadShouldFail {
      throw TestPersistenceError.failed
    }

    return savedHabits
  }

  /// Saves habits into the test double.
  func saveHabits(_ habits: [Habit]) throws {
    if saveShouldFail {
      throw TestPersistenceError.failed
    }

    savedHabits = habits
    saveCallCount += 1
  }
}
