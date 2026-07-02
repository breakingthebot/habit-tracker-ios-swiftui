//
// HabitListView.swift
// Root screen that renders loading, empty, and populated habit states.
// Connects to: services/HabitStore.swift, components/HabitRowView.swift, components/AddHabitView.swift
// Created: 2026-07-01
//

import SwiftUI

struct HabitListView: View {
  @ObservedObject var store: HabitStore
  @State private var isPresentingAddHabit = false

  var body: some View {
    NavigationStack {
      Group {
        if store.isLoading {
          ProgressView("Loading habits...")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if store.habits.isEmpty {
          EmptyHabitsView(addHabitAction: { isPresentingAddHabit = true })
        } else {
          List {
            if let errorMessage = store.errorMessage {
              ErrorBannerView(message: errorMessage, dismissAction: store.clearError)
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
            }

            Section("Today") {
              ForEach(store.habits) { habit in
                HabitRowView(
                  habit: habit,
                  isCompletedToday: store.isCompletedToday(habit),
                  currentStreak: store.streak(for: habit),
                  toggleAction: { store.toggleCompletion(for: habit) }
                )
              }
            }
          }
          .listStyle(.insetGrouped)
        }
      }
      .navigationTitle("Habit Tracker")
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            isPresentingAddHabit = true
          } label: {
            Label("Add Habit", systemImage: "plus")
          }
        }
      }
      .sheet(isPresented: $isPresentingAddHabit) {
        AddHabitView(
          saveAction: { name in
            store.addHabit(named: name)
            if store.errorMessage == nil {
              isPresentingAddHabit = false
            }
          },
          cancelAction: {
            isPresentingAddHabit = false
          }
        )
        .presentationDetents([.medium])
      }
    }
  }
}

#Preview {
  HabitListView(
    store: HabitStore(
      habits: [
        Habit(
          id: UUID(),
          name: "Drink water",
          createdAt: .now,
          completedDayKeys: [DateValueFormatter.dayKey(for: .now)]
        )
      ],
      isLoading: false
    )
  )
}
