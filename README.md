# Habit Tracker iOS App

A SwiftUI habit tracker that lets you add habits, rename or delete them, mark daily completion, view current streaks, and keep everything saved between app launches.

## Stack
- Swift 5
- SwiftUI
- XCTest
- `os.Logger` for lightweight structured logging

## Setup
1. Clone the repository.
2. Open `HabitTracker.xcodeproj` in Xcode on macOS.
3. Select the `HabitTracker` scheme.
4. Build and run on an iOS Simulator.

## Environment Variables
No environment variables are required right now. See `.env.example`.

## Running Locally
1. Open `HabitTracker.xcodeproj`.
2. Choose an iPhone simulator such as iPhone 16.
3. Press Run in Xcode.
4. Stop and rerun the app to confirm habits persist.
5. Swipe a habit row to edit or delete it.

## CI
- GitHub Actions runs the XCTest suite on a macOS runner for pushes and pull requests to `main`.
- The workflow lives at `.github/workflows/ci.yml` and uses the shared `HabitTracker` scheme.

## Deployed
Not deployed. This project is intended to run locally in Xcode.

## Architecture Notes
The app is structured as a small but deliberate vertical slice: models for habit data, a store service for state transitions, a separate persistence service for storage, utilities for date and streak rules, and thin SwiftUI views for presentation. After persistence was in place, I added rename and delete as store-driven mutations so habit lifecycle changes reuse the same validation, rollback, and save behavior instead of pushing business logic into the SwiftUI layer. This iteration adds a shared Xcode scheme and a GitHub Actions workflow so the same XCTest path can run automatically on a macOS CI runner.

## Notes
- The app includes loading, empty, and validation error states.
- Habits are persisted with `UserDefaults` using JSON encoding.
- Habit rows support swipe actions for rename and delete.
- CI runs on GitHub Actions because the local Windows workspace cannot execute Xcode builds.
- Automated Swift build execution was not available in this Windows workspace because the Swift/Xcode toolchain is not installed here.
