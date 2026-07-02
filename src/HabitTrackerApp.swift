//
// HabitTrackerApp.swift
// Entry point for the SwiftUI habit tracker app.
// Connects to: services/HabitStore.swift, components/HabitListView.swift
// Created: 2026-07-01
//

import SwiftUI

@main
struct HabitTrackerApp: App {
  @StateObject private var store = HabitStore()

  var body: some Scene {
    WindowGroup {
      HabitListView(store: store)
        .task {
          await store.loadInitialHabits()
        }
    }
  }
}
