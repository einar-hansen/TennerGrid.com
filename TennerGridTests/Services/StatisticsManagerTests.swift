import Combine
import XCTest
@testable import TennerGrid

// swiftlint:disable type_body_length file_length implicitly_unwrapped_optional force_unwrapping

final class StatisticsManagerTests: XCTestCase {
    // MARK: - Properties

    private var suiteName: String!
    private var userDefaults: UserDefaults!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        // Use a unique suite name for each test to avoid conflicts
        suiteName = "test.suite.\(UUID().uuidString)"
        userDefaults = UserDefaults(suiteName: suiteName)!

        // Clear any existing data
        userDefaults.removePersistentDomain(forName: suiteName)
    }

    override func tearDown() {
        // Clean up test suite
        userDefaults.removePersistentDomain(forName: suiteName)
        userDefaults = nil
        suiteName = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitializationWithNoSavedStatistics() {
        // Given: No saved statistics in UserDefaults
        // When: StatisticsManager is initialized
        let manager = createTestManager()

        // Then: Empty statistics should be loaded
        XCTAssertEqual(manager.statistics.gamesPlayed, 0)
        XCTAssertEqual(manager.statistics.gamesCompleted, 0)
        XCTAssertEqual(manager.statistics.totalTimePlayed, 0)
        XCTAssertNil(manager.statistics.bestTime)
    }

    func testInitializationWithSavedStatistics() {
        // Given: Statistics saved in UserDefaults
        var stats = GameStatistics()
        stats.recordGameStarted(difficulty: .easy)
        stats.recordGameCompleted(difficulty: .easy, time: 120, hintsUsed: 2, errors: 1)
        saveStatistics(stats)

        // When: StatisticsManager is initialized
        let manager = createTestManager()

        // Then: Saved statistics should be loaded
        XCTAssertEqual(manager.statistics.gamesPlayed, 1)
        XCTAssertEqual(manager.statistics.gamesCompleted, 1)
        XCTAssertEqual(manager.statistics.totalTimePlayed, 120)
    }

    func testInitializationWithCorruptedData() {
        // Given: Corrupted data in UserDefaults
        userDefaults.set("corrupted data", forKey: "com.tennergrid.gameStatistics")

        // When: StatisticsManager is initialized
        let manager = createTestManager()

        // Then: Empty statistics should be used as fallback
        XCTAssertEqual(manager.statistics.gamesPlayed, 0)
        XCTAssertEqual(manager.statistics.gamesCompleted, 0)
    }

    // MARK: - Recording Games Tests

    func testRecordGameStarted() {
        // Given: Manager with empty statistics
        let manager = createTestManager()
        XCTAssertEqual(manager.statistics.gamesPlayed, 0)

        // When: A game is started
        manager.recordGameStarted(difficulty: .medium)

        // Then: Games played should increment
        XCTAssertEqual(manager.statistics.gamesPlayed, 1)

        // And: Difficulty-specific stats should update
        let mediumStats = manager.statistics(for: .medium)
        XCTAssertEqual(mediumStats.played, 1)
        XCTAssertEqual(mediumStats.completed, 0)

        // And: Statistics should persist
        let loadedStats = loadStatistics()
        XCTAssertEqual(loadedStats?.gamesPlayed, 1)
    }

    func testRecordGameCompleted() {
        // Given: Manager with a started game
        let manager = createTestManager()
        manager.recordGameStarted(difficulty: .easy)

        // When: The game is completed
        manager.recordGameCompleted(difficulty: .easy, time: 180, hintsUsed: 3, errors: 2)

        // Then: Completion stats should update
        XCTAssertEqual(manager.statistics.gamesCompleted, 1)
        XCTAssertEqual(manager.statistics.totalTimePlayed, 180)
        XCTAssertEqual(manager.statistics.bestTime, 180)

        // And: Difficulty-specific stats should update
        let easyStats = manager.statistics(for: .easy)
        XCTAssertEqual(easyStats.completed, 1)
        XCTAssertEqual(easyStats.totalTime, 180)
        XCTAssertEqual(easyStats.totalHintsUsed, 3)
        XCTAssertEqual(easyStats.totalErrors, 2)
        XCTAssertEqual(easyStats.bestTime, 180)

        // And: Statistics should persist
        let loadedStats = loadStatistics()
        XCTAssertEqual(loadedStats?.gamesCompleted, 1)
        XCTAssertEqual(loadedStats?.totalTimePlayed, 180)
    }

    func testRecordMultipleGamesWithDifferentDifficulties() {
        // Given: Manager with empty statistics
        let manager = createTestManager()

        // When: Multiple games are played at different difficulties
        manager.recordGameStarted(difficulty: .easy)
        manager.recordGameCompleted(difficulty: .easy, time: 120)

        manager.recordGameStarted(difficulty: .medium)
        manager.recordGameCompleted(difficulty: .medium, time: 240)

        manager.recordGameStarted(difficulty: .hard)
        manager.recordGameCompleted(difficulty: .hard, time: 360)

        // Then: Overall stats should reflect all games
        XCTAssertEqual(manager.statistics.gamesPlayed, 3)
        XCTAssertEqual(manager.statistics.gamesCompleted, 3)
        XCTAssertEqual(manager.statistics.totalTimePlayed, 720)
        XCTAssertEqual(manager.statistics.bestTime, 120) // Easy game was fastest

        // And: Each difficulty should have its own stats
        XCTAssertEqual(manager.statistics(for: .easy).completed, 1)
        XCTAssertEqual(manager.statistics(for: .medium).completed, 1)
        XCTAssertEqual(manager.statistics(for: .hard).completed, 1)
    }

    // MARK: - Average Time Calculation Tests

    func testAverageCompletionTimeWithNoGames() {
        // Given: Manager with no completed games
        let manager = createTestManager()

        // When: Average time is requested
        let avgTime = manager.averageCompletionTime()

        // Then: Should return nil
        XCTAssertNil(avgTime)
    }

    func testAverageCompletionTimeWithOneGame() {
        // Given: Manager with one completed game
        let manager = createTestManager()
        manager.recordGameStarted(difficulty: .easy)
        manager.recordGameCompleted(difficulty: .easy, time: 180)

        // When: Average time is requested
        let avgTime = manager.averageCompletionTime()

        // Then: Should return the time of that one game
        XCTAssertEqual(avgTime, 180)
    }

    func testAverageCompletionTimeWithMultipleGames() {
        // Given: Manager with multiple completed games
        let manager = createTestManager()
        manager.recordGameStarted(difficulty: .easy)
        manager.recordGameCompleted(difficulty: .easy, time: 120)

        manager.recordGameStarted(difficulty: .easy)
        manager.recordGameCompleted(difficulty: .easy, time: 180)

        manager.recordGameStarted(difficulty: .easy)
        manager.recordGameCompleted(difficulty: .easy, time: 240)

        // When: Average time is requested
        let avgTime = manager.averageCompletionTime()

        // Then: Should return average of all games (120 + 180 + 240) / 3 = 180
        XCTAssertEqual(avgTime, 180)
    }

    func testAverageCompletionTimeForSpecificDifficulty() {
        // Given: Manager with games at different difficulties
        let manager = createTestManager()

        // Easy games: 120, 180 (avg = 150)
        manager.recordGameStarted(difficulty: .easy)
        manager.recordGameCompleted(difficulty: .easy, time: 120)
        manager.recordGameStarted(difficulty: .easy)
        manager.recordGameCompleted(difficulty: .easy, time: 180)

        // Hard games: 300, 400 (avg = 350)
        manager.recordGameStarted(difficulty: .hard)
        manager.recordGameCompleted(difficulty: .hard, time: 300)
        manager.recordGameStarted(difficulty: .hard)
        manager.recordGameCompleted(difficulty: .hard, time: 400)

        // When: Average time for each difficulty is requested
        let easyAvg = manager.averageCompletionTime(for: .easy)
        let hardAvg = manager.averageCompletionTime(for: .hard)
        let mediumAvg = manager.averageCompletionTime(for: .medium)

        // Then: Each should return correct average
        XCTAssertEqual(easyAvg, 150)
        XCTAssertEqual(hardAvg, 350)
        XCTAssertNil(mediumAvg) // No medium games played
    }

    // MARK: - Win Rate Calculation Tests

    func testOverallWinRateWithNoGames() {
        // Given: Manager with no games
        let manager = createTestManager()

        // When: Win rate is requested
        let winRate = manager.overallWinRate()

        // Then: Should return 0
        XCTAssertEqual(winRate, 0.0)
    }

    func testOverallWinRateWithAllWins() {
        // Given: Manager with all completed games
        let manager = createTestManager()
        manager.recordGameStarted(difficulty: .easy)
        manager.recordGameCompleted(difficulty: .easy, time: 120)

        manager.recordGameStarted(difficulty: .easy)
        manager.recordGameCompleted(difficulty: .easy, time: 180)

        // When: Win rate is requested
        let winRate = manager.overallWinRate()

        // Then: Should return 1.0 (100%)
        XCTAssertEqual(winRate, 1.0)
    }

    func testOverallWinRateWithPartialWins() {
        // Given: Manager with some completed and some abandoned games
        let manager = createTestManager()

        // Started 5 games, completed 3
        manager.recordGameStarted(difficulty: .easy)
        manager.recordGameCompleted(difficulty: .easy, time: 120)

        manager.recordGameStarted(difficulty: .easy)
        manager.recordGameStarted(difficulty: .easy)
        manager.recordGameCompleted(difficulty: .easy, time: 180)

        manager.recordGameStarted(difficulty: .easy)
        manager.recordGameStarted(difficulty: .easy)
        manager.recordGameCompleted(difficulty: .easy, time: 240)

        // When: Win rate is requested
        let winRate = manager.overallWinRate()

        // Then: Should return 0.6 (3/5 = 60%)
        XCTAssertEqual(winRate, 0.6, accuracy: 0.001)
    }

    func testWinRateForSpecificDifficulty() {
        // Given: Manager with games at different difficulties with different win rates
        let manager = createTestManager()

        // Easy: 2/3 completed (66.67%)
        manager.recordGameStarted(difficulty: .easy)
        manager.recordGameCompleted(difficulty: .easy, time: 120)
        manager.recordGameStarted(difficulty: .easy)
        manager.recordGameStarted(difficulty: .easy)
        manager.recordGameCompleted(difficulty: .easy, time: 180)

        // Hard: 1/2 completed (50%)
        manager.recordGameStarted(difficulty: .hard)
        manager.recordGameCompleted(difficulty: .hard, time: 300)
        manager.recordGameStarted(difficulty: .hard)

        // When: Win rate for each difficulty is requested
        let easyWinRate = manager.winRate(for: .easy)
        let hardWinRate = manager.winRate(for: .hard)
        let mediumWinRate = manager.winRate(for: .medium)

        // Then: Each should return correct win rate
        XCTAssertEqual(easyWinRate, 2.0 / 3.0, accuracy: 0.001)
        XCTAssertEqual(hardWinRate, 0.5, accuracy: 0.001)
        XCTAssertEqual(mediumWinRate, 0.0) // No medium games played
    }

    // MARK: - Best Time Tests

    func testBestTimeWithNoGames() {
        // Given: Manager with no completed games
        let manager = createTestManager()

        // When: Best time is requested
        let bestTime = manager.bestTime()

        // Then: Should return nil
        XCTAssertNil(bestTime)
    }

    func testBestTimeUpdatesCorrectly() {
        // Given: Manager with empty statistics
        let manager = createTestManager()

        // When: Games are completed with different times
        manager.recordGameStarted(difficulty: .easy)
        manager.recordGameCompleted(difficulty: .easy, time: 240)
        XCTAssertEqual(manager.bestTime(), 240)

        manager.recordGameStarted(difficulty: .easy)
        manager.recordGameCompleted(difficulty: .easy, time: 180) // New best
        XCTAssertEqual(manager.bestTime(), 180)

        manager.recordGameStarted(difficulty: .easy)
        manager.recordGameCompleted(difficulty: .easy, time: 300) // Slower, doesn't update
        XCTAssertEqual(manager.bestTime(), 180)

        manager.recordGameStarted(difficulty: .easy)
        manager.recordGameCompleted(difficulty: .easy, time: 120) // New best
        XCTAssertEqual(manager.bestTime(), 120)

        // Then: Best time should be the fastest
        XCTAssertEqual(manager.bestTime(), 120)
    }

    func testBestTimeForSpecificDifficulty() {
        // Given: Manager with games at different difficulties
        let manager = createTestManager()

        manager.recordGameStarted(difficulty: .easy)
        manager.recordGameCompleted(difficulty: .easy, time: 120)
        manager.recordGameStarted(difficulty: .easy)
        manager.recordGameCompleted(difficulty: .easy, time: 180)

        manager.recordGameStarted(difficulty: .hard)
        manager.recordGameCompleted(difficulty: .hard, time: 300)
        manager.recordGameStarted(difficulty: .hard)
        manager.recordGameCompleted(difficulty: .hard, time: 250)

        // When: Best time for each difficulty is requested
        let easyBest = manager.bestTime(for: .easy)
        let hardBest = manager.bestTime(for: .hard)
        let mediumBest = manager.bestTime(for: .medium)

        // Then: Each should return correct best time
        XCTAssertEqual(easyBest, 120)
        XCTAssertEqual(hardBest, 250)
        XCTAssertNil(mediumBest)
    }

    // MARK: - Streak Tests

    func testCurrentStreakStartsAtZero() {
        // Given: Manager with no games
        let manager = createTestManager()

        // Then: Current streak should be 0
        XCTAssertEqual(manager.currentStreak(), 0)
        XCTAssertEqual(manager.longestStreak(), 0)
        XCTAssertFalse(manager.hasActiveStreak())
    }

    func testStreakIncreasesWithGameStart() {
        // Given: Manager with no games
        let manager = createTestManager()

        // When: First game is started
        manager.recordGameStarted(difficulty: .easy)

        // Then: Streak should be 1
        XCTAssertEqual(manager.currentStreak(), 1)
        XCTAssertEqual(manager.longestStreak(), 1)
        XCTAssertTrue(manager.hasActiveStreak())
    }

    func testLongestStreakTracksMaximum() {
        // Given: Manager with simulated games over consecutive days
        let manager = createTestManager()

        // Simulate playing 3 consecutive days
        manager.recordGameStarted(difficulty: .easy)
        XCTAssertEqual(manager.currentStreak(), 1)
        XCTAssertEqual(manager.longestStreak(), 1)

        // Note: Streak logic is date-based and tested in GameStatistics
        // Here we verify the manager correctly exposes the values
        XCTAssertEqual(manager.longestStreak(), manager.statistics.longestStreak)
    }

    // MARK: - Total Stats Tests

    func testTotalGamesPlayed() {
        // Given: Manager with multiple games
        let manager = createTestManager()

        manager.recordGameStarted(difficulty: .easy)
        manager.recordGameStarted(difficulty: .medium)
        manager.recordGameStarted(difficulty: .hard)

        // When: Total games played is requested
        let total = manager.totalGamesPlayed()

        // Then: Should return sum of all games
        XCTAssertEqual(total, 3)
    }

    func testTotalGamesCompleted() {
        // Given: Manager with some completed games
        let manager = createTestManager()

        manager.recordGameStarted(difficulty: .easy)
        manager.recordGameCompleted(difficulty: .easy, time: 120)

        manager.recordGameStarted(difficulty: .easy)

        manager.recordGameStarted(difficulty: .medium)
        manager.recordGameCompleted(difficulty: .medium, time: 240)

        // When: Total games completed is requested
        let total = manager.totalGamesCompleted()

        // Then: Should return only completed games
        XCTAssertEqual(total, 2)
    }

    func testTotalTimePlayed() {
        // Given: Manager with multiple completed games
        let manager = createTestManager()

        manager.recordGameStarted(difficulty: .easy)
        manager.recordGameCompleted(difficulty: .easy, time: 120)

        manager.recordGameStarted(difficulty: .medium)
        manager.recordGameCompleted(difficulty: .medium, time: 240)

        manager.recordGameStarted(difficulty: .hard)
        manager.recordGameCompleted(difficulty: .hard, time: 360)

        // When: Total time played is requested
        let total = manager.totalTimePlayed()

        // Then: Should return sum of all completion times
        XCTAssertEqual(total, 720)
    }

    // MARK: - Difficulty Analysis Tests

    func testMostPlayedDifficultyWithNoGames() {
        // Given: Manager with no games
        let manager = createTestManager()

        // When: Most played difficulty is requested
        let mostPlayed = manager.mostPlayedDifficulty()

        // Then: Should return nil
        XCTAssertNil(mostPlayed)
    }

    func testMostPlayedDifficulty() {
        // Given: Manager with games at different difficulties
        let manager = createTestManager()

        // Play 1 hard, 3 easy, 2 medium
        manager.recordGameStarted(difficulty: .hard)
        manager.recordGameStarted(difficulty: .easy)
        manager.recordGameStarted(difficulty: .easy)
        manager.recordGameStarted(difficulty: .easy)
        manager.recordGameStarted(difficulty: .medium)
        manager.recordGameStarted(difficulty: .medium)

        // When: Most played difficulty is requested
        let mostPlayed = manager.mostPlayedDifficulty()

        // Then: Should return easy (3 games)
        XCTAssertEqual(mostPlayed, .easy)
    }

    func testDifficultiesByPlayCount() {
        // Given: Manager with games at different difficulties
        let manager = createTestManager()

        // Play 3 easy, 1 hard, 2 medium
        manager.recordGameStarted(difficulty: .easy)
        manager.recordGameStarted(difficulty: .easy)
        manager.recordGameStarted(difficulty: .easy)
        manager.recordGameStarted(difficulty: .hard)
        manager.recordGameStarted(difficulty: .medium)
        manager.recordGameStarted(difficulty: .medium)

        // When: Difficulties sorted by play count are requested
        let sorted = manager.difficultiesByPlayCount()

        // Then: Should return in descending order: easy, medium, hard
        XCTAssertEqual(sorted.count, 3)
        XCTAssertEqual(sorted[0], .easy)
        XCTAssertEqual(sorted[1], .medium)
        XCTAssertEqual(sorted[2], .hard)
    }

    // MARK: - Improvement Trend Tests

    func testImprovementTrendWithInsufficientData() {
        // Given: Manager with fewer than 3 completed games
        let manager = createTestManager()

        manager.recordGameStarted(difficulty: .easy)
        manager.recordGameCompleted(difficulty: .easy, time: 120)

        // When: Improvement trend is requested
        let trend = manager.improvementTrend(for: .easy)

        // Then: Should indicate not improving (insufficient data)
        XCTAssertFalse(trend.isImproving)
        XCTAssertEqual(trend.percentageChange, 0.0)
    }

    func testImprovementTrendWithConsistentPerformance() {
        // Given: Manager with 3+ games where average is close to best
        let manager = createTestManager()

        // Best time: 100, Average: (100 + 105 + 115) / 3 = 106.67
        // Percentage: (106.67 - 100) / 100 = 6.67% (within 20% threshold)
        manager.recordGameStarted(difficulty: .easy)
        manager.recordGameCompleted(difficulty: .easy, time: 100)

        manager.recordGameStarted(difficulty: .easy)
        manager.recordGameCompleted(difficulty: .easy, time: 105)

        manager.recordGameStarted(difficulty: .easy)
        manager.recordGameCompleted(difficulty: .easy, time: 115)

        // When: Improvement trend is requested
        let trend = manager.improvementTrend(for: .easy)

        // Then: Should indicate improving (average within 20% of best)
        XCTAssertTrue(trend.isImproving)
        XCTAssertLessThan(trend.percentageChange, 20)
    }

    func testImprovementTrendWithInconsistentPerformance() {
        // Given: Manager with 3+ games where average is far from best
        let manager = createTestManager()

        // Best time: 100, Average: (100 + 150 + 200) / 3 = 150
        // Percentage: (150 - 100) / 100 = 50% (exceeds 20% threshold)
        manager.recordGameStarted(difficulty: .easy)
        manager.recordGameCompleted(difficulty: .easy, time: 100)

        manager.recordGameStarted(difficulty: .easy)
        manager.recordGameCompleted(difficulty: .easy, time: 150)

        manager.recordGameStarted(difficulty: .easy)
        manager.recordGameCompleted(difficulty: .easy, time: 200)

        // When: Improvement trend is requested
        let trend = manager.improvementTrend(for: .easy)

        // Then: Should indicate not improving (average more than 20% slower than best)
        XCTAssertFalse(trend.isImproving)
        XCTAssertGreaterThan(trend.percentageChange, 20)
    }

    // MARK: - Reset Tests

    func testResetAllStatistics() {
        // Given: Manager with recorded statistics
        let manager = createTestManager()

        manager.recordGameStarted(difficulty: .easy)
        manager.recordGameCompleted(difficulty: .easy, time: 120, hintsUsed: 2, errors: 1)
        manager.recordGameStarted(difficulty: .medium)
        manager.recordGameCompleted(difficulty: .medium, time: 240, hintsUsed: 3, errors: 2)

        XCTAssertEqual(manager.statistics.gamesPlayed, 2)
        XCTAssertEqual(manager.statistics.gamesCompleted, 2)

        // When: Statistics are reset
        manager.resetAllStatistics()

        // Then: All statistics should be cleared
        XCTAssertEqual(manager.statistics.gamesPlayed, 0)
        XCTAssertEqual(manager.statistics.gamesCompleted, 0)
        XCTAssertEqual(manager.statistics.totalTimePlayed, 0)
        XCTAssertNil(manager.statistics.bestTime)
        XCTAssertEqual(manager.statistics.currentStreak, 0)
        XCTAssertEqual(manager.statistics.longestStreak, 0)

        // And: Reset should persist
        let loadedStats = loadStatistics()
        XCTAssertEqual(loadedStats?.gamesPlayed, 0)
        XCTAssertEqual(loadedStats?.gamesCompleted, 0)
    }

    // MARK: - Persistence Tests

    func testStatisticsPersistence() {
        // Given: Manager with recorded statistics
        let manager1 = createTestManager()

        manager1.recordGameStarted(difficulty: .easy)
        manager1.recordGameCompleted(difficulty: .easy, time: 120, hintsUsed: 2, errors: 1)
        manager1.recordGameStarted(difficulty: .medium)
        manager1.recordGameCompleted(difficulty: .medium, time: 240, hintsUsed: 3, errors: 2)

        // When: Statistics are loaded again (simulating app restart)
        let manager2 = createTestManager()

        // Then: Same statistics should be loaded
        XCTAssertEqual(manager2.statistics.gamesPlayed, 2)
        XCTAssertEqual(manager2.statistics.gamesCompleted, 2)
        XCTAssertEqual(manager2.statistics.totalTimePlayed, 360)
        XCTAssertEqual(manager2.statistics.bestTime, 120)
    }

    func testMultipleOperationsPersist() {
        // Given: Manager with multiple operations
        let manager = createTestManager()

        // When: Multiple games are recorded
        for difficulty in [Difficulty.easy, .medium, .hard] {
            manager.recordGameStarted(difficulty: difficulty)
            manager.recordGameCompleted(difficulty: difficulty, time: 180, hintsUsed: 1, errors: 0)
        }

        // Then: All operations should persist
        let loadedStats = loadStatistics()
        XCTAssertEqual(loadedStats?.gamesPlayed, 3)
        XCTAssertEqual(loadedStats?.gamesCompleted, 3)
        XCTAssertEqual(loadedStats?.difficultyBreakdowns.count, 3)
    }

    // MARK: - Edge Cases

    func testStatisticsForDifficultyNeverPlayed() {
        // Given: Manager with some games played
        let manager = createTestManager()
        manager.recordGameStarted(difficulty: .easy)

        // When: Statistics for unplayed difficulty are requested
        let stats = manager.statistics(for: .hard)

        // Then: Should return empty statistics
        XCTAssertEqual(stats.played, 0)
        XCTAssertEqual(stats.completed, 0)
        XCTAssertEqual(stats.totalTime, 0)
        XCTAssertNil(stats.bestTime)
    }

    func testHintsAndErrorsTracking() {
        // Given: Manager with empty statistics
        let manager = createTestManager()

        // When: Games are completed with hints and errors
        manager.recordGameStarted(difficulty: .easy)
        manager.recordGameCompleted(difficulty: .easy, time: 120, hintsUsed: 3, errors: 2)

        manager.recordGameStarted(difficulty: .easy)
        manager.recordGameCompleted(difficulty: .easy, time: 180, hintsUsed: 1, errors: 4)

        // Then: Hints and errors should be tracked
        let easyStats = manager.statistics(for: .easy)
        XCTAssertEqual(easyStats.totalHintsUsed, 4) // 3 + 1
        XCTAssertEqual(easyStats.totalErrors, 6) // 2 + 4
        XCTAssertEqual(easyStats.averageHints, 2.0) // 4 / 2
        XCTAssertEqual(easyStats.averageErrors, 3.0) // 6 / 2
    }

    func testUpdateStreaksMethodExists() {
        // Given: Manager with statistics
        let manager = createTestManager()

        // When: updateStreaks is called
        manager.updateStreaks()

        // Then: Should not crash (this method exists for future use)
        // Streak updates are already handled by recordGameStarted
    }

    // MARK: - Helper Methods

    /// Creates a test manager instance that uses the test UserDefaults
    private func createTestManager() -> TestStatisticsManager {
        TestStatisticsManager(userDefaults: userDefaults)
    }

    /// Saves statistics directly to test UserDefaults
    private func saveStatistics(_ statistics: GameStatistics) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(statistics)
            userDefaults.set(data, forKey: "com.tennergrid.gameStatistics")
        } catch {
            XCTFail("Failed to save test statistics: \(error)")
        }
    }

    /// Loads statistics directly from test UserDefaults
    private func loadStatistics() -> GameStatistics? {
        guard let data = userDefaults.data(forKey: "com.tennergrid.gameStatistics") else {
            return nil
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode(GameStatistics.self, from: data)
        } catch {
            XCTFail("Failed to load test statistics: \(error)")
            return nil
        }
    }
}

