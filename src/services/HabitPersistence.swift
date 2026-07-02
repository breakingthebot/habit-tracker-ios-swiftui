//
// HabitPersistence.swift
// Persistence abstraction and UserDefaults-backed implementation for saved habits.
// Connects to: services/HabitStore.swift, models/Habit.swift, config/AppConstants.swift
// Created: 2026-07-01
//

import Foundation
import OSLog

protocol HabitPersisting {
  /// Loads all saved habits from the persistence layer.
  /// - Returns: The decoded habits, or an empty array when nothing has been stored yet.
  func loadHabits() throws -> [Habit]

  /// Saves the full set of habits to the persistence layer.
  /// - Parameter habits: The habits to encode and persist.
  func saveHabits(_ habits: [Habit]) throws
}

enum HabitPersistenceError: LocalizedError {
  case decodingFailed
  case encodingFailed

  var errorDescription: String? {
    switch self {
    case .decodingFailed:
      return "Saved habits could not be decoded."
    case .encodingFailed:
      return "Habits could not be encoded for storage."
    }
  }
}

struct UserDefaultsHabitPersistence: HabitPersisting {
  private let userDefaults: UserDefaults
  private let storageKey: String
  private let decoder: JSONDecoder
  private let encoder: JSONEncoder
  private let logger: Logger

  init(
    userDefaults: UserDefaults = UserDefaultsHabitPersistence.sharedUserDefaults(),
    storageKey: String = AppConstants.habitsStorageKey,
    decoder: JSONDecoder = JSONDecoder(),
    encoder: JSONEncoder = JSONEncoder(),
    logger: Logger = Logger(subsystem: "HabitTracker", category: "HabitPersistence")
  ) {
    self.userDefaults = userDefaults
    self.storageKey = storageKey
    self.decoder = decoder
    self.encoder = encoder
    self.logger = logger
  }

  /// Returns the shared app-group defaults store, falling back to `.standard` when unavailable.
  /// - Returns: The `UserDefaults` instance used by both the app and widget.
  static func sharedUserDefaults() -> UserDefaults {
    UserDefaults(suiteName: AppConstants.appGroupIdentifier) ?? .standard
  }

  /// Loads habits from `UserDefaults`.
  func loadHabits() throws -> [Habit] {
    guard let savedData = userDefaults.data(forKey: storageKey) else {
      logger.info("No saved habits found")
      return []
    }

    do {
      let habits = try decoder.decode([Habit].self, from: savedData)
      logger.info("Loaded \(habits.count, privacy: .public) persisted habits")
      return habits
    } catch {
      logger.error("Habit decoding failed: \(error.localizedDescription, privacy: .public)")
      throw HabitPersistenceError.decodingFailed
    }
  }

  /// Saves habits to `UserDefaults`.
  func saveHabits(_ habits: [Habit]) throws {
    do {
      let encodedHabits = try encoder.encode(habits)
      userDefaults.set(encodedHabits, forKey: storageKey)
      logger.info("Saved \(habits.count, privacy: .public) habits")
    } catch {
      logger.error("Habit encoding failed: \(error.localizedDescription, privacy: .public)")
      throw HabitPersistenceError.encodingFailed
    }
  }
}
