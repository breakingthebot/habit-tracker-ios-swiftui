//
// WeeklyHabitProgress.swift
// Per-habit weekly progress model used by the dashboard.
// Connects to: utils/WeeklyProgressBuilder.swift, components/WeeklyDashboardView.swift
// Created: 2026-07-02
//

import Foundation

struct WeeklyHabitProgress: Identifiable, Equatable {
  let habitID: UUID
  let habitName: String
  let completedDays: Int
  let totalDays: Int
  let isCompletedToday: Bool
  let streak: Int

  var id: UUID {
    habitID
  }

  var missedDays: Int {
    max(totalDays - completedDays, 0)
  }
}