// MARK: - Test Statistics Manager

/// Test version of StatisticsManager that uses a custom UserDefaults
private final class TestStatisticsManager: ObservableObject {
    @Published private(set) var statistics: GameStatistics
    private let userDefaults: UserDefaults
    private let statisticsKey = "com.tennergrid.gameStatistics"

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
        self.statistics = TestStatisticsManager.loadStatistics(from: userDefaults) ?? GameStatistics()
    }

    func recordGameStarted(difficulty: Difficulty) {
        statistics.recordGameStarted(difficulty: difficulty)
        saveStatistics()
    }

    func recordGameCompleted(
        difficulty: Difficulty,
        time: TimeInterval,
        hintsUsed: Int = 0,
        errors: Int = 0
    ) {
        statistics.recordGameCompleted(
            difficulty: difficulty,
            time: time,
            hintsUsed: hintsUsed,
            errors: errors
        )
        saveStatistics()
    }

    func updateStreaks() {
        saveStatistics()
    }

    func statistics(for difficulty: Difficulty) -> GameStatistics.DifficultyStatistics {
        statistics.statistics(for: difficulty)
    }

    func averageCompletionTime() -> TimeInterval? {
        statistics.averageTime
    }

    func averageCompletionTime(for difficulty: Difficulty) -> TimeInterval? {
        statistics.statistics(for: difficulty).averageTime
    }

    func overallWinRate() -> Double {
        statistics.winRate
    }

    func winRate(for difficulty: Difficulty) -> Double {
        statistics.statistics(for: difficulty).winRate
    }

    func currentStreak() -> Int {
        statistics.currentStreak
    }

    func longestStreak() -> Int {
        statistics.longestStreak
    }

    func hasActiveStreak() -> Bool {
        statistics.hasActiveStreak()
    }

    func mostPlayedDifficulty() -> Difficulty? {
        statistics.mostPlayedDifficulty()
    }

    func difficultiesByPlayCount() -> [Difficulty] {
        statistics.difficultiesByPlayCount()
    }

    func improvementTrend(for difficulty: Difficulty) -> StatisticsManager.ImprovementTrend {
        let stats = statistics.statistics(for: difficulty)

        guard let avgTime = stats.averageTime,
              let bestTime = stats.bestTime,
              stats.completed >= 3
        else {
            return StatisticsManager.ImprovementTrend(isImproving: false, percentageChange: 0.0)
        }

        let percentageChange = ((avgTime - bestTime) / bestTime) * 100
        let isImproving = percentageChange <= 20

        return StatisticsManager.ImprovementTrend(isImproving: isImproving, percentageChange: percentageChange)
    }

    func totalGamesPlayed() -> Int {
        statistics.gamesPlayed
    }

    func totalGamesCompleted() -> Int {
        statistics.gamesCompleted
    }

    func totalTimePlayed() -> TimeInterval {
        statistics.totalTimePlayed
    }

    func bestTime() -> TimeInterval? {
        statistics.bestTime
    }

    func bestTime(for difficulty: Difficulty) -> TimeInterval? {
        statistics.statistics(for: difficulty).bestTime
    }

    func resetAllStatistics() {
        statistics.reset()
        saveStatistics()
    }

    private func saveStatistics() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(statistics)
            userDefaults.set(data, forKey: statisticsKey)
        } catch {
            // swiftlint:disable:next no_print
            print("Failed to save statistics: \(error.localizedDescription)")
        }
    }

    private static func loadStatistics(from userDefaults: UserDefaults) -> GameStatistics? {
        guard let data = userDefaults.data(forKey: "com.tennergrid.gameStatistics") else {
            return nil
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode(GameStatistics.self, from: data)
        } catch {
            // swiftlint:disable:next no_print
            print("Failed to load statistics: \(error.localizedDescription)")
            return nil
        }
    }
}
