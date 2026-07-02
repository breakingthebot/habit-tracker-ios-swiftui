//
// AddHabitView.swift
// Modal form for creating or renaming a habit with inline validation guidance.
// Connects to: config/AppConstants.swift, services/HabitStore.swift, components/HabitListView.swift
// Created: 2026-07-01
//

import SwiftUI

struct AddHabitView: View {
  @State private var habitName: String

  let title: String
  let saveButtonTitle: String
  let saveAction: (String) -> Void
  let cancelAction: () -> Void

  init(
    title: String = "New Habit",
    saveButtonTitle: String = "Save",
    initialHabitName: String = "",
    saveAction: @escaping (String) -> Void,
    cancelAction: @escaping () -> Void
  ) {
    self.title = title
    self.saveButtonTitle = saveButtonTitle
    self.saveAction = saveAction
    self.cancelAction = cancelAction
    _habitName = State(initialValue: initialHabitName)
  }

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
      .navigationTitle(title)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel", action: cancelAction)
        }

        ToolbarItem(placement: .confirmationAction) {
          Button(saveButtonTitle) {
            saveAction(habitName)
          }
          .disabled(habitName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
      }
    }
  }
}
