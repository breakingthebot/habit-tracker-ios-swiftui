//
// StreakCalculator.swift
// Pure helper for calculating consecutive daily streaks from completion dates.
// Connects to: services/HabitStore.swift, tests/utils/StreakCalculatorTests.swift
// Created: 2026-07-01
//

import Foundation

enum StreakCalculator {
  /// Calculates the current streak length from a set of completed day keys.
  /// - Parameters:
  ///   - completedDayKeys: Normalized day keys in `yyyy-MM-dd` format.
  ///   - asOf: The anchor date used to evaluate the streak.
  ///   - calendar: The calendar used to traverse days.
  /// - Returns: The number of consecutive completed days ending today or yesterday.
  static func currentStreak(
    completedDayKeys: Set<String>,
    asOf date: Date,
    calendar: Calendar = .current
  ) -> Int {
    let todayKey = DateValueFormatter.dayKey(for: date, calendar: calendar)

    if completedDayKeys.contains(todayKey) {
      return countConsecutiveDays(startingAt: date, completedDayKeys: completedDayKeys, calendar: calendar)
    }

    guard let yesterday = calendar.date(byAdding: .day, value: -1, to: date) else {
      return 0
    }

    let yesterdayKey = DateValueFormatter.dayKey(for: yesterday, calendar: calendar)

    guard completedDayKeys.contains(yesterdayKey) else {
      return 0
    }

    return countConsecutiveDays(startingAt: yesterday, completedDayKeys: completedDayKeys, calendar: calendar)
  }

  /// Walks backward one day at a time until the streak breaks.
  private static func countConsecutiveDays(
    startingAt startDate: Date,
    completedDayKeys: Set<String>,
    calendar: Calendar
  ) -> Int {
    var streak = 0
    var currentDate = startDate

    while completedDayKeys.contains(DateValueFormatter.dayKey(for: currentDate, calendar: calendar)) {
      streak += 1

      guard let previousDate = calendar.date(byAdding: .day, value: -1, to: currentDate) else {
        break
      }

      currentDate = previousDate
    }

    return streak
  }
}
