//
// AddHabitView.swift
// Modal form for adding a new habit with inline validation guidance.
// Connects to: config/AppConstants.swift, services/HabitStore.swift
// Created: 2026-07-01
//

import SwiftUI

struct AddHabitView: View {
  @State private var habitName = ""

  let saveAction: (String) -> Void
  let cancelAction: () -> Void

  var body: some View {
    NavigationStack {
      Form {
        Section("Habit Details") {
          TextField("Walk 10 minutes", text: $habitName)
            .textInputAutocapitalization(.words)

          Text("\(habitName.trimmingCharacters(in: .whitespacesAndNewlines).count)/\(AppConstants.maxHabitNameLength)")
            .font(.caption)
            .foregroundStyle(.secondary)
        }
      }
      .navigationTitle("New Habit")
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel", action: cancelAction)
        }

        ToolbarItem(placement: .confirmationAction) {
          Button("Save") {
            saveAction(habitName)
          }
          .disabled(habitName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
      }
    }
  }
}
