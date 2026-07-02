# Habit Tracker iOS App

A SwiftUI habit tracker that lets you add habits, rename or delete them, mark daily completion, inspect habit history, view current streaks, and keep everything saved between app launches.

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
6. Tap a habit row to open its history screen.

## CI
- GitHub Actions runs the XCTest suite on a macOS runner for pushes and pull requests to `main`.
- The workflow lives at `.github/workflows/ci.yml` and uses the shared `HabitTracker` scheme.

## Deployed
Not deployed. This project is intended to run locally in Xcode.

## Architecture Notes
The app is structured as a small but deliberate vertical slice: models for habit data, a store service for state transitions, a separate persistence service for storage, utilities for date and streak rules, and thin SwiftUI views for presentation. After persistence and CRUD were stable, I added a history builder utility and a dedicated habit detail screen so the app can reuse the same completion data for both today's checklist and a richer timeline view. The project also includes a shared Xcode scheme and GitHub Actions workflow so the XCTest path runs automatically on macOS CI.

## Notes
- The app includes loading, empty, and validation error states.
- Habits are persisted with `UserDefaults` using JSON encoding.
- Habit rows support swipe actions for rename and delete.
- Habit rows open a detail screen with recent history and all recorded completion dates.
- CI runs on GitHub Actions because the local Windows workspace cannot execute Xcode builds.
- Automated Swift build execution was not available in this Windows workspace because the Swift/Xcode toolchain is not installed here.
