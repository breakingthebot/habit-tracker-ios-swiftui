//
// HabitWidgetView.swift
// SwiftUI presentation for the habit home screen widget in small and medium sizes.
// Connects to: widgets/HabitWidgetEntry.swift, widgets/WidgetHabitSummary.swift
// Created: 2026-07-02
//

import SwiftUI
import WidgetKit

struct HabitWidgetView: View {
  let entry: HabitWidgetEntry
  @Environment(\.widgetFamily) private var family

  var body: some View {
    switch family {
    case .systemSmall:
      smallWidgetBody
    default:
      mediumWidgetBody
    }
  }

  private var smallWidgetBody: some View {
    VStack(alignment: .leading, spacing: 10) {
      widgetHeader

      if entry.summary.hasHabits {
        Text(entry.summary.completionText)
          .font(.system(size: 28, weight: .bold, design: .rounded))

        Text("\(entry.summary.openHabitCount) habit\(entry.summary.openHabitCount == 1 ? "" : "s") left today")
          .font(.caption)
          .foregroundStyle(.secondary)
      } else {
        Text("No habits yet")
          .font(.headline)
        Text("Add a habit in the app to see today's progress.")
          .font(.caption)
          .foregroundStyle(.secondary)
      }

      Spacer()
    }
    .padding()
    .containerBackground(.fill.tertiary, for: .widget)
  }

  private var mediumWidgetBody: some View {
    HStack(spacing: 16) {
      VStack(alignment: .leading, spacing: 10) {
        widgetHeader

        if entry.summary.hasHabits {
          Text("\(entry.summary.completedTodayCount) of \(entry.summary.totalHabitCount)")
            .font(.system(size: 24, weight: .bold, design: .rounded))

          Text("completed today")
            .font(.caption)
            .foregroundStyle(.secondary)
        } else {
          Text("No habits yet")
            .font(.headline)
          Text("Create habits in the app to populate this widget.")
            .font(.caption)
            .foregroundStyle(.secondary)
        }

        Spacer()
      }

      Divider()

      VStack(alignment: .leading, spacing: 8) {
        Text("Focus Next")
          .font(.caption.weight(.semibold))
          .foregroundStyle(.secondary)

        if entry.summary.leadingHabits.isEmpty {
          Text("Nothing to show yet.")
            .font(.caption)
            .foregroundStyle(.secondary)
        } else {
          ForEach(Array(entry.summary.leadingHabits.enumerated()), id: \.offset) { _, item in
            HStack {
              Circle()
                .fill(item.isCompletedToday ? Color.green : Color.orange)
                .frame(width: 8, height: 8)

              Text(item.name)
                .font(.caption.weight(.medium))
                .lineLimit(1)

              Spacer()

              Text("\(item.streak)d")
                .font(.caption2.weight(.bold))
                .foregroundStyle(.secondary)
            }
          }
        }

        Spacer()
      }
    }
    .padding()
    .containerBackground(.fill.tertiary, for: .widget)
  }

  private var widgetHeader: some View {
    Label("Habit Tracker", systemImage: "checkmark.circle.badge.clock")
      .font(.caption.weight(.semibold))
      .foregroundStyle(.secondary)
  }
}
