//
// HabitStore.swift
// Observable store that manages habits, validation, and completion state.
// Connects to: models/Habit.swift, models/HabitHistoryDay.swift, models/HabitListFilter.swift, models/WeeklyHabitProgress.swift, models/WeeklyProgressSummary.swift, services/HabitPersistence.swift, utils/DateValueFormatter.swift, utils/HabitHistoryBuilder.swift, utils/HabitListFilterer.swift, utils/StreakCalculator.swift, utils/WeeklyProgressBuilder.swift
// Created: 2026-07-01
//

import Foundation
import OSLog

@MainActor
final class HabitStore: ObservableObject {
  @Published private(set) var habits: [Habit]
  @Published private(set) var isLoading: Bool
  @Published private(set) var errorMessage: String?

  private let calendar: Calendar
  private let persistence: HabitPersisting
  private let logger: Logger

  init(
    habits: [Habit] = [],
    isLoading: Bool = true,
    errorMessage: String? = nil,
    calendar: Calendar = .current,
    persistence: HabitPersisting = UserDefaultsHabitPersistence(),
    logger: Logger = Logger(subsystem: "HabitTracker", category: "HabitStore")
  ) {
    self.habits = habits
    self.isLoading = isLoading
    self.errorMessage = errorMessage
    self.calendar = calendar
    self.persistence = persistence
    self.logger = logger
  }

  /// Loads persisted habits during app startup.
  func loadInitialHabits() async {
    logger.info("Loading initial habits")
    isLoading = true

    do {
      try await Task.sleep(nanoseconds: AppConstants.loadingDelayNanoseconds)
      habits = try persistence.loadHabits()
      errorMessage = nil
      isLoading = false
      logger.info("Initial habits loaded")
    } catch {
      isLoading = false
      errorMessage = "Saved habits could not be loaded."
      logger.error("Loading failed: \(error.localizedDescription, privacy: .public)")
    }
  }

  /// Adds a new habit after validating the user-provided name.
  /// - Parameter rawName: The untrimmed habit name from the UI.
  func addHabit(named rawName: String) {
    guard let validatedName = validateHabitName(rawName) else {
      return
    }

    let habit = Habit(
      id: UUID(),
      name: validatedName,
      createdAt: Date(),
      completedDayKeys: []
    )

    let previousHabits = habits
    habits.insert(habit, at: 0)
    persistHabits(
      rollbackHabits: previousHabits,
      successLogMessage: "Added habit named \(validatedName)"
    )
  }

  /// Renames an existing habit after validating the new name.
  /// - Parameters:
  ///   - habit: The habit to rename.
  ///   - rawName: The untrimmed replacement name from the UI.
  func renameHabit(_ habit: Habit, to rawName: String) {
    guard let validatedName = validateHabitName(rawName) else {
      return
    }

    guard let index = habits.firstIndex(where: { $0.id == habit.id }) else {
      errorMessage = "That habit could not be updated."
      logger.error("Missing habit for rename")
      return
    }

    let previousHabits = habits
    habits[index] = habits[index].updatingName(validatedName)
    persistHabits(
      rollbackHabits: previousHabits,
      successLogMessage: "Renamed habit to \(validatedName)"
    )
  }

  /// Deletes a habit from the store and persists the new list.
  /// - Parameter habit: The habit to remove.
  func deleteHabit(_ habit: Habit) {
    guard let index = habits.firstIndex(where: { $0.id == habit.id }) else {
      errorMessage = "That habit could not be removed."
      logger.error("Missing habit for delete")
      return
    }

    let previousHabits = habits
    let deletedHabitName = habits[index].name
    habits.remove(at: index)
    persistHabits(
      rollbackHabits: previousHabits,
      successLogMessage: "Deleted habit named \(deletedHabitName)"
    )
  }

  /// Toggles whether a habit is completed for the provided day.
  /// - Parameters:
  ///   - habit: The habit to update.
  ///   - date: The calendar day being toggled.
  func toggleCompletion(for habit: Habit, on date: Date = Date()) {
    guard let index = habits.firstIndex(where: { $0.id == habit.id }) else {
      errorMessage = "That habit could not be updated."
      logger.error("Missing habit for toggle")
      return
    }

    let dayKey = DateValueFormatter.dayKey(for: date, calendar: calendar)
    let isCurrentlyCompleted = habits[index].completedDayKeys.contains(dayKey)
    let previousHabits = habits
    habits[index] = habits[index].updatingCompletion(dayKey: dayKey, isCompleted: !isCurrentlyCompleted)
    persistHabits(
      rollbackHabits: previousHabits,
      successLogMessage: "Toggled completion for \(habit.name) on \(dayKey)"
    )
  }

  /// Sets whether a habit is completed for a specific day.
  /// - Parameters:
  ///   - habit: The habit to update.
  ///   - date: The calendar day being changed.
  ///   - isCompleted: The desired completion state after the update.
  func setCompletion(for habit: Habit, on date: Date, isCompleted: Bool) {
    guard let index = habits.firstIndex(where: { $0.id == habit.id }) else {
      errorMessage = "That habit could not be updated."
      logger.error("Missing habit for explicit completion update")
      return
    }

    let dayKey = DateValueFormatter.dayKey(for: date, calendar: calendar)
    let previousHabits = habits
    habits[index] = habits[index].updatingCompletion(dayKey: dayKey, isCompleted: isCompleted)
    persistHabits(
      rollbackHabits: previousHabits,
      successLogMessage: "\(isCompleted ? "Marked" : "Removed") completion for \(habit.name) on \(dayKey)"
    )
  }

