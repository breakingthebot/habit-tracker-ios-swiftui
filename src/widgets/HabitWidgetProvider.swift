//
// HabitWidgetProvider.swift
// Timeline provider that reads shared habit data and feeds it into the home screen widget.
// Connects to: widgets/HabitWidgetEntry.swift, widgets/HabitWidgetSnapshotLoader.swift
// Created: 2026-07-02
//

import Foundation
import WidgetKit

struct HabitWidgetProvider: TimelineProvider {
  private let loader = HabitWidgetSnapshotLoader()

  /// Returns a placeholder entry for widget gallery previews.
  func placeholder(in context: Context) -> HabitWidgetEntry {
    HabitWidgetEntry(date: Date(), summary: previewSummary)
  }

  /// Returns a current snapshot for transient widget contexts.
  func getSnapshot(in context: Context, completion: @escaping (HabitWidgetEntry) -> Void) {
    let summary = context.isPreview ? previewSummary : loader.loadSummary()
    completion(HabitWidgetEntry(date: Date(), summary: summary))
  }

  /// Returns the widget timeline, refreshing periodically to keep today-state current.
  func getTimeline(in context: Context, completion: @escaping (Timeline<HabitWidgetEntry>) -> Void) {
    let entry = HabitWidgetEntry(date: Date(), summary: loader.loadSummary())
    let refreshDate = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
    completion(Timeline(entries: [entry], policy: .after(refreshDate)))
  }

  private var previewSummary: WidgetHabitSummary {
    WidgetHabitSummary(
      completedTodayCount: 1,
      totalHabitCount: 3,
      leadingHabits: [
        WidgetHabitSummaryItem(name: "Read", streak: 6, isCompletedToday: false),
        WidgetHabitSummaryItem(name: "Walk", streak: 4, isCompletedToday: true),
        WidgetHabitSummaryItem(name: "Meditate", streak: 2, isCompletedToday: false)
      ],
      hasHabits: true
    )
  }
}
