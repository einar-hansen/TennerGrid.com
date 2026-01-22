//
//  GameStatistics.swift
//  TennerGrid
//
//  Created by Claude on 2026-01-22.
//

import Foundation

/// Represents aggregated statistics about games played
struct GameStatistics: Equatable, Codable {
    /// Total number of games started
    var gamesPlayed: Int

    /// Total number of games completed successfully
    var gamesCompleted: Int

    /// Total time spent playing across all games (in seconds)
    var totalTimePlayed: TimeInterval

    /// Best (fastest) completion time (in seconds, nil if no games completed)
    var bestTime: TimeInterval?

    /// Statistics broken down by difficulty level
    var difficultyBreakdowns: [Difficulty: DifficultyStatistics]

    /// Current streak of consecutive days played
    var currentStreak: Int

    /// Longest streak of consecutive days played
    var longestStreak: Int

    /// Last date a game was played
    var lastPlayedDate: Date?

    /// Date when statistics tracking started
    let createdAt: Date

    /// Creates new empty statistics
    /// - Parameter createdAt: When statistics tracking started (defaults to now)
    init(createdAt: Date = Date()) {
        gamesPlayed = 0
        gamesCompleted = 0
        totalTimePlayed = 0
        bestTime = nil
        difficultyBreakdowns = [:]
        currentStreak = 0
        longestStreak = 0
        lastPlayedDate = nil
        self.createdAt = createdAt
    }
}

// MARK: - DifficultyStatistics

extension GameStatistics {
    /// Statistics for a specific difficulty level
    struct DifficultyStatistics: Equatable, Codable {
        /// Number of games played at this difficulty
        var played: Int

        /// Number of games completed at this difficulty
        var completed: Int

        /// Total time spent on this difficulty (in seconds)
        var totalTime: TimeInterval

        /// Best completion time for this difficulty (in seconds)
        var bestTime: TimeInterval?

        /// Total hints used across all games at this difficulty
        var totalHintsUsed: Int

        /// Total errors made across all games at this difficulty
        var totalErrors: Int

        /// Creates new empty difficulty statistics
        init() {
            played = 0
            completed = 0
            totalTime = 0
            bestTime = nil
            totalHintsUsed = 0
            totalErrors = 0
        }

        /// Win rate for this difficulty (0.0 to 1.0)
        var winRate: Double {
            guard played > 0 else { return 0.0 }
            return Double(completed) / Double(played)
        }

        /// Average completion time for this difficulty (in seconds)
        var averageTime: TimeInterval? {
            guard completed > 0 else { return nil }
            return totalTime / Double(completed)
        }

        /// Average hints used per completed game
        var averageHints: Double {
            guard completed > 0 else { return 0.0 }
            return Double(totalHintsUsed) / Double(completed)
        }

        /// Average errors per completed game
        var averageErrors: Double {
            guard completed > 0 else { return 0.0 }
            return Double(totalErrors) / Double(completed)
        }
    }
}

// MARK: - Computed Properties

extension GameStatistics {
    /// Overall win rate across all difficulties (0.0 to 1.0)
    var winRate: Double {
        guard gamesPlayed > 0 else { return 0.0 }
        return Double(gamesCompleted) / Double(gamesPlayed)
    }

    /// Average time per completed game (in seconds)
    var averageTime: TimeInterval? {
        guard gamesCompleted > 0 else { return nil }
        return totalTimePlayed / Double(gamesCompleted)
    }

    /// Win rate as a percentage string (e.g., "85.5%")
    var winRatePercentage: String {
        String(format: "%.1f%%", winRate * 100)
    }

    /// Formatted total time played (e.g., "2h 15m")
    var formattedTotalTime: String {
        formatDuration(totalTimePlayed)
    }

    /// Formatted average time (e.g., "12:34")
    var formattedAverageTime: String? {
        guard let avgTime = averageTime else { return nil }
        return formatTime(avgTime)
    }

    /// Formatted best time (e.g., "05:23")
    var formattedBestTime: String? {
        guard let time = bestTime else { return nil }
        return formatTime(time)
    }

    /// Total hints used across all games
    var totalHintsUsed: Int {
        difficultyBreakdowns.values.reduce(0) { $0 + $1.totalHintsUsed }
    }

    /// Total errors made across all games
    var totalErrors: Int {
        difficultyBreakdowns.values.reduce(0) { $0 + $1.totalErrors }
    }

    /// Number of different difficulties played
    var difficultiesPlayed: Int {
        difficultyBreakdowns.count
    }
}

// MARK: - Recording Game Results

extension GameStatistics {
    /// Records a game start
    /// - Parameter difficulty: The difficulty of the started game
    mutating func recordGameStarted(difficulty: Difficulty) {
        gamesPlayed += 1

        var stats = difficultyBreakdowns[difficulty] ?? DifficultyStatistics()
        stats.played += 1
        difficultyBreakdowns[difficulty] = stats

        updatePlayedDate()
    }

