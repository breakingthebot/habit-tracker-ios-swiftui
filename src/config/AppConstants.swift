//
// AppConstants.swift
// Central constants used across the habit tracker app.
// Connects to: services/HabitStore.swift, components/HabitRowView.swift
// Created: 2026-07-01
//

import Foundation

enum AppConstants {
  static let maxHabitNameLength = 40
  static let loadingDelayNanoseconds: UInt64 = 150_000_000
  static let habitsStorageKey = "habit-tracker.habits"
}
