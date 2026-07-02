//
// Habit.swift
// Model for a habit, its completed days, and optional reminder settings.
// Connects to: services/HabitStore.swift, models/HabitReminder.swift, utils/StreakCalculator.swift
// Created: 2026-07-01
//

import Foundation

struct Habit: Identifiable, Equatable, Codable {
  let id: UUID
  let name: String
  let createdAt: Date
  var completedDayKeys: Set<String>
  var reminder: HabitReminder?

  init(
    id: UUID,
    name: String,
    createdAt: Date,
    completedDayKeys: Set<String>,
    reminder: HabitReminder? = nil
  ) {
    self.id = id
    self.name = name
    self.createdAt = createdAt
    self.completedDayKeys = completedDayKeys
    self.reminder = reminder
  }

  /// Returns a copy of the habit with a completion day added or removed.
  /// - Parameters:
  ///   - dayKey: The normalized calendar day key to update.
  ///   - isCompleted: Indicates whether the completion should exist after the change.
  /// - Returns: A new habit with the requested completion state.
  func updatingCompletion(dayKey: String, isCompleted: Bool) -> Habit {
    var updatedDayKeys = completedDayKeys

    if isCompleted {
      updatedDayKeys.insert(dayKey)
    } else {
      updatedDayKeys.remove(dayKey)
    }

    return Habit(id: id, name: name, createdAt: createdAt, completedDayKeys: updatedDayKeys, reminder: reminder)
  }

  /// Returns a copy of the habit with a renamed title.
  /// - Parameter name: The validated name to store.
  /// - Returns: A new habit with the updated name.
  func updatingName(_ name: String) -> Habit {
    Habit(id: id, name: name, createdAt: createdAt, completedDayKeys: completedDayKeys, reminder: reminder)
  }

  /// Returns a copy of the habit with updated reminder settings.
  /// - Parameter reminder: The reminder to store, or `nil` to clear it.
  /// - Returns: A new habit with the updated reminder state.
  func updatingReminder(_ reminder: HabitReminder?) -> Habit {
    Habit(id: id, name: name, createdAt: createdAt, completedDayKeys: completedDayKeys, reminder: reminder)
  }
}
