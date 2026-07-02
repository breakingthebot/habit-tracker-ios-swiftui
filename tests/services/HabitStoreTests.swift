//
// HabitStoreTests.swift
// Unit tests for habit creation, completion state updates, and reminder persistence behavior.
// Connects to: src/services/HabitStore.swift, src/services/HabitReminderScheduler.swift, src/models/Habit.swift, src/models/HabitReminder.swift
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

  /// Verifies that renaming a habit updates the stored name.
  func testRenameHabitUpdatesNameAndPersists() {
    let habit = Habit(id: UUID(), name: "Walk", createdAt: Date(), completedDayKeys: [])
    let persistence = TestHabitPersistence(initialHabits: [habit])
    let store = HabitStore(habits: [habit], isLoading: false, persistence: persistence)

    store.renameHabit(habit, to: "Evening Walk")

    XCTAssertEqual(store.habits.first?.name, "Evening Walk")
    XCTAssertEqual(persistence.savedHabits.first?.name, "Evening Walk")
    XCTAssertNil(store.errorMessage)
  }

  /// Verifies that deleting a habit removes it and persists the new list.
  func testDeleteHabitRemovesHabitAndPersists() {
    let firstHabit = Habit(id: UUID(), name: "Walk", createdAt: Date(), completedDayKeys: [])
    let secondHabit = Habit(id: UUID(), name: "Read", createdAt: Date(), completedDayKeys: [])
    let persistence = TestHabitPersistence(initialHabits: [firstHabit, secondHabit])
    let store = HabitStore(
      habits: [firstHabit, secondHabit],
      isLoading: false,
      persistence: persistence
    )

    store.deleteHabit(firstHabit)

    XCTAssertEqual(store.habits.count, 1)
    XCTAssertEqual(store.habits.first?.name, "Read")
    XCTAssertEqual(persistence.savedHabits.map(\.name), ["Read"])
    XCTAssertNil(store.errorMessage)
  }

  /// Verifies that rename failures roll the in-memory change back.
  func testRenameHabitRollsBackWhenSavingFails() {
    let habit = Habit(id: UUID(), name: "Walk", createdAt: Date(), completedDayKeys: [])
    let store = HabitStore(
      habits: [habit],
      isLoading: false,
      persistence: TestHabitPersistence(initialHabits: [habit], saveShouldFail: true)
    )

    store.renameHabit(habit, to: "Evening Walk")

    XCTAssertEqual(store.habits.first?.name, "Walk")
    XCTAssertEqual(store.errorMessage, "Your changes could not be saved.")
  }

  /// Verifies that delete failures restore the removed habit.
  func testDeleteHabitRollsBackWhenSavingFails() {
    let habit = Habit(id: UUID(), name: "Walk", createdAt: Date(), completedDayKeys: [])
    let store = HabitStore(
      habits: [habit],
      isLoading: false,
      persistence: TestHabitPersistence(initialHabits: [habit], saveShouldFail: true)
    )

    store.deleteHabit(habit)

    XCTAssertEqual(store.habits.map(\.name), ["Walk"])
    XCTAssertEqual(store.errorMessage, "Your changes could not be saved.")
  }

  /// Verifies that the store returns completion dates sorted from newest to oldest.
  func testCompletionDatesReturnsNewestFirst() {
    let habit = Habit(
      id: UUID(),
      name: "Walk",
      createdAt: Date(),
      completedDayKeys: ["2026-06-30", "2026-07-02", "2026-07-01"]
    )
    let store = HabitStore(habits: [habit], isLoading: false, persistence: TestHabitPersistence())

    let completionDates = store.completionDates(for: habit)
    let calendar = Calendar(identifier: .gregorian)

    XCTAssertEqual(
      completionDates.map { DateValueFormatter.dayKey(for: $0, calendar: calendar) },
      ["2026-07-02", "2026-07-01", "2026-06-30"]
    )
  }

  /// Verifies that weekly summary returns aggregate counts across all habits.
  func testWeeklySummaryAggregatesAcrossHabits() {
    let habits = [
      Habit(id: UUID(), name: "Walk", createdAt: Date(), completedDayKeys: ["2026-06-28", "2026-07-02"]),
      Habit(id: UUID(), name: "Read", createdAt: Date(), completedDayKeys: ["2026-06-29"])
    ]
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = .gmt
    calendar.firstWeekday = 1
    let store = HabitStore(
      habits: habits,
      isLoading: false,
      calendar: calendar,
      persistence: TestHabitPersistence()
    )

    let summary = store.weeklySummary()

    XCTAssertEqual(summary.totalHabits, 2)
    XCTAssertEqual(summary.scheduledCheckIns, 14)
  }

  /// Verifies that filtered habits return only items matching the chosen query and status.
  func testFilteredHabitsAppliesSearchAndStatusFilter() {
    let today = Date()
    let completedKey = DateValueFormatter.dayKey(for: today)
    let completedHabit = Habit(
      id: UUID(),
      name: "Walk Outside",
      createdAt: today,
      completedDayKeys: [completedKey]
    )
    let openHabit = Habit(
      id: UUID(),
      name: "Walk Dog",
      createdAt: today,
      completedDayKeys: []
    )
    let store = HabitStore(
      habits: [completedHabit, openHabit],
      isLoading: false,
      persistence: TestHabitPersistence()
    )

    let filteredHabits = store.filteredHabits(searchText: "walk", filter: .completedToday)

    XCTAssertEqual(filteredHabits.map(\.id), [completedHabit.id])
  }

  /// Verifies that setting a specific completion date adds that day to the habit.
  func testSetCompletionAddsSpecificDate() {
    let habit = Habit(id: UUID(), name: "Walk", createdAt: Date(), completedDayKeys: [])
    let targetDate = Date(timeIntervalSince1970: 1_725_206_400)
    let targetKey = DateValueFormatter.dayKey(for: targetDate)
    let store = HabitStore(
      habits: [habit],
      isLoading: false,
      persistence: TestHabitPersistence()
    )

    store.setCompletion(for: habit, on: targetDate, isCompleted: true)

    XCTAssertTrue(store.habits[0].completedDayKeys.contains(targetKey))
  }

  /// Verifies that clearing a specific completion date removes that day from the habit.
  func testSetCompletionRemovesSpecificDate() {
    let targetDate = Date(timeIntervalSince1970: 1_725_206_400)
    let targetKey = DateValueFormatter.dayKey(for: targetDate)
    let habit = Habit(id: UUID(), name: "Walk", createdAt: Date(), completedDayKeys: [targetKey])
    let store = HabitStore(
      habits: [habit],
      isLoading: false,
      persistence: TestHabitPersistence()
    )

    store.setCompletion(for: habit, on: targetDate, isCompleted: false)

    XCTAssertFalse(store.habits[0].completedDayKeys.contains(targetKey))
  }

  /// Verifies that explicit completion updates roll back when saving fails.
  func testSetCompletionRollsBackWhenSavingFails() {
    let targetDate = Date(timeIntervalSince1970: 1_725_206_400)
    let habit = Habit(id: UUID(), name: "Walk", createdAt: Date(), completedDayKeys: [])
    let store = HabitStore(
      habits: [habit],
      isLoading: false,
      persistence: TestHabitPersistence(initialHabits: [habit], saveShouldFail: true)
    )

    store.setCompletion(for: habit, on: targetDate, isCompleted: true)

    XCTAssertTrue(store.habits[0].completedDayKeys.isEmpty)
    XCTAssertEqual(store.errorMessage, "Your changes could not be saved.")
  }

  /// Verifies that setting a reminder stores the normalized hour and minute.
  func testSetReminderPersistsReminderTime() async {
    let habit = Habit(id: UUID(), name: "Read", createdAt: Date(), completedDayKeys: [])
    let persistence = TestHabitPersistence(initialHabits: [habit])
    let scheduler = TestHabitReminderScheduler()
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = .gmt
    let store = HabitStore(
      habits: [habit],
      isLoading: false,
      calendar: calendar,
      persistence: persistence,
      reminderScheduler: scheduler
    )
    let reminderDate = calendar.date(from: DateComponents(year: 2026, month: 7, day: 2, hour: 15, minute: 45))!

    await store.setReminder(for: habit, at: reminderDate)

    XCTAssertEqual(store.habits[0].reminder, HabitReminder(hour: 15, minute: 45))
    XCTAssertEqual(persistence.savedHabits[0].reminder, HabitReminder(hour: 15, minute: 45))
    XCTAssertEqual(scheduler.upsertedHabits.first?.id, habit.id)
    XCTAssertNil(store.errorMessage)
  }

  /// Verifies that clearing a reminder removes it from persistence and unschedules notifications.
  func testClearReminderRemovesReminderAndUnschedules() async {
    let habit = Habit(
      id: UUID(),
      name: "Read",
      createdAt: Date(),
      completedDayKeys: [],
      reminder: HabitReminder(hour: 20, minute: 0)
    )
    let persistence = TestHabitPersistence(initialHabits: [habit])
    let scheduler = TestHabitReminderScheduler()
    let store = HabitStore(
      habits: [habit],
      isLoading: false,
      persistence: persistence,
      reminderScheduler: scheduler
    )

    await store.clearReminder(for: habit)

    XCTAssertNil(store.habits[0].reminder)
    XCTAssertNil(persistence.savedHabits[0].reminder)
    XCTAssertEqual(scheduler.removedHabitIDs, [habit.id])
    XCTAssertNil(store.errorMessage)
  }

  /// Verifies that permission failures roll reminder changes back.
  func testSetReminderRollsBackWhenPermissionDenied() async {
    let originalReminder = HabitReminder(hour: 19, minute: 0)
    let habit = Habit(
      id: UUID(),
      name: "Stretch",
      createdAt: Date(),
      completedDayKeys: [],
      reminder: originalReminder
    )
    let persistence = TestHabitPersistence(initialHabits: [habit])
    let scheduler = TestHabitReminderScheduler(upsertError: HabitReminderSchedulerError.permissionDenied)
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = .gmt
    let store = HabitStore(
      habits: [habit],
      isLoading: false,
      calendar: calendar,
      persistence: persistence,
      reminderScheduler: scheduler
    )
    let reminderDate = calendar.date(from: DateComponents(year: 2026, month: 7, day: 2, hour: 15, minute: 45))!

    await store.setReminder(for: habit, at: reminderDate)

    XCTAssertEqual(store.habits[0].reminder, originalReminder)
    XCTAssertEqual(persistence.savedHabits[0].reminder, originalReminder)
    XCTAssertEqual(store.errorMessage, "Allow notifications before saving reminders.")
  }

  /// Verifies that deleting a habit with a reminder also unschedules its notification.
  func testDeleteHabitRemovesScheduledReminder() async {
    let habit = Habit(
      id: UUID(),
      name: "Meditate",
      createdAt: Date(),
      completedDayKeys: [],
      reminder: HabitReminder(hour: 8, minute: 30)
    )
    let scheduler = TestHabitReminderScheduler()
    let store = HabitStore(
      habits: [habit],
      isLoading: false,
      persistence: TestHabitPersistence(initialHabits: [habit]),
      reminderScheduler: scheduler
    )

    store.deleteHabit(habit)
    await Task.yield()

    XCTAssertTrue(store.habits.isEmpty)
    XCTAssertEqual(scheduler.removedHabitIDs, [habit.id])
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

private final class TestHabitReminderScheduler: HabitReminderScheduling {
  private(set) var upsertedHabits: [Habit]
  private(set) var removedHabitIDs: [UUID]
  private let upsertError: Error?
  private let removeError: Error?

  init(upsertError: Error? = nil, removeError: Error? = nil) {
    upsertedHabits = []
    removedHabitIDs = []
    self.upsertError = upsertError
    self.removeError = removeError
  }

  /// Records reminder scheduling requests or throws the configured error.
  func upsertReminder(for habit: Habit) async throws {
    if let upsertError {
      throw upsertError
    }

    upsertedHabits.append(habit)
  }

  /// Records reminder removals or throws the configured error.
  func removeReminder(for habitID: UUID) async throws {
    if let removeError {
      throw removeError
    }

    removedHabitIDs.append(habitID)
  }
}
