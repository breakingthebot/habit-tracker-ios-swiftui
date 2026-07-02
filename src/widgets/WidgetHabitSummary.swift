//
// WidgetHabitSummary.swift
// Compact widget-facing summary of today's habit progress and leading streaks.
// Connects to: widgets/WidgetHabitSummaryBuilder.swift, widgets/HabitWidgetEntry.swift, widgets/HabitWidgetView.swift
// Created: 2026-07-02
//

import Foundation

struct WidgetHabitSummary: Equatable {
  let completedTodayCount: Int
  let totalHabitCount: Int
  let leadingHabits: [WidgetHabitSummaryItem]
  let hasHabits: Bool

  static let empty = WidgetHabitSummary(
    completedTodayCount: 0,
    totalHabitCount: 0,
    leadingHabits: [],
    hasHabits: false
  )

  var completionText: String {
    "\(completedTodayCount)/\(totalHabitCount)"
  }

  var openHabitCount: Int {
    max(totalHabitCount - completedTodayCount, 0)
  }
}

struct WidgetHabitSummaryItem: Equatable {
  let name: String
  let streak: Int
  let isCompletedToday: Bool
}
