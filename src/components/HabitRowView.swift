//
// HabitRowView.swift
// Single row UI for a habit with completion toggle and streak summary.
// Connects to: models/Habit.swift, utils/DateValueFormatter.swift
// Created: 2026-07-01
//

import SwiftUI

struct HabitRowView: View {
  let habit: Habit
  let isCompletedToday: Bool
  let currentStreak: Int
  let toggleAction: () -> Void

  var body: some View {
    HStack(spacing: 16) {
      Button(action: toggleAction) {
        Image(systemName: isCompletedToday ? "checkmark.circle.fill" : "circle")
          .font(.system(size: 28))
          .foregroundStyle(isCompletedToday ? .green : .secondary)
          .accessibilityLabel(isCompletedToday ? "Mark incomplete" : "Mark complete")
      }
      .buttonStyle(.plain)

      VStack(alignment: .leading, spacing: 4) {
        Text(habit.name)
          .font(.headline)

        Text("Current streak: \(currentStreak) day\(currentStreak == 1 ? "" : "s")")
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }

      Spacer()

      Text(DateValueFormatter.shortDisplayText(for: .now))
        .font(.caption)
        .foregroundStyle(.secondary)
    }
    .padding(.vertical, 8)
  }
}
