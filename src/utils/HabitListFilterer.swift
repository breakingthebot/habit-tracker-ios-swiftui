//
// HabitListFilterer.swift
// Pure helpers for filtering and searching habits in the main list.
// Connects to: models/HabitListFilter.swift, services/HabitStore.swift, tests/utils/HabitListFiltererTests.swift
// Created: 2026-07-02
//

import Foundation

enum HabitListFilterer {
  /// Filters habits by search text and today-status selection.
  /// - Parameters:
  ///   - habits: The habits to filter.
  ///   - searchText: The raw user-entered search query.
  ///   - filter: The today-status filter to apply.
  ///   - completedTodayIDs: The identifiers of habits completed today.
  /// - Returns: A filtered list preserving the original ordering.
  static func filteredHabits(
    habits: [Habit],
    searchText: String,
    filter: HabitListFilter,
    completedTodayIDs: Set<UUID>
  ) -> [Habit] {
    let normalizedQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

    return habits.filter { habit in
      let matchesSearch = normalizedQuery.isEmpty || habit.name.localizedCaseInsensitiveContains(normalizedQuery)

      let matchesFilter: Bool
      switch filter {
      case .all:
        matchesFilter = true
      case .completedToday:
        matchesFilter = completedTodayIDs.contains(habit.id)
      case .openToday:
        matchesFilter = !completedTodayIDs.contains(habit.id)
      }

      return matchesSearch && matchesFilter
    }
  }
}
