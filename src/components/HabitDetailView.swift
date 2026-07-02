//
// HabitDetailView.swift
// Detail screen that shows streak stats, editable completion history, and daily reminder controls for a selected habit.
// Connects to: services/HabitStore.swift, models/HabitHistoryDay.swift, models/HabitReminder.swift, components/EditCompletionDateView.swift, components/ErrorBannerView.swift, config/AppConstants.swift, utils/DateValueFormatter.swift
// Created: 2026-07-02
//

import SwiftUI

struct HabitDetailView: View {
  @ObservedObject var store: HabitStore
  let habitID: UUID
  @State private var isPresentingAddCompletion = false
  @State private var isReminderEnabled = false
  @State private var reminderTime = HabitDetailView.defaultReminderDate()

  var body: some View {
    Group {
      if let habit = store.habit(withID: habitID) {
        detailList(for: habit)
      } else {
        ContentUnavailableView {
          Label("Habit Not Found", systemImage: "questionmark.circle")
        } description: {
          Text("This habit may have been deleted.")
        }
      }
    }
    .navigationTitle("History")
    .navigationBarTitleDisplayMode(.inline)
  }

  /// Builds the main detail list for the current habit.
  /// - Parameter habit: The latest stored version of the selected habit.
  /// - Returns: The complete detail screen content for that habit.
  private func detailList(for habit: Habit) -> some View {
    List {
      errorSection
      summarySection(for: habit)
      reminderSection(for: habit)
      recentHistorySection(for: habit)
      allCompletionsSection(for: habit)
    }
    .listStyle(.insetGrouped)
    .onAppear {
      syncReminderState(from: habit.reminder)
    }
    .onChange(of: habit.reminder) { _, newReminder in
      syncReminderState(from: newReminder)
    }
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button {
          isPresentingAddCompletion = true
        } label: {
          Label("Add Check-in", systemImage: "calendar.badge.plus")
        }
      }
    }
    .sheet(isPresented: $isPresentingAddCompletion) {
      EditCompletionDateView(
        habit: habit,
        saveAction: { date in
          store.setCompletion(for: habit, on: date, isCompleted: true)
          if store.errorMessage == nil {
            isPresentingAddCompletion = false
          }
        },
        cancelAction: {
          isPresentingAddCompletion = false
        }
      )
      .presentationDetents([.medium])
    }
  }

  /// Shows the current store error when one exists.
  /// - Returns: The inline error section at the top of the detail list.
  @ViewBuilder
  private var errorSection: some View {
    if let message = store.errorMessage {
      Section {
        ErrorBannerView(message: message) {
          store.clearError()
        }
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
      }
    }
  }

  /// Builds the summary metrics section for the selected habit.
  /// - Parameter habit: The habit currently shown on screen.
  /// - Returns: The top section with title, creation date, and key metrics.
  private func summarySection(for habit: Habit) -> some View {
    Section {
      VStack(alignment: .leading, spacing: 16) {
        Text(habit.name)
          .font(.largeTitle.weight(.bold))

        Text("Created \(DateValueFormatter.longDisplayText(for: habit.createdAt))")
          .font(.subheadline)
          .foregroundStyle(.secondary)

        HStack(spacing: 12) {
          detailMetric(
            title: "Current Streak",
            value: "\(store.streak(for: habit))"
          )

          detailMetric(
            title: "Total Check-ins",
            value: "\(store.totalCompletions(for: habit))"
          )
        }
      }
      .padding(.vertical, 8)
    }
  }

  /// Builds the reminder controls section for the selected habit.
  /// - Parameter habit: The habit currently shown on screen.
  /// - Returns: The reminder section with toggle and time picker.
  private func reminderSection(for habit: Habit) -> some View {
    Section("Reminder") {
      Toggle("Daily reminder", isOn: reminderToggleBinding(for: habit))

      if isReminderEnabled {
        DatePicker(
          "Reminder time",
          selection: reminderTimeBinding(for: habit),
          displayedComponents: .hourAndMinute
        )
      }
    } footer: {
      Text("The app can send one repeating local notification per habit each day.")
    }
  }

  /// Builds the recent-history section for fast day-by-day edits.
  /// - Parameter habit: The habit currently shown on screen.
  /// - Returns: The recent-history section with tap-to-toggle rows.
  private func recentHistorySection(for habit: Habit) -> some View {
    Section("Recent 7 Days") {
      ForEach(store.recentHistory(for: habit)) { historyDay in
        Button {
          store.setCompletion(for: habit, on: historyDay.date, isCompleted: !historyDay.isCompleted)
        } label: {
          historyRow(for: historyDay)
        }
        .buttonStyle(.plain)
      }

      Text("Tap a day to toggle its completion state.")
        .font(.caption)
        .foregroundStyle(.secondary)
    }
  }

  /// Builds the full completion-history section for the selected habit.
  /// - Parameter habit: The habit currently shown on screen.
  /// - Returns: The all-completions section with swipe-to-remove rows.
  private func allCompletionsSection(for habit: Habit) -> some View {
    let completionDates = store.completionDates(for: habit)

    return Section("All Completions") {
      if completionDates.isEmpty {
        Text("No completions recorded yet.")
          .foregroundStyle(.secondary)
      } else {
        ForEach(completionDates, id: \.self) { date in
          Text(DateValueFormatter.longDisplayText(for: date))
            .swipeActions(edge: .trailing) {
              Button("Remove", role: .destructive) {
                store.setCompletion(for: habit, on: date, isCompleted: false)
              }
            }
        }
      }
    }
  }

  /// Builds one recent-history row showing the date and completion state.
  /// - Parameter historyDay: The recent history entry to present.
  /// - Returns: A single row used inside the recent-history section.
  private func historyRow(for historyDay: HabitHistoryDay) -> some View {
    HStack {
      VStack(alignment: .leading, spacing: 4) {
        Text(DateValueFormatter.shortDisplayText(for: historyDay.date))
          .font(.body.weight(.medium))

        Text(DateValueFormatter.longDisplayText(for: historyDay.date))
          .font(.caption)
          .foregroundStyle(.secondary)
      }

      Spacer()

      Label(
        historyDay.isCompleted ? "Completed" : "Missed",
        systemImage: historyDay.isCompleted ? "checkmark.circle.fill" : "circle"
      )
      .foregroundStyle(historyDay.isCompleted ? .green : .secondary)
      .labelStyle(.titleAndIcon)
    }
  }

  /// Creates the toggle binding that enables or clears a habit reminder.
  /// - Parameter habit: The habit currently shown on the detail screen.
  /// - Returns: A binding that synchronizes the toggle with the store.
  private func reminderToggleBinding(for habit: Habit) -> Binding<Bool> {
    Binding(
      get: { isReminderEnabled },
      set: { isEnabled in
        isReminderEnabled = isEnabled

        if isEnabled {
          Task {
            await store.setReminder(for: habit, at: reminderTime)
          }
        } else {
          Task {
            await store.clearReminder(for: habit)
          }
        }
      }
    )
  }

  /// Creates the date binding used by the reminder time picker.
  /// - Parameter habit: The habit currently shown on the detail screen.
  /// - Returns: A binding that updates the store whenever the reminder time changes.
  private func reminderTimeBinding(for habit: Habit) -> Binding<Date> {
    Binding(
      get: { reminderTime },
      set: { newValue in
        reminderTime = newValue

        Task {
          await store.setReminder(for: habit, at: newValue)
        }
      }
    )
  }

  /// Creates one metric card used in the detail summary.
  /// - Parameters:
  ///   - title: The label shown under the metric value.
  ///   - value: The emphasized metric value.
  /// - Returns: A compact summary card view.
  private func detailMetric(title: String, value: String) -> some View {
    VStack(alignment: .leading, spacing: 6) {
      Text(value)
        .font(.title2.weight(.bold))

      Text(title)
        .font(.caption)
        .foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding()
    .background(Color(.secondarySystemGroupedBackground))
    .clipShape(RoundedRectangle(cornerRadius: 14))
  }

  /// Synchronizes local reminder UI state with the stored habit reminder.
  /// - Parameter reminder: The current persisted reminder, if one exists.
  private func syncReminderState(from reminder: HabitReminder?) {
    isReminderEnabled = reminder != nil
    reminderTime = Self.date(from: reminder) ?? reminderTime
  }

  /// Converts a stored reminder into a `Date` suitable for the time picker.
  /// - Parameter reminder: The reminder to convert.
  /// - Returns: A date using today's calendar day and the reminder's time.
  private static func date(from reminder: HabitReminder?) -> Date? {
    guard let reminder else {
      return nil
    }

    let calendar = Calendar.current
    return calendar.date(
      bySettingHour: reminder.hour,
      minute: reminder.minute,
      second: 0,
      of: Date()
    )
  }

  /// Builds the default reminder date shown when a habit has no reminder yet.
  /// - Returns: A date using today's calendar day and the app default reminder time.
  private static func defaultReminderDate() -> Date {
    let calendar = Calendar.current
    return calendar.date(
      bySettingHour: AppConstants.defaultReminderHour,
      minute: AppConstants.defaultReminderMinute,
      second: 0,
      of: Date()
    ) ?? Date()
  }
}
