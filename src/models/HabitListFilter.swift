//
// HabitListFilter.swift
// List-level filter options for narrowing visible habits in the main screen.
// Connects to: utils/HabitListFilterer.swift, components/HabitListView.swift
// Created: 2026-07-02
//

import Foundation

enum HabitListFilter: String, CaseIterable, Identifiable {
  case all
  case completedToday
  case openToday

  var id: String {
    rawValue
  }

  var title: String {
    switch self {
    case .all:
      return "All"
    case .completedToday:
      return "Done Today"
    case .openToday:
      return "Open Today"
    }
  }
}