    /// Records a completed game
    /// - Parameters:
    ///   - difficulty: The difficulty of the completed game
    ///   - time: Time taken to complete the game (in seconds)
    ///   - hintsUsed: Number of hints used
    ///   - errors: Number of errors made
    mutating func recordGameCompleted(
        difficulty: Difficulty,
        time: TimeInterval,
        hintsUsed: Int,
        errors: Int
    ) {
        gamesCompleted += 1
        totalTimePlayed += time

        // Update best time
        if let currentBest = bestTime {
            if time < currentBest {
                bestTime = time
            }
        } else {
            bestTime = time
        }

        // Update difficulty-specific statistics
        var stats = difficultyBreakdowns[difficulty] ?? DifficultyStatistics()
        stats.completed += 1
        stats.totalTime += time
        stats.totalHintsUsed += hintsUsed
        stats.totalErrors += errors

        // Update difficulty best time
        if let currentBest = stats.bestTime {
            if time < currentBest {
                stats.bestTime = time
            }
        } else {
            stats.bestTime = time
        }

        difficultyBreakdowns[difficulty] = stats
    }

    /// Updates the last played date and recalculates streaks
    private mutating func updatePlayedDate() {
        let today = Calendar.current.startOfDay(for: Date())

        if let lastPlayed = lastPlayedDate {
            let lastPlayedDay = Calendar.current.startOfDay(for: lastPlayed)
            let daysBetween = Calendar.current.dateComponents(
                [.day],
                from: lastPlayedDay,
                to: today
            ).day ?? 0

            if daysBetween == 1 {
                // Consecutive day - increment streak
                currentStreak += 1
                if currentStreak > longestStreak {
                    longestStreak = currentStreak
                }
            } else if daysBetween > 1 {
                // Streak broken - reset to 1
                currentStreak = 1
            }
            // If daysBetween == 0, already played today, don't change streak
        } else {
            // First game ever
            currentStreak = 1
            longestStreak = 1
        }

        lastPlayedDate = today
    }

    /// Resets all statistics to initial values
    mutating func reset() {
        gamesPlayed = 0
        gamesCompleted = 0
        totalTimePlayed = 0
        bestTime = nil
        difficultyBreakdowns = [:]
        currentStreak = 0
        longestStreak = 0
        lastPlayedDate = nil
    }
}

// MARK: - Query Methods

extension GameStatistics {
    /// Gets statistics for a specific difficulty
    /// - Parameter difficulty: The difficulty level
    /// - Returns: Statistics for that difficulty, or empty stats if none recorded
    func statistics(for difficulty: Difficulty) -> DifficultyStatistics {
        difficultyBreakdowns[difficulty] ?? DifficultyStatistics()
    }

    /// Checks if any games have been played at a specific difficulty
    /// - Parameter difficulty: The difficulty level
    /// - Returns: True if games have been played at this difficulty
    func hasPlayed(difficulty: Difficulty) -> Bool {
        guard let stats = difficultyBreakdowns[difficulty] else { return false }
        return stats.played > 0
    }

    /// Gets all difficulties sorted by number of games played (descending)
    /// - Returns: Array of difficulties sorted by play count
    func difficultiesByPlayCount() -> [Difficulty] {
        difficultyBreakdowns.keys.sorted { difficulty1, difficulty2 in
            let count1 = difficultyBreakdowns[difficulty1]?.played ?? 0
            let count2 = difficultyBreakdowns[difficulty2]?.played ?? 0
            return count1 > count2
        }
    }

    /// Gets the most played difficulty
    /// - Returns: The difficulty with the most games played, or nil if no games played
    func mostPlayedDifficulty() -> Difficulty? {
        difficultiesByPlayCount().first
    }

    /// Checks if the user has an active streak
    /// - Returns: True if played yesterday or today
    func hasActiveStreak() -> Bool {
        guard let lastPlayed = lastPlayedDate else { return false }
        let today = Calendar.current.startOfDay(for: Date())
        let lastPlayedDay = Calendar.current.startOfDay(for: lastPlayed)
        let daysBetween = Calendar.current.dateComponents(
            [.day],
            from: lastPlayedDay,
            to: today
        ).day ?? 0
        return daysBetween <= 1
    }
}

// MARK: - Formatting Helpers

extension GameStatistics {
    /// Formats a time interval as MM:SS
    /// - Parameter time: Time in seconds
    /// - Returns: Formatted string
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    /// Formats a duration for display (e.g., "2h 15m" or "45m")
    /// - Parameter duration: Duration in seconds
    /// - Returns: Formatted string
    private func formatDuration(_ duration: TimeInterval) -> String {
        let totalMinutes = Int(duration) / 60
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Factory Methods

extension GameStatistics {
    /// Creates new empty statistics
    /// - Returns: A new GameStatistics instance
    static func new() -> GameStatistics {
        GameStatistics()
    }
}

// MARK: - CustomStringConvertible

extension GameStatistics: CustomStringConvertible {
    var description: String {
        """
        GameStatistics(
            games: \(gamesCompleted)/\(gamesPlayed),
            winRate: \(winRatePercentage),
            totalTime: \(formattedTotalTime),
            avgTime: \(formattedAverageTime ?? "N/A"),
            bestTime: \(formattedBestTime ?? "N/A"),
            streak: \(currentStreak) (best: \(longestStreak)),
            difficulties: \(difficultiesPlayed)
        )
        """
    }
}
