//
// HabitWidgetReloader.swift
// Widget timeline reload abstraction used after persisted habit changes.
// Connects to: services/HabitStore.swift, config/AppConstants.swift
// Created: 2026-07-02
//

import Foundation

#if canImport(WidgetKit)
import WidgetKit
#endif

protocol HabitWidgetReloading {
  /// Requests a widget timeline refresh after persisted data changes.
  func reloadAllTimelines()
}

struct HabitWidgetReloader: HabitWidgetReloading {
  /// Reloads all habit widget timelines when WidgetKit is available.
  func reloadAllTimelines() {
    #if canImport(WidgetKit)
    WidgetCenter.shared.reloadAllTimelines()
    #endif
  }
}
