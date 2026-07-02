//
// HabitListView.swift
// Root screen that renders loading, empty, list, and navigation flows for habits.
// Connects to: services/HabitStore.swift, components/HabitRowView.swift, components/AddHabitView.swift, components/HabitDetailView.swift
// Created: 2026-07-01
//

import SwiftUI

struct HabitListView: View {
  @ObservedObject var store: HabitStore
  @State private var navigationPath: [UUID] = []
  @State private var isPresentingAddHabit = false
  @State private var habitBeingEdited: Habit?
  @State private var habitPendingDeletion: Habit?

  var body: some View {
    NavigationStack(path: $navigationPath) {
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
                .contentShape(Rectangle())
                .onTapGesture {
                  navigationPath.append(habit.id)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                  Button("Delete", role: .destructive) {
                    habitPendingDeletion = habit
                  }

                  Button("Edit") {
                    habitBeingEdited = habit
                  }
                  .tint(.blue)
                }
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
          title: "New Habit",
          saveButtonTitle: "Save",
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
      .sheet(item: $habitBeingEdited) { habit in
        AddHabitView(
          title: "Edit Habit",
          saveButtonTitle: "Update",
          initialHabitName: habit.name,
          saveAction: { name in
            store.renameHabit(habit, to: name)
            if store.errorMessage == nil {
              habitBeingEdited = nil
            }
          },
          cancelAction: {
            habitBeingEdited = nil
          }
        )
        .presentationDetents([.medium])
      }
      .alert("Delete Habit?", isPresented: isDeleteAlertPresented) {
        Button("Delete", role: .destructive) {
          if let habitPendingDeletion {
            store.deleteHabit(habitPendingDeletion)
          }
          self.habitPendingDeletion = nil
        }

        Button("Cancel", role: .cancel) {
          habitPendingDeletion = nil
        }
      } message: {
        Text(deleteAlertMessage)
      }
      .navigationDestination(for: UUID.self) { habitID in
        HabitDetailView(store: store, habitID: habitID)
      }
    }
  }

  private var isDeleteAlertPresented: Binding<Bool> {
    Binding(
      get: { habitPendingDeletion != nil },
      set: { isPresented in
        if !isPresented {
          habitPendingDeletion = nil
        }
      }
    )
  }

  private var deleteAlertMessage: String {
    guard let habitPendingDeletion else {
      return "This habit will be removed from your tracker."
    }

    return "Delete \"\(habitPendingDeletion.name)\"? This cannot be undone."
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
