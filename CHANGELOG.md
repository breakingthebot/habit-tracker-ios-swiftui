# Changelog

## 0.10.0 - 2026-07-02
- Add optional daily local reminders for each habit from the detail screen.
- Add a reminder model plus a notification scheduler service to keep reminder logic out of the views.
- Persist reminder settings with rollback behavior when notification permission is denied or scheduling fails.
- Add tests for reminder request building, reminder persistence, rollback behavior, and reminder cleanup after habit deletion.

## 0.9.0 - 2026-07-02
- Make the habit history screen editable instead of read-only.
- Add a date-specific completion setter in the store for correcting past history entries.
- Add a sheet for recording past completion dates plus removal actions for mistaken entries.
- Add tests for adding, removing, and rollback behavior on explicit history edits.

## 0.8.0 - 2026-07-02
- Add search and today-status filtering to the main habit list.
- Add reusable list-filter models and filtering utilities to keep search logic out of the view layer.
- Add empty-state messaging for filtered and searched result sets.
- Add tests for search matching, status filters, and combined store filtering behavior.

## 0.7.0 - 2026-07-02
- Protect `main` with a required GitHub Actions status check.
- Require the passing `Run XCTest Suite` job before merges.
- Update the README to document the enforced CI gate.

## 0.6.0 - 2026-07-02
- Add a weekly dashboard screen with overall check-in totals, completion rate, and per-habit weekly progress.
- Add reusable weekly progress models and builder utilities for current-week aggregation.
- Add dashboard navigation from the habit list without changing the existing history and CRUD flows.
- Add tests for weekly date windows, weekly aggregate counts, and per-habit sorting.

## 0.5.0 - 2026-07-02
- Add a habit detail screen with streak stats, recent 7-day history, and full completion-date history.
- Add a reusable history builder utility and history-day model for timeline data.
- Wire habit row taps into detail navigation without breaking the completion toggle.
- Add tests for history timeline generation and store completion-date ordering.

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
