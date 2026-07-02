# Habit Tracker iOS App

A SwiftUI habit tracker that lets you add habits, rename or delete them, search and filter the list, mark daily completion, inspect and edit habit history, schedule daily reminders, review a weekly dashboard, view current streaks, pin a home screen widget, and keep everything saved between app launches.

## Stack
- Swift 5
- SwiftUI
- WidgetKit
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
7. Tap the weekly dashboard button in the top-left to review current-week progress.
8. Use the search bar and segmented filter to narrow the habit list.
9. Use the history screen to add or remove past completion dates.
10. Turn on a daily reminder from the history screen and pick a reminder time.
11. Accept notification permission when prompted, then verify the reminder remains saved after relaunching the app.
12. Add the `Habit Progress` widget from the home screen and confirm it reflects today's saved habits.

## CI
- GitHub Actions runs the XCTest suite on a macOS runner for pushes and pull requests to `main`.
- The workflow lives at `.github/workflows/ci.yml` and uses the shared `HabitTracker` scheme.
- Branch protection on `main` requires the `Run XCTest Suite` check to pass before merges.

## Deployed
Not deployed. This project is intended to run locally in Xcode.

## Architecture Notes
The app is structured as a small but deliberate vertical slice: models for habit data, a store service for state transitions, a separate persistence service for storage, utilities for date and streak rules, and thin SwiftUI views for presentation. After persistence, CRUD, habit history, weekly reporting, list filtering, manual history correction, and reminders were stable, I extended the architecture into a real WidgetKit surface instead of building a disconnected marketing widget. The app now writes habits into an app-group `UserDefaults` container that both the main app and widget extension can read, the store explicitly reloads widget timelines after successful saves, and the widget uses a small summary builder so home screen rendering stays decoupled from the full app UI. The project also includes a shared Xcode scheme and GitHub Actions workflow so the XCTest path runs automatically on macOS CI, and `main` is protected by that passing check.

## Notes
- The app includes loading, empty, and validation error states.
- Habits are persisted with `UserDefaults` using JSON encoding.
- Habit rows support swipe actions for rename and delete.
- The main list supports search plus `All`, `Done Today`, and `Open Today` filtering.
- Habit rows open a detail screen with recent history and all recorded completion dates.
- The history screen supports adding past check-ins and removing mistaken recorded dates.
- The history screen also supports one optional repeating local reminder per habit.
- Reminder saves roll back cleanly if notification permission is denied or scheduling fails.
- A WidgetKit extension exposes small and medium home screen widgets for today's progress and top open habits.
- The app and widget share saved habit data through an app-group `UserDefaults` container.
- The top-left dashboard action opens current-week summary metrics across all habits.
- CI runs on GitHub Actions because the local Windows workspace cannot execute Xcode builds.
- `main` is protected by the passing `Run XCTest Suite` status check.
- Automated Swift build execution was not available in this Windows workspace because the Swift/Xcode toolchain is not installed here.
