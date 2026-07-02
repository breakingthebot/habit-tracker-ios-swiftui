# Changelog

## 0.4.0 - 2026-07-02
- Add a GitHub Actions workflow that runs the XCTest suite on a macOS runner.
- Add a shared Xcode scheme so CI can resolve the app and test targets from a fresh checkout.
- Update the README with CI behavior and workflow location.

## 0.3.0 - 2026-07-01
- Add rename and delete support for habits through centralized store mutations.
- Reuse the habit form sheet for both create and edit flows.
- Add swipe actions and delete confirmation to the habit list UI.
- Add tests for rename/delete success and rollback on persistence failures.

## 0.2.0 - 2026-07-01
- Add a dedicated persistence service backed by `UserDefaults`.
- Load saved habits during app startup and keep habits across app relaunches.
- Roll back in-memory changes when persistence fails so the UI stays honest.
- Add unit tests for persistence round-trips and startup/save failure paths.

## 0.1.0 - 2026-07-01
- Scaffold the SwiftUI habit tracker project structure.
- Add in-memory habit creation, daily completion toggling, and streak calculation.
- Add unit tests for streak logic and store behavior.
- Add MIT license, README, and repository hygiene files.
