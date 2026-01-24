import Foundation

/// Defines the persistence schema and data models for the app
/// Uses Codable + FileManager approach (iOS 16+ compatible)
enum PersistenceSchema {
    /// Current schema version for migrations
    static let currentVersion = 1

    /// Base directory for all app data
    static var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    /// App-specific data directory
    static var appDataDirectory: URL {
        documentsDirectory.appendingPathComponent("TennerGridData", isDirectory: true)
    }

    // MARK: - File Paths

    /// File paths for different data types
    enum FilePath {
        /// Path for saved game state
        static var savedGame: URL {
            appDataDirectory.appendingPathComponent("saved_game.json")
        }

        /// Path for statistics data
        static var statistics: URL {
            appDataDirectory.appendingPathComponent("statistics.json")
        }

        /// Path for achievements data
        static var achievements: URL {
            appDataDirectory.appendingPathComponent("achievements.json")
        }

        /// Path for user settings
        static var settings: URL {
            appDataDirectory.appendingPathComponent("settings.json")
        }

        /// Path for schema version tracking
        static var schemaVersion: URL {
            appDataDirectory.appendingPathComponent("schema_version.json")
        }
    }

    // MARK: - Data Models

    /// Wrapper for saved game state with metadata
    struct SavedGameData: Codable {
        /// Schema version for this data
        let schemaVersion: Int

        /// The game state
        let gameState: GameState

        /// When this save was created
        let savedAt: Date

        /// Creates a new saved game data
        /// - Parameter gameState: The game state to save
        init(gameState: GameState) {
            self.schemaVersion = PersistenceSchema.currentVersion
            self.gameState = gameState
            savedAt = Date()
        }
    }

    /// Wrapper for statistics with metadata
    struct StatisticsData: Codable {
        /// Schema version for this data
        let schemaVersion: Int

        /// The statistics
        let statistics: GameStatistics

        /// Last updated timestamp
        let updatedAt: Date

        /// Creates new statistics data
        /// - Parameter statistics: The statistics to save
        init(statistics: GameStatistics) {
            self.schemaVersion = PersistenceSchema.currentVersion
            self.statistics = statistics
            updatedAt = Date()
        }
    }

    /// Wrapper for achievements list with metadata
    struct AchievementsData: Codable {
        /// Schema version for this data
        let schemaVersion: Int

        /// List of achievements
        let achievements: [Achievement]

        /// Last updated timestamp
        let updatedAt: Date

        /// Creates new achievements data
        /// - Parameter achievements: The achievements to save
        init(achievements: [Achievement]) {
            self.schemaVersion = PersistenceSchema.currentVersion
            self.achievements = achievements
            updatedAt = Date()
        }
    }

    /// Wrapper for user settings with metadata
    struct SettingsData: Codable {
        /// Schema version for this data
        let schemaVersion: Int

        /// The settings
        let settings: UserSettings

        /// Last updated timestamp
        let updatedAt: Date

        /// Creates new settings data
        /// - Parameter settings: The settings to save
        init(settings: UserSettings) {
            self.schemaVersion = PersistenceSchema.currentVersion
            self.settings = settings
            updatedAt = Date()
        }
    }

    /// Schema version information
    struct SchemaVersionData: Codable {
        /// Current schema version
        let version: Int

        /// When this version was set
        let setAt: Date

        /// Previous version (for migration tracking)
        let previousVersion: Int?

        /// Creates new schema version data
        /// - Parameters:
        ///   - version: The schema version
        ///   - previousVersion: The previous version (nil if first install)
        init(version: Int, previousVersion: Int? = nil) {
            self.version = version
            setAt = Date()
            self.previousVersion = previousVersion
        }
    }

    // MARK: - Migration Support

    /// Migration strategy for schema updates
    enum Migration {
        /// Migrates data from one version to another
        /// - Parameters:
        ///   - fromVersion: The source version
        ///   - toVersion: The target version
        ///   - data: The data to migrate
        /// - Returns: Migrated data
        /// - Throws: Migration error if migration fails
        static func migrate(fromVersion: Int, toVersion: Int, data: Data) throws -> Data {
            guard fromVersion < toVersion else {
                throw MigrationError.invalidVersions(from: fromVersion, to: toVersion)
            }

            var currentData = data
            var currentVersion = fromVersion

            // Apply migrations step by step
            while currentVersion < toVersion {
                switch currentVersion {
                case 0:
                    // Migrate from v0 to v1
                    currentData = try migrateV0ToV1(data: currentData)
                default:
                    // No migration needed or unknown version
                    break
                }
                currentVersion += 1
            }

            return currentData
        }

        /// Migrates from version 0 to version 1
        /// - Parameter data: The v0 data
        /// - Returns: The v1 data
        /// - Throws: Migration error if migration fails
        private static func migrateV0ToV1(data: Data) throws -> Data {
            // First version - no actual migration needed
            // This is a placeholder for future migrations
            data
        }
    }

    /// Migration errors
    enum MigrationError: Error, LocalizedError {
        case invalidVersions(from: Int, to: Int)
        case migrationFailed(version: Int, underlyingError: Error?)
        case corruptedData

