//
// HabitWidgetEntry.swift
// Timeline entry describing the current widget snapshot for today.
// Connects to: widgets/WidgetHabitSummary.swift, widgets/HabitWidgetProvider.swift
// Created: 2026-07-02
//

import Foundation
import WidgetKit

struct HabitWidgetEntry: TimelineEntry {
  let date: Date
  let summary: WidgetHabitSummary
}
