import Combine
import Foundation

/// Service for managing user settings persistence
/// Handles saving and loading settings to/from UserDefaults
final class SettingsManager: ObservableObject {
    // MARK: - Properties

    /// Shared singleton instance
    static let shared = SettingsManager()

    /// Published current user settings
    @Published private(set) var settings: UserSettings

    /// Key for storing settings in UserDefaults
    private let settingsKey = "com.tennergrid.userSettings"

    // MARK: - Initialization

    /// Private initializer to enforce singleton pattern
    private init() {
        // Load settings from UserDefaults or use default
        self.settings = SettingsManager.loadSettings() ?? .default
    }

    // MARK: - Public Methods

    /// Updates settings and persists changes
    /// - Parameter settings: The new settings to save
    func updateSettings(_ settings: UserSettings) {
        self.settings = settings
        saveSettings()
    }

    /// Updates a specific setting property and persists changes
    /// - Parameters:
    ///   - keyPath: The key path to the property to update
    ///   - value: The new value for the property
    func updateSetting<T>(_ keyPath: WritableKeyPath<UserSettings, T>, value: T) {
        settings[keyPath: keyPath] = value
        saveSettings()
    }

    /// Resets settings to default values
    func resetToDefaults() {
        settings = .default
        saveSettings()
    }

    // MARK: - Private Methods

    /// Saves current settings to UserDefaults
    private func saveSettings() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(settings)
            UserDefaults.standard.set(data, forKey: settingsKey)
        } catch {
            // swiftlint:disable:next no_print
            print("Failed to save settings: \(error.localizedDescription)")
        }
    }

    /// Loads settings from UserDefaults
    /// - Returns: UserSettings if found and decoded successfully, nil otherwise
    private static func loadSettings() -> UserSettings? {
        guard let data = UserDefaults.standard.data(forKey: "com.tennergrid.userSettings") else {
            return nil
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode(UserSettings.self, from: data)
        } catch {
            // swiftlint:disable:next no_print
            print("Failed to load settings: \(error.localizedDescription)")
            return nil
        }
    }
}