  /// Returns whether the supplied habit is complete today.
  /// - Parameter habit: The habit to inspect.
  /// - Returns: `true` when the habit is completed on the current day.
  func isCompletedToday(_ habit: Habit) -> Bool {
    let todayKey = DateValueFormatter.dayKey(for: Date(), calendar: calendar)
    return habit.completedDayKeys.contains(todayKey)
  }

  /// Finds the latest version of a habit by identifier.
  /// - Parameter id: The identifier to look up.
  /// - Returns: The current stored habit, if it still exists.
  func habit(withID id: UUID) -> Habit? {
    habits.first(where: { $0.id == id })
  }

  /// Calculates the current streak for a habit.
  /// - Parameter habit: The habit to inspect.
  /// - Returns: The number of consecutive completed days ending today or yesterday.
  func streak(for habit: Habit) -> Int {
    StreakCalculator.currentStreak(
      completedDayKeys: habit.completedDayKeys,
      asOf: Date(),
      calendar: calendar
    )
  }

  /// Calculates the total number of completed days for a habit.
  /// - Parameter habit: The habit to inspect.
  /// - Returns: The number of stored completion days.
  func totalCompletions(for habit: Habit) -> Int {
    habit.completedDayKeys.count
  }

  /// Builds a recent history timeline for the supplied habit.
  /// - Parameters:
  ///   - habit: The habit to inspect.
  ///   - dayCount: The number of recent days to include.
  /// - Returns: A newest-first recent history timeline.
  func recentHistory(for habit: Habit, dayCount: Int = 7) -> [HabitHistoryDay] {
    HabitHistoryBuilder.recentDays(
      completedDayKeys: habit.completedDayKeys,
      referenceDate: Date(),
      dayCount: dayCount,
      calendar: calendar
    )
  }

  /// Returns completion dates sorted from newest to oldest.
  /// - Parameter habit: The habit to inspect.
  /// - Returns: Sorted completion dates for the habit.
  func completionDates(for habit: Habit) -> [Date] {
    HabitHistoryBuilder.completionDates(
      completedDayKeys: habit.completedDayKeys,
      calendar: calendar
    )
  }

  /// Builds the current week's overall dashboard summary.
  /// - Returns: Aggregate weekly progress metrics across all habits.
  func weeklySummary() -> WeeklyProgressSummary {
    WeeklyProgressBuilder.overallSummary(
      habits: habits,
      referenceDate: Date(),
      calendar: calendar
    )
  }

  /// Builds current-week progress rows for each habit.
  /// - Returns: Per-habit weekly progress data sorted by completion strength.
  func weeklyHabitProgress() -> [WeeklyHabitProgress] {
    WeeklyProgressBuilder.habitProgress(
      habits: habits,
      referenceDate: Date(),
      calendar: calendar
    )
  }

  /// Filters habits for the main list using search text and today-status selection.
  /// - Parameters:
  ///   - searchText: The raw user-entered query.
  ///   - filter: The today-status filter to apply.
  /// - Returns: A filtered list preserving the store order.
  func filteredHabits(searchText: String, filter: HabitListFilter) -> [Habit] {
    let completedTodayIDs = Set(
      habits.compactMap { habit in
        isCompletedToday(habit) ? habit.id : nil
      }
    )

    return HabitListFilterer.filteredHabits(
      habits: habits,
      searchText: searchText,
      filter: filter,
      completedTodayIDs: completedTodayIDs
    )
  }

  /// Clears the current user-facing error.
  func clearError() {
    errorMessage = nil
  }

  /// Validates and normalizes a raw habit name from the UI.
  /// - Parameter rawName: The user-entered habit name.
  /// - Returns: The trimmed name when valid, otherwise `nil`.
  private func validateHabitName(_ rawName: String) -> String? {
    let trimmedName = rawName.trimmingCharacters(in: .whitespacesAndNewlines)

    guard !trimmedName.isEmpty else {
      errorMessage = "Enter a habit name before saving."
      logger.warning("Rejected empty habit name")
      return nil
    }

    guard trimmedName.count <= AppConstants.maxHabitNameLength else {
      errorMessage = "Habit names must be \(AppConstants.maxHabitNameLength) characters or fewer."
      logger.warning("Rejected long habit name")
      return nil
    }

    return trimmedName
  }

  /// Persists the current habit list and surfaces any storage failures.
  /// - Parameters:
  ///   - rollbackHabits: The previous state used when persistence fails.
  ///   - successLogMessage: The log line emitted after a successful save.
  private func persistHabits(rollbackHabits: [Habit], successLogMessage: String) {
    do {
      try persistence.saveHabits(habits)
      errorMessage = nil
      logger.info("\(successLogMessage, privacy: .public)")
    } catch {
      habits = rollbackHabits
      errorMessage = "Your changes could not be saved."
      logger.error("Saving failed: \(error.localizedDescription, privacy: .public)")
    }
  }
}
