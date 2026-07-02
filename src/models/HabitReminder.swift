//
// HabitReminder.swift
// Daily reminder settings stored with each habit.
// Connects to: models/Habit.swift, services/HabitReminderScheduler.swift, components/HabitDetailView.swift
// Created: 2026-07-02
//

import Foundation

struct HabitReminder: Equatable, Codable {
  let hour: Int
  let minute: Int

  /// Converts the reminder into date components for daily scheduling.
  /// - Returns: Hour and minute components used by the notification trigger.
  func dateComponents() -> DateComponents {
    DateComponents(hour: hour, minute: minute)
  }
}
