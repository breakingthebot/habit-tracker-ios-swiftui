//
// DateValueFormatter.swift
// Date helpers for normalizing habit completion dates and short labels.
// Connects to: services/HabitStore.swift, components/HabitRowView.swift
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

  /// Creates a compact label for dates shown in the habit list.
  /// - Parameter date: The date to format.
  /// - Returns: A short weekday and day string.
  static func shortDisplayText(for date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEE, MMM d"
    return formatter.string(from: date)
  }
}
