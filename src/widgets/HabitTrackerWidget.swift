//
// HabitTrackerWidget.swift
// WidgetKit configuration entry point for the habit progress home screen widget.
// Connects to: widgets/HabitWidgetProvider.swift, widgets/HabitWidgetView.swift, config/AppConstants.swift
// Created: 2026-07-02
//

import SwiftUI
import WidgetKit

@main
struct HabitTrackerWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(
      kind: AppConstants.widgetKind,
      provider: HabitWidgetProvider()
    ) { entry in
      HabitWidgetView(entry: entry)
    }
    .configurationDisplayName("Habit Progress")
    .description("Shows today's habit progress and which habits still need attention.")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}
