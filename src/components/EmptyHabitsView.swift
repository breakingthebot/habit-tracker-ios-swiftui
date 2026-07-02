//
// EmptyHabitsView.swift
// Empty state shown before the user adds the first habit.
// Connects to: components/HabitListView.swift
// Created: 2026-07-01
//

import SwiftUI

struct EmptyHabitsView: View {
  let addHabitAction: () -> Void

  var body: some View {
    ContentUnavailableView {
      Label("No habits yet", systemImage: "checklist")
    } description: {
      Text("Add your first habit to start tracking daily consistency.")
    } actions: {
      Button("Add Habit", action: addHabitAction)
        .buttonStyle(.borderedProminent)
    }
  }
}
