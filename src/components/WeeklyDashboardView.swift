//
// WeeklyDashboardView.swift
// Dashboard screen that summarizes current-week progress across all habits.
// Connects to: services/HabitStore.swift, models/WeeklyProgressSummary.swift, models/WeeklyHabitProgress.swift
// Created: 2026-07-02
//

import SwiftUI

struct WeeklyDashboardView: View {
  @ObservedObject var store: HabitStore

  var body: some View {
    let summary = store.weeklySummary()
    let progressRows = store.weeklyHabitProgress()

    List {
      Section {
        VStack(alignment: .leading, spacing: 16) {
          Text("This Week")
            .font(.largeTitle.weight(.bold))

          Text("A quick view of how your habits are trending right now.")
            .font(.subheadline)
            .foregroundStyle(.secondary)

          HStack(spacing: 12) {
            dashboardMetric(
              title: "Check-ins",
              value: "\(summary.completedCheckIns)/\(summary.scheduledCheckIns)"
            )

            dashboardMetric(
              title: "Completion Rate",
              value: summary.scheduledCheckIns == 0 ? "0%" : "\(Int(summary.completionRate * 100))%"
            )
          }

          HStack(spacing: 12) {
            dashboardMetric(
              title: "Done Today",
              value: "\(summary.habitsCompletedToday)/\(summary.totalHabits)"
            )

            dashboardMetric(
              title: "Habits Tracked",
              value: "\(summary.totalHabits)"
            )
          }
        }
        .padding(.vertical, 8)
      }

      Section("Habit Breakdown") {
        if progressRows.isEmpty {
          Text("Add habits to start seeing weekly progress.")
            .foregroundStyle(.secondary)
        } else {
          ForEach(progressRows) { progress in
            VStack(alignment: .leading, spacing: 10) {
              HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                  Text(progress.habitName)
                    .font(.headline)

                  Text("Streak: \(progress.streak) day\(progress.streak == 1 ? "" : "s")")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }

                Spacer()

                Text(progress.isCompletedToday ? "Done Today" : "Open Today")
                  .font(.caption.weight(.semibold))
                  .foregroundStyle(progress.isCompletedToday ? .green : .orange)
              }

              ProgressView(value: Double(progress.completedDays), total: Double(progress.totalDays))
                .tint(progress.completedDays == progress.totalDays ? .green : .blue)

              HStack {
                Text("\(progress.completedDays) of \(progress.totalDays) days completed")
                  .font(.caption)
                  .foregroundStyle(.secondary)

                Spacer()

                Text("\(progress.missedDays) missed")
                  .font(.caption)
                  .foregroundStyle(.secondary)
              }
            }
            .padding(.vertical, 4)
          }
        }
      }
    }
    .listStyle(.insetGrouped)
    .navigationTitle("Weekly Dashboard")
    .navigationBarTitleDisplayMode(.inline)
  }

  /// Creates one summary card for the dashboard header.
  /// - Parameters:
  ///   - title: The supporting metric label.
  ///   - value: The emphasized metric value.
  /// - Returns: A compact dashboard metric card.
  private func dashboardMetric(title: String, value: String) -> some View {
    VStack(alignment: .leading, spacing: 6) {
      Text(value)
        .font(.title3.weight(.bold))

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
