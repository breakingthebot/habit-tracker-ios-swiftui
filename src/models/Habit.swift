//
// Habit.swift
// Model for a habit and the set of calendar days it was completed.
// Connects to: services/HabitStore.swift, utils/StreakCalculator.swift
// Created: 2026-07-01
//

import Foundation

struct Habit: Identifiable, Equatable, Codable {
  let id: UUID
  let name: String
  let createdAt: Date
  var completedDayKeys: Set<String>

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

    return Habit(id: id, name: name, createdAt: createdAt, completedDayKeys: updatedDayKeys)
  }
}
