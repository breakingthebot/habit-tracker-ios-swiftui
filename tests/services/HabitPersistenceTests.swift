//
// HabitPersistenceTests.swift
// Unit tests for the UserDefaults-backed habit persistence layer.
// Connects to: src/services/HabitPersistence.swift, src/models/Habit.swift
// Created: 2026-07-01
//

import XCTest
@testable import HabitTracker

final class HabitPersistenceTests: XCTestCase {
  private let storageKey = "habit-persistence-tests"
  private var suiteName: String!
  private var userDefaults: UserDefaults!

  override func setUp() {
    super.setUp()
    suiteName = UUID().uuidString
    userDefaults = UserDefaults(suiteName: suiteName)
  }

  override func tearDown() {
    userDefaults.removePersistentDomain(forName: suiteName)
    userDefaults = nil
    suiteName = nil
    super.tearDown()
  }

  /// Verifies that saved habits can be loaded back from storage.
  func testSaveAndLoadHabitsRoundTrip() throws {
    let persistence = UserDefaultsHabitPersistence(
      userDefaults: userDefaults,
      storageKey: storageKey
    )
    let habits = [
      Habit(id: UUID(), name: "Meditate", createdAt: Date(), completedDayKeys: ["2026-07-01"])
    ]

    try persistence.saveHabits(habits)
    let loadedHabits = try persistence.loadHabits()

    XCTAssertEqual(loadedHabits, habits)
  }

  /// Verifies that loading returns an empty list when nothing is saved yet.
  func testLoadHabitsReturnsEmptyArrayWhenStorageIsBlank() throws {
    let persistence = UserDefaultsHabitPersistence(
      userDefaults: userDefaults,
      storageKey: storageKey
    )

    let loadedHabits = try persistence.loadHabits()

    XCTAssertTrue(loadedHabits.isEmpty)
  }
}
