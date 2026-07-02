//
// WeeklyProgressSummary.swift
// Aggregated weekly progress metrics for the dashboard screen.
// Connects to: utils/WeeklyProgressBuilder.swift, components/WeeklyDashboardView.swift
// Created: 2026-07-02
//

import Foundation

struct WeeklyProgressSummary: Equatable {
  let completedCheckIns: Int
  let scheduledCheckIns: Int
  let habitsCompletedToday: Int
  let totalHabits: Int

  var completionRate: Double {
    guard scheduledCheckIns > 0 else {
      return 0
    }

    return Double(completedCheckIns) / Double(scheduledCheckIns)
  }
}
