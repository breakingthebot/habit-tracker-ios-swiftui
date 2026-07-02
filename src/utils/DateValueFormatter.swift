//
// DateValueFormatter.swift
// Date helpers for normalizing habit completion dates and user-facing labels.
// Connects to: services/HabitStore.swift, components/HabitRowView.swift, components/HabitDetailView.swift
// Created: 2026-07-01
//

import Foundation

enum DateValueFormatter {
  /// Builds a stable year-month-day key for the provided date.
  /// - Parameters:
  ///   - date: The date to normalize.
  ///   - calendar: The calendar used to resolve the day.
  /// - Returns: A `yyyy-MM-dd` day key.
  static func dayKey(for date: Date, calendar: Calendar = .current) -> String {
    let components = calendar.dateComponents([.year, .month, .day], from: date)
    let year = components.year ?? 0
    let month = components.month ?? 0
    let day = components.day ?? 0
    return String(format: "%04d-%02d-%02d", year, month, day)
  }

  /// Converts a stored day key back into a date value.
  /// - Parameters:
  ///   - dayKey: The normalized `yyyy-MM-dd` key.
  ///   - calendar: The calendar used to resolve the date.
  /// - Returns: A date at the start of the represented day, or `nil` when the key is invalid.
  static func date(from dayKey: String, calendar: Calendar = .current) -> Date? {
    let parts = dayKey.split(separator: "-")

    guard parts.count == 3,
          let year = Int(parts[0]),
          let month = Int(parts[1]),
          let day = Int(parts[2]) else {
      return nil
    }

    return calendar.date(from: DateComponents(year: year, month: month, day: day))
  }

  /// Creates a compact label for dates shown in the habit list.
  /// - Parameter date: The date to format.
  /// - Returns: A short weekday and day string.
  static func shortDisplayText(for date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEE, MMM d"
    return formatter.string(from: date)
  }

  /// Creates a long label for dates shown in habit detail screens.
  /// - Parameter date: The date to format.
  /// - Returns: A full month-day-year string.
  static func longDisplayText(for date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    return formatter.string(from: date)
  }
}
