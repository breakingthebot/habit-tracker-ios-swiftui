//
// HabitHistoryDay.swift
// View model for one calendar day in a habit's recent history timeline.
// Connects to: utils/HabitHistoryBuilder.swift, components/HabitDetailView.swift
// Created: 2026-07-02
//

import Foundation

struct HabitHistoryDay: Identifiable, Equatable {
  let dayKey: String
  let date: Date
  let isCompleted: Bool

  var id: String {
    dayKey
  }
}
