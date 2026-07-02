//
// HabitHistoryBuilder.swift
// Pure helpers for building recent-history timelines and completion-date lists.
// Connects to: models/HabitHistoryDay.swift, services/HabitStore.swift, tests/utils/HabitHistoryBuilderTests.swift
// Created: 2026-07-02
//

import Foundation

enum HabitHistoryBuilder {
  /// Builds a newest-first timeline for the requested number of recent days.
  /// - Parameters:
  ///   - completedDayKeys: The set of normalized completed day keys.
  ///   - referenceDate: The anchor date used to build the window.
  ///   - dayCount: The number of days to include.
  ///   - calendar: The calendar used to walk backward through days.
  /// - Returns: A newest-first list of recent habit history entries.
  static func recentDays(
    completedDayKeys: Set<String>,
    referenceDate: Date,
    dayCount: Int,
    calendar: Calendar = .current
  ) -> [HabitHistoryDay] {
    guard dayCount > 0 else {
      return []
    }

    return (0..<dayCount).compactMap { offset in
      guard let date = calendar.date(byAdding: .day, value: -offset, to: referenceDate) else {
        return nil
      }

      let dayKey = DateValueFormatter.dayKey(for: date, calendar: calendar)

      return HabitHistoryDay(
        dayKey: dayKey,
        date: date,
        isCompleted: completedDayKeys.contains(dayKey)
      )
    }
  }

  /// Converts stored day keys into sorted completion dates.
  /// - Parameters:
  ///   - completedDayKeys: The set of normalized completed day keys.
  ///   - calendar: The calendar used to convert keys into dates.
  /// - Returns: Completion dates sorted from newest to oldest.
  static func completionDates(
    completedDayKeys: Set<String>,
    calendar: Calendar = .current
  ) -> [Date] {
    completedDayKeys
      .compactMap { DateValueFormatter.date(from: $0, calendar: calendar) }
      .sorted(by: >)
  }
}