        var errorDescription: String? {
            switch self {
            case let .invalidVersions(from, to):
                return "Invalid migration versions: from \(from) to \(to)"
            case let .migrationFailed(version, error):
                let errorMsg = error?.localizedDescription ?? "unknown error"
                return "Migration to version \(version) failed: \(errorMsg)"
            case .corruptedData:
                return "Data is corrupted and cannot be migrated"
            }
        }
    }

    // MARK: - Setup

    /// Ensures the app data directory exists
    /// - Throws: File system error if directory cannot be created
    static func ensureDirectoryExists() throws {
        let fileManager = FileManager.default

        guard !fileManager.fileExists(atPath: appDataDirectory.path) else {
            return
        }

        try fileManager.createDirectory(
            at: appDataDirectory,
            withIntermediateDirectories: true,
            attributes: nil
        )
    }

    /// Initializes the persistence system
    /// - Throws: Setup error if initialization fails
    static func initialize() throws {
        try ensureDirectoryExists()

        // Check if schema version exists
        let versionPath = FilePath.schemaVersion
        if !FileManager.default.fileExists(atPath: versionPath.path) {
            // First launch - set current version
            let versionData = SchemaVersionData(version: currentVersion)
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(versionData)
            try data.write(to: versionPath)
        }
    }

    /// Gets the current schema version from disk
    /// - Returns: The schema version, or nil if not found
    static func getCurrentSchemaVersion() -> Int? {
        let versionPath = FilePath.schemaVersion
        guard FileManager.default.fileExists(atPath: versionPath.path) else {
            return nil
        }

        do {
            let data = try Data(contentsOf: versionPath)
            let decoder = JSONDecoder()
            let versionData = try decoder.decode(SchemaVersionData.self, from: data)
            return versionData.version
        } catch {
            return nil
        }
    }

    /// Updates the schema version on disk
    /// - Parameter newVersion: The new version to set
    /// - Throws: Write error if update fails
    static func updateSchemaVersion(to newVersion: Int) throws {
        let previousVersion = getCurrentSchemaVersion()
        let versionData = SchemaVersionData(version: newVersion, previousVersion: previousVersion)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(versionData)
        try data.write(to: FilePath.schemaVersion)
    }
}

// MARK: - File Management Extensions

extension PersistenceSchema {
    /// Checks if a file exists at a given path
    /// - Parameter path: The file URL
    /// - Returns: True if the file exists
    static func fileExists(at path: URL) -> Bool {
        FileManager.default.fileExists(atPath: path.path)
    }

    /// Deletes a file at a given path
    /// - Parameter path: The file URL
    /// - Throws: File system error if deletion fails
    static func deleteFile(at path: URL) throws {
        guard fileExists(at: path) else { return }
        try FileManager.default.removeItem(at: path)
    }

    /// Gets the size of a file in bytes
    /// - Parameter path: The file URL
    /// - Returns: File size in bytes, or nil if file doesn't exist
    static func fileSize(at path: URL) -> Int? {
        guard fileExists(at: path) else { return nil }
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: path.path) else {
            return nil
        }
        return attributes[.size] as? Int
    }

    /// Gets the modification date of a file
    /// - Parameter path: The file URL
    /// - Returns: Modification date, or nil if file doesn't exist
    static func modificationDate(at path: URL) -> Date? {
        guard fileExists(at: path) else { return nil }
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: path.path) else {
            return nil
        }
        return attributes[.modificationDate] as? Date
    }
}

// MARK: - Backup Support

extension PersistenceSchema {
    /// Creates a backup of all data files
    /// - Returns: URL of the backup directory
    /// - Throws: File system error if backup fails
    @discardableResult
    static func createBackup() throws -> URL {
        let backupDir = documentsDirectory.appendingPathComponent("Backups", isDirectory: true)
        try FileManager.default.createDirectory(
            at: backupDir,
            withIntermediateDirectories: true,
            attributes: nil
        )

        let timestamp = ISO8601DateFormatter().string(from: Date())
        let backupPath = backupDir.appendingPathComponent("backup_\(timestamp)", isDirectory: true)

        try FileManager.default.copyItem(at: appDataDirectory, to: backupPath)

        return backupPath
    }

    /// Restores data from a backup directory
    /// - Parameter backupURL: The backup directory URL
    /// - Throws: File system error if restore fails
    static func restoreFromBackup(_ backupURL: URL) throws {
        // Delete current data
        if fileExists(at: appDataDirectory) {
            try FileManager.default.removeItem(at: appDataDirectory)
        }

        // Copy backup to app data directory
        try FileManager.default.copyItem(at: backupURL, to: appDataDirectory)
    }

    /// Lists all available backups
    /// - Returns: Array of backup directory URLs
    static func listBackups() -> [URL] {
        let backupDir = documentsDirectory.appendingPathComponent("Backups", isDirectory: true)
        guard fileExists(at: backupDir) else { return [] }

        guard let contents = try? FileManager.default.contentsOfDirectory(
            at: backupDir,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        return contents.filter { url in
            guard let resourceValues = try? url.resourceValues(forKeys: [.isDirectoryKey]) else {
                return false
            }
            return resourceValues.isDirectory ?? false
        }.sorted { $0.lastPathComponent > $1.lastPathComponent }
    }
}
