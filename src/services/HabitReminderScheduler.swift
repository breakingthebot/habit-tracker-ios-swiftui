//
// HabitReminderScheduler.swift
// Notification scheduling abstraction and UserNotifications-backed implementation for daily habit reminders.
// Connects to: models/Habit.swift, models/HabitReminder.swift, config/AppConstants.swift, services/HabitStore.swift
// Created: 2026-07-02
//

import Foundation
import OSLog
import UserNotifications

protocol HabitReminderScheduling {
  /// Schedules or replaces the reminder for a habit.
  /// - Parameter habit: The habit whose reminder should be scheduled.
  func upsertReminder(for habit: Habit) async throws

  /// Removes any scheduled reminder for a habit.
  /// - Parameter habitID: The identifier of the habit whose reminder should be removed.
  func removeReminder(for habitID: UUID) async throws
}

enum HabitReminderSchedulerError: LocalizedError {
  case permissionDenied
  case reminderMissing

  var errorDescription: String? {
    switch self {
    case .permissionDenied:
      return "Notifications are not allowed."
    case .reminderMissing:
      return "No reminder was configured for this habit."
    }
  }
}

struct UserNotificationHabitReminderScheduler: HabitReminderScheduling {
  private let center: UNUserNotificationCenter
  private let logger: Logger

  init(
    center: UNUserNotificationCenter = .current(),
    logger: Logger = Logger(subsystem: "HabitTracker", category: "HabitReminderScheduler")
  ) {
    self.center = center
    self.logger = logger
  }

  /// Schedules or replaces a repeating daily reminder notification.
  func upsertReminder(for habit: Habit) async throws {
    let authorizationGranted = try await ensureAuthorization()
    guard authorizationGranted else {
      throw HabitReminderSchedulerError.permissionDenied
    }
    let request = try Self.notificationRequest(for: habit)

    try await center.add(request)
    logger.info("Scheduled reminder for \(habit.name, privacy: .public)")
  }

  /// Removes any scheduled reminder notification for the supplied habit identifier.
  func removeReminder(for habitID: UUID) async throws {
    center.removePendingNotificationRequests(withIdentifiers: [Self.reminderIdentifier(for: habitID)])
    logger.info("Removed reminder for habit \(habitID.uuidString, privacy: .public)")
  }

  /// Ensures that notification authorization exists before scheduling.
  private func ensureAuthorization() async throws -> Bool {
    let settings = await center.notificationSettings()

    switch settings.authorizationStatus {
    case .authorized, .provisional, .ephemeral:
      return true
    case .notDetermined:
      return try await center.requestAuthorization(options: [.alert, .badge, .sound])
    case .denied:
      return false
    @unknown default:
      return false
    }
  }

  /// Creates the notification request used for a habit reminder.
  /// - Parameter habit: The habit whose reminder will be turned into a request.
  /// - Returns: A fully configured repeating calendar notification request.
  static func notificationRequest(for habit: Habit) throws -> UNNotificationRequest {
    guard let reminder = habit.reminder else {
      throw HabitReminderSchedulerError.reminderMissing
    }

    let content = UNMutableNotificationContent()
    content.title = "Habit Reminder"
    content.body = "Time to complete \(habit.name)."
    content.sound = .default

    let trigger = UNCalendarNotificationTrigger(dateMatching: reminder.dateComponents(), repeats: true)
    return UNNotificationRequest(
      identifier: reminderIdentifier(for: habit.id),
      content: content,
      trigger: trigger
    )
  }

  /// Builds the stable identifier used for a habit reminder notification.
  static func reminderIdentifier(for habitID: UUID) -> String {
    "\(AppConstants.reminderNotificationPrefix)-\(habitID.uuidString)"
  }
}
