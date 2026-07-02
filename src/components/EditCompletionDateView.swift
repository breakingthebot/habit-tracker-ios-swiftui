//
// EditCompletionDateView.swift
// Sheet for adding a specific past completion date to a habit's history.
// Connects to: components/HabitDetailView.swift, models/Habit.swift, utils/DateValueFormatter.swift
// Created: 2026-07-02
//

import SwiftUI

struct EditCompletionDateView: View {
  @State private var selectedDate: Date

  let habit: Habit
  let saveAction: (Date) -> Void
  let cancelAction: () -> Void

  init(
    habit: Habit,
    saveAction: @escaping (Date) -> Void,
    cancelAction: @escaping () -> Void
  ) {
    self.habit = habit
    self.saveAction = saveAction
    self.cancelAction = cancelAction
    _selectedDate = State(initialValue: Date())
  }

  var body: some View {
    NavigationStack {
      Form {
        Section("Completion Date") {
          DatePicker(
            "Date",
            selection: $selectedDate,
            in: validDateRange,
            displayedComponents: .date
          )

          if alreadyCompleted {
            Text("This day is already recorded as completed.")
              .font(.caption)
              .foregroundStyle(.secondary)
          }
        }
      }
      .navigationTitle("Add Check-in")
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel", action: cancelAction)
        }

        ToolbarItem(placement: .confirmationAction) {
          Button("Save") {
            saveAction(selectedDate)
          }
          .disabled(alreadyCompleted)
        }
      }
    }
  }

  private var validDateRange: ClosedRange<Date> {
    let lowerBound = Calendar.current.startOfDay(for: habit.createdAt)
    let upperBound = Calendar.current.startOfDay(for: Date())
    return lowerBound...upperBound
  }

  private var alreadyCompleted: Bool {
    habit.completedDayKeys.contains(DateValueFormatter.dayKey(for: selectedDate))
  }
}
