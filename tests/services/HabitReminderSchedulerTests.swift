//
// HabitReminderSchedulerTests.swift
// Unit tests for request-building helpers used by the local reminder scheduler.
// Connects to: src/services/HabitReminderScheduler.swift, src/models/Habit.swift, src/models/HabitReminder.swift, src/config/AppConstants.swift
// Created: 2026-07-02
//

import XCTest
import UserNotifications
@testable import HabitTracker

final class HabitReminderSchedulerTests: XCTestCase {
  /// Verifies that the scheduler builds a stable notification identifier per habit.
  func testReminderIdentifierUsesConfiguredPrefix() {
    let habitID = UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE")!

    let identifier = UserNotificationHabitReminderScheduler.reminderIdentifier(for: habitID)

    XCTAssertEqual(
      identifier,
      "\(AppConstants.reminderNotificationPrefix)-AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE"
    )
  }

  /// Verifies that a notification request carries the reminder time and habit-specific copy.
  func testNotificationRequestUsesHabitReminderTime() throws {
    let habit = Habit(
      id: UUID(uuidString: "11111111-2222-3333-4444-555555555555")!,
      name: "Read",
      createdAt: Date(),
      completedDayKeys: [],
      reminder: HabitReminder(hour: 21, minute: 15)
    )

    let request = try UserNotificationHabitReminderScheduler.notificationRequest(for: habit)
    let trigger = try XCTUnwrap(request.trigger as? UNCalendarNotificationTrigger)

    XCTAssertEqual(
      request.identifier,
      "\(AppConstants.reminderNotificationPrefix)-11111111-2222-3333-4444-555555555555"
    )
    XCTAssertEqual(request.content.title, "Habit Reminder")
    XCTAssertEqual(request.content.body, "Time to complete Read.")
    XCTAssertTrue(trigger.repeats)
    XCTAssertEqual(trigger.dateComponents.hour, 21)
    XCTAssertEqual(trigger.dateComponents.minute, 15)
  }

  /// Verifies that missing reminder data is rejected before request creation.
  func testNotificationRequestThrowsWhenReminderIsMissing() {
    let habit = Habit(id: UUID(), name: "Read", createdAt: Date(), completedDayKeys: [])

    XCTAssertThrowsError(try UserNotificationHabitReminderScheduler.notificationRequest(for: habit)) { error in
      XCTAssertEqual(error as? HabitReminderSchedulerError, .reminderMissing)
    }
  }
}
