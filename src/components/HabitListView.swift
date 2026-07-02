//
// HabitListView.swift
// Root screen that renders loading, empty, list, and navigation flows for habits.
// Connects to: services/HabitStore.swift, models/HabitListFilter.swift, components/HabitRowView.swift, components/AddHabitView.swift, components/HabitDetailView.swift, components/WeeklyDashboardView.swift
// Created: 2026-07-01
//

import SwiftUI

struct HabitListView: View {
  @ObservedObject var store: HabitStore
  @State private var navigationPath: [HabitRoute] = []
  @State private var searchText = ""
  @State private var selectedFilter: HabitListFilter = .all
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
          let visibleHabits = store.filteredHabits(searchText: searchText, filter: selectedFilter)

          List {
            if let errorMessage = store.errorMessage {
              ErrorBannerView(message: errorMessage, dismissAction: store.clearError)
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
            }

            Section {
              Picker("Status Filter", selection: $selectedFilter) {
                ForEach(HabitListFilter.allCases) { filter in
                  Text(filter.title).tag(filter)
                }
              }
              .pickerStyle(.segmented)
            }

            Section("Today") {
              if visibleHabits.isEmpty {
                Text(emptyResultsMessage)
                  .foregroundStyle(.secondary)
              } else {
                ForEach(visibleHabits) { habit in
                  HabitRowView(
                    habit: habit,
                    isCompletedToday: store.isCompletedToday(habit),
                    currentStreak: store.streak(for: habit),
                    toggleAction: { store.toggleCompletion(for: habit) }
                  )
                  .contentShape(Rectangle())
                  .onTapGesture {
                    navigationPath.append(.habitDetail(habit.id))
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
          }
          .listStyle(.insetGrouped)
        }
      }
      .navigationTitle("Habit Tracker")
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button {
            navigationPath.append(.weeklyDashboard)
          } label: {
            Label("Weekly Dashboard", systemImage: "chart.bar.xaxis")
          }
        }

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
      .navigationDestination(for: HabitRoute.self) { route in
        switch route {
        case .habitDetail(let habitID):
          HabitDetailView(store: store, habitID: habitID)
        case .weeklyDashboard:
          WeeklyDashboardView(store: store)
        }
      }
      .searchable(text: $searchText, prompt: "Search habits")
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

  private var emptyResultsMessage: String {
    if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
      return "No habits match your search."
    }

    switch selectedFilter {
    case .all:
      return "No habits found."
    case .completedToday:
      return "No habits are marked complete today."
    case .openToday:
      return "All habits are complete today."
    }
  }
}

private enum HabitRoute: Hashable {
  case habitDetail(UUID)
  case weeklyDashboard
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
