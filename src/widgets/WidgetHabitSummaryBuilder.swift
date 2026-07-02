//
// WidgetHabitSummaryBuilder.swift
// Builds compact widget summaries from the full saved habit list.
// Connects to: widgets/WidgetHabitSummary.swift, models/Habit.swift, utils/DateValueFormatter.swift, utils/StreakCalculator.swift
// Created: 2026-07-02
//

import Foundation

enum WidgetHabitSummaryBuilder {
  /// Builds a widget summary using today's completion status and top current streaks.
  /// - Parameters:
  ///   - habits: The full saved habit list.
  ///   - referenceDate: The date used for today's completion and streak calculations.
  ///   - calendar: The calendar used for day-key normalization.
  /// - Returns: A compact summary tailored for home screen widgets.
  static func buildSummary(
    habits: [Habit],
    referenceDate: Date,
    calendar: Calendar
  ) -> WidgetHabitSummary {
    guard !habits.isEmpty else {
      return .empty
    }

    let todayKey = DateValueFormatter.dayKey(for: referenceDate, calendar: calendar)
    let summaryItems = habits.map { habit in
      WidgetHabitSummaryItem(
        name: habit.name,
        streak: StreakCalculator.currentStreak(
          completedDayKeys: habit.completedDayKeys,
          asOf: referenceDate,
          calendar: calendar
        ),
        isCompletedToday: habit.completedDayKeys.contains(todayKey)
      )
    }

    let leadingHabits = summaryItems
      .sorted {
        if $0.isCompletedToday != $1.isCompletedToday {
          return !$0.isCompletedToday && $1.isCompletedToday
        }

        if $0.streak != $1.streak {
          return $0.streak > $1.streak
        }

        return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
      }
      .prefix(AppConstants.widgetPreviewHabitLimit)

    return WidgetHabitSummary(
      completedTodayCount: summaryItems.filter(\.isCompletedToday).count,
      totalHabitCount: habits.count,
      leadingHabits: Array(leadingHabits),
      hasHabits: true
    )
  }
}
