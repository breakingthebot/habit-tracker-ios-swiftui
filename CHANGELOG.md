# Changelog

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
