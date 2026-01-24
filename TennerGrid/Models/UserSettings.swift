import Foundation

/// User settings model for storing app preferences
/// Conforms to Codable for easy persistence to UserDefaults or file storage
struct UserSettings: Codable, Equatable {
    // MARK: - Game Settings

    /// Automatically highlight invalid moves
    var autoCheckErrors: Bool

    /// Display elapsed time during gameplay
    var showTimer: Bool

    /// Highlight all cells with the same number
    var highlightSameNumbers: Bool

    /// Vibrate on selections and actions
    var hapticFeedback: Bool

    /// Play sounds for actions and events
    var soundEffects: Bool

    // MARK: - Appearance Settings

    /// User's preferred theme (light, dark, or system)
    var themePreference: String

    /// Enable high contrast mode for better accessibility (useful for color-blind users)
    var highContrastMode: Bool

    // MARK: - Notification Settings

    /// Enable daily reminder notifications
    var dailyReminder: Bool

    // MARK: - Initialization

    /// Creates user settings with default values
    init(
        autoCheckErrors: Bool = true,
        showTimer: Bool = true,
        highlightSameNumbers: Bool = true,
        hapticFeedback: Bool = true,
        soundEffects: Bool = true,
        themePreference: String = "system",
        highContrastMode: Bool = false,
        dailyReminder: Bool = false
    ) {
        self.autoCheckErrors = autoCheckErrors
        self.showTimer = showTimer
        self.highlightSameNumbers = highlightSameNumbers
        self.hapticFeedback = hapticFeedback
        self.soundEffects = soundEffects
        self.themePreference = themePreference
        self.highContrastMode = highContrastMode
        self.dailyReminder = dailyReminder
    }
}

// MARK: - Default Settings

extension UserSettings {
    /// Default user settings
    static let `default` = UserSettings()

    /// Settings with all features enabled (for testing)
    static let allEnabled = UserSettings(
        autoCheckErrors: true,
        showTimer: true,
        highlightSameNumbers: true,
        hapticFeedback: true,
        soundEffects: true,
        themePreference: "system",
        highContrastMode: true,
        dailyReminder: true
    )

    /// Settings with all features disabled (for testing)
    static let allDisabled = UserSettings(
        autoCheckErrors: false,
        showTimer: false,
        highlightSameNumbers: false,
        hapticFeedback: false,
        soundEffects: false,
        themePreference: "system",
        highContrastMode: false,
        dailyReminder: false
    )
}
