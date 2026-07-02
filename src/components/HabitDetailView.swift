//
// HabitDetailView.swift
// Detail screen that shows streak stats and completion history for a selected habit.
// Connects to: services/HabitStore.swift, models/HabitHistoryDay.swift, utils/DateValueFormatter.swift
// Created: 2026-07-02
//

import SwiftUI

struct HabitDetailView: View {
  @ObservedObject var store: HabitStore
  let habitID: UUID

  var body: some View {
    Group {
      if let habit = store.habit(withID: habitID) {
        List {
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

          Section("Recent 7 Days") {
            ForEach(store.recentHistory(for: habit)) { historyDay in
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
          }

          Section("All Completions") {
            let completionDates = store.completionDates(for: habit)

            if completionDates.isEmpty {
              Text("No completions recorded yet.")
                .foregroundStyle(.secondary)
            } else {
              ForEach(completionDates, id: \.self) { date in
                Text(DateValueFormatter.longDisplayText(for: date))
              }
            }
          }
        }
        .listStyle(.insetGrouped)
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
}
