//
// WeeklyProgressBuilder.swift
// Pure helpers for building current-week dashboard metrics across habits.
// Connects to: models/WeeklyProgressSummary.swift, models/WeeklyHabitProgress.swift, services/HabitStore.swift, tests/utils/WeeklyProgressBuilderTests.swift
// Created: 2026-07-02
//

import Foundation

enum WeeklyProgressBuilder {
  /// Returns the current week's dates in calendar order starting from the first weekday.
  /// - Parameters:
  ///   - referenceDate: The anchor date inside the target week.
  ///   - calendar: The calendar used to derive week boundaries.
  /// - Returns: An ordered list of seven dates representing the current week.
  static func currentWeekDates(
    referenceDate: Date,
    calendar: Calendar = .current
  ) -> [Date] {
    guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: referenceDate) else {
      return []
    }

    return (0..<7).compactMap { offset in
      calendar.date(byAdding: .day, value: offset, to: weekInterval.start)
    }
  }

  /// Builds the overall weekly summary across all habits.
  /// - Parameters:
  ///   - habits: The habits to summarize.
  ///   - referenceDate: The anchor date inside the target week.
  ///   - calendar: The calendar used to resolve week dates and day keys.
  /// - Returns: Aggregate weekly metrics for the dashboard header.
  static func overallSummary(
    habits: [Habit],
    referenceDate: Date,
    calendar: Calendar = .current
  ) -> WeeklyProgressSummary {
    let weekDates = currentWeekDates(referenceDate: referenceDate, calendar: calendar)
    let weekDayKeys = Set(weekDates.map { DateValueFormatter.dayKey(for: $0, calendar: calendar) })
    let todayKey = DateValueFormatter.dayKey(for: referenceDate, calendar: calendar)

    let completedCheckIns = habits.reduce(into: 0) { partialResult, habit in
      partialResult += habit.completedDayKeys.intersection(weekDayKeys).count
    }

    let habitsCompletedToday = habits.filter { $0.completedDayKeys.contains(todayKey) }.count

    return WeeklyProgressSummary(
      completedCheckIns: completedCheckIns,
      scheduledCheckIns: habits.count * weekDates.count,
      habitsCompletedToday: habitsCompletedToday,
      totalHabits: habits.count
    )
  }

  /// Builds per-habit weekly progress rows for the dashboard.
  /// - Parameters:
  ///   - habits: The habits to summarize.
  ///   - referenceDate: The anchor date inside the target week.
  ///   - calendar: The calendar used to resolve week dates and day keys.
  /// - Returns: Habit progress rows sorted by strongest weekly completion first.
  static func habitProgress(
    habits: [Habit],
    referenceDate: Date,
    calendar: Calendar = .current
  ) -> [WeeklyHabitProgress] {
    let weekDates = currentWeekDates(referenceDate: referenceDate, calendar: calendar)
    let weekDayKeys = Set(weekDates.map { DateValueFormatter.dayKey(for: $0, calendar: calendar) })
    let todayKey = DateValueFormatter.dayKey(for: referenceDate, calendar: calendar)

    return habits
      .map { habit in
        let completedDays = habit.completedDayKeys.intersection(weekDayKeys).count

        return WeeklyHabitProgress(
          habitID: habit.id,
          habitName: habit.name,
          completedDays: completedDays,
          totalDays: weekDates.count,
          isCompletedToday: habit.completedDayKeys.contains(todayKey),
          streak: StreakCalculator.currentStreak(
            completedDayKeys: habit.completedDayKeys,
            asOf: referenceDate,
            calendar: calendar
          )
        )
      }
      .sorted {
        if $0.completedDays == $1.completedDays {
          return $0.habitName.localizedCaseInsensitiveCompare($1.habitName) == .orderedAscending
        }

        return $0.completedDays > $1.completedDays
      }
  }
}
