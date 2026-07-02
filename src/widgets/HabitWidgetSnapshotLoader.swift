//
// HabitWidgetSnapshotLoader.swift
// Loads saved habits from the shared app-group store and converts them into widget summaries.
// Connects to: widgets/WidgetHabitSummaryBuilder.swift, services/HabitPersistence.swift, models/Habit.swift, config/AppConstants.swift
// Created: 2026-07-02
//

import Foundation

struct HabitWidgetSnapshotLoader {
  private let decoder: JSONDecoder
  private let calendar: Calendar

  init(decoder: JSONDecoder = JSONDecoder(), calendar: Calendar = .current) {
    self.decoder = decoder
    self.calendar = calendar
  }

  /// Loads today's widget summary from the shared app-group `UserDefaults`.
  /// - Parameter referenceDate: The date used for completion and streak calculations.
  /// - Returns: The latest compact widget summary.
  func loadSummary(referenceDate: Date = Date()) -> WidgetHabitSummary {
    let sharedDefaults = UserDefaultsHabitPersistence.sharedUserDefaults()

    guard let savedData = sharedDefaults.data(forKey: AppConstants.habitsStorageKey) else {
      return .empty
    }

    do {
      let habits = try decoder.decode([Habit].self, from: savedData)
      return WidgetHabitSummaryBuilder.buildSummary(
        habits: habits,
        referenceDate: referenceDate,
        calendar: calendar
      )
    } catch {
      return .empty
    }
  }
}
