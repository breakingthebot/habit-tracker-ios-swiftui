# Habit Tracker iOS App

A SwiftUI habit tracker that lets you add habits, mark daily completion, and view current streaks.

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

## Deployed
Not deployed. This project is intended to run locally in Xcode.

## Architecture Notes
This first iteration is a small, usable vertical slice of the app. I split the app into models, a store service, utilities, and focused SwiftUI components so the UI stays thin and the habit rules can be tested separately. The store currently keeps data in memory only, which makes it easy to validate the add-complete-streak flow before bringing in persistence.

## Notes
- The app includes loading, empty, and validation error states.
- Habit data resets when the app restarts because persistence has not been added yet.
- Automated Swift build execution was not available in this Windows workspace because the Swift/Xcode toolchain is not installed here.
