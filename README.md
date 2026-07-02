# Habit Tracker iOS App

A SwiftUI habit tracker that lets you add habits, mark daily completion, view current streaks, and keep your habits saved between app launches.

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

## Deployed
Not deployed. This project is intended to run locally in Xcode.

## Architecture Notes
The app is structured as a small but deliberate vertical slice: models for habit data, a store service for state transitions, a separate persistence service for storage, utilities for date and streak rules, and thin SwiftUI views for presentation. I added persistence as the second iteration so the app now survives relaunches without tangling storage code into the UI, and the tests cover both the pure streak logic and the load/save behavior.

## Notes
- The app includes loading, empty, and validation error states.
- Habits are persisted with `UserDefaults` using JSON encoding.
- The app currently supports adding and toggling habits, but not editing or deleting them yet.
- Automated Swift build execution was not available in this Windows workspace because the Swift/Xcode toolchain is not installed here.
