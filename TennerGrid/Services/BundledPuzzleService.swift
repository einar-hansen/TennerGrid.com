//
//  BundledPuzzleService.swift
//  TennerGrid
//
//  Service for loading pre-generated puzzles from the app bundle.
//  These puzzles are used for offline play and as fallback when API is unavailable.
//

import Foundation

/// Response structure matching the API format
struct PuzzleResponse: Codable {
    let data: [[APIPuzzle]]
}

import CryptoKit

/// Puzzle structure matching the API format
struct APIPuzzle: Codable {
    let id: String
    let columns: Int
    let rows: Int
    let difficulty: String
    let targetSums: [Int]
    let initialGrid: [[Int?]]
    let solution: [[Int]]

    enum CodingKeys: String, CodingKey {
        case id, columns, rows, difficulty, solution
        case targetSums = "target_sums"
        case initialGrid = "initial_grid"
    }

    /// Converts to the app's TennerGridPuzzle model with a deterministic UUID
    func toPuzzle() -> TennerGridPuzzle {
        TennerGridPuzzle(
            id: deterministicUUID(from: id),
            columns: columns,
            rows: rows,
            difficulty: Difficulty(rawValue: difficulty) ?? .medium,
            targetSums: targetSums,
            initialGrid: initialGrid,
            solution: solution
        )
    }

    /// Creates a deterministic UUID from a string ID using SHA256
    private func deterministicUUID(from string: String) -> UUID {
        // First try to parse as UUID
        if let uuid = UUID(uuidString: string) {
            return uuid
        }

        // Otherwise generate a deterministic UUID from the string using SHA256
        let hash = SHA256.hash(data: Data(string.utf8))
        let hashBytes = Array(hash)

        // Use the first 16 bytes of the hash to create a UUID
        var uuidBytes = Array(hashBytes.prefix(16))

        // Set version 4 (random) UUID variant bits
        uuidBytes[6] = (uuidBytes[6] & 0x0F) | 0x40  // Version 4
        uuidBytes[8] = (uuidBytes[8] & 0x3F) | 0x80  // Variant 1

        return UUID(uuid: (
            uuidBytes[0], uuidBytes[1], uuidBytes[2], uuidBytes[3],
            uuidBytes[4], uuidBytes[5], uuidBytes[6], uuidBytes[7],
            uuidBytes[8], uuidBytes[9], uuidBytes[10], uuidBytes[11],
            uuidBytes[12], uuidBytes[13], uuidBytes[14], uuidBytes[15]
        ))
    }
}

/// Service for loading and querying bundled puzzles
final class BundledPuzzleService {
    /// Shared instance for app-wide use
    static let shared = BundledPuzzleService()

    /// All loaded puzzles
    private var puzzles: [APIPuzzle] = []

    /// Puzzles indexed by difficulty and rows for fast lookup
    private var puzzleIndex: [String: [APIPuzzle]] = [:]

    /// Whether puzzles have been loaded
    private(set) var isLoaded = false

    private init() {
        loadPuzzles()
    }

    /// Loads puzzles from the app bundle
    private func loadPuzzles() {
        guard let url = Bundle.main.url(forResource: "BundledPuzzles", withExtension: "json") else {
            print("BundledPuzzleService: BundledPuzzles.json not found in bundle")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let response = try JSONDecoder().decode(PuzzleResponse.self, from: data)

            // Flatten the nested array structure
            puzzles = response.data.flatMap { $0 }

            // Build index for fast lookup
            buildIndex()

            isLoaded = true
            print("BundledPuzzleService: Loaded \(puzzles.count) puzzles")
        } catch {
            print("BundledPuzzleService: Failed to load puzzles: \(error)")
        }
    }

    /// Builds an index for fast puzzle lookup by difficulty and rows
    private func buildIndex() {
        puzzleIndex = [:]
        for puzzle in puzzles {
            let key = "\(puzzle.difficulty)_\(puzzle.rows)"
            puzzleIndex[key, default: []].append(puzzle)
        }
    }

    /// Returns a random puzzle matching the criteria
    /// - Parameters:
    ///   - difficulty: Desired difficulty level
    ///   - rows: Number of rows (3-7)
    /// - Returns: A random puzzle matching the criteria, or nil if none found
    func randomPuzzle(difficulty: Difficulty, rows: Int = 5) -> TennerGridPuzzle? {
        let key = "\(difficulty.rawValue)_\(rows)"
        guard let matching = puzzleIndex[key], !matching.isEmpty else {
            return nil
        }
        return matching.randomElement()?.toPuzzle()
    }

    /// Returns a specific puzzle by ID
    /// - Parameter id: The puzzle ID
    /// - Returns: The puzzle if found, nil otherwise
    func puzzle(byId id: String) -> TennerGridPuzzle? {
        puzzles.first { $0.id == id }?.toPuzzle()
    }

    /// Returns all puzzles matching the criteria
    /// - Parameters:
    ///   - difficulty: Optional difficulty filter
    ///   - rows: Optional rows filter
    /// - Returns: Array of matching puzzles
    func puzzles(difficulty: Difficulty? = nil, rows: Int? = nil) -> [TennerGridPuzzle] {
        var filtered = puzzles

        if let difficulty = difficulty {
            filtered = filtered.filter { $0.difficulty == difficulty.rawValue }
        }

        if let rows = rows {
            filtered = filtered.filter { $0.rows == rows }
        }

        return filtered.map { $0.toPuzzle() }
    }

    /// Returns the first puzzle matching the criteria (useful for tests)
    /// - Parameters:
    ///   - difficulty: Desired difficulty level
    ///   - rows: Number of rows
    /// - Returns: The first matching puzzle, or nil if none found
    func firstPuzzle(difficulty: Difficulty, rows: Int = 5) -> TennerGridPuzzle? {
        let key = "\(difficulty.rawValue)_\(rows)"
        return puzzleIndex[key]?.first?.toPuzzle()
    }

    /// Returns available row counts for a difficulty
    func availableRows(for difficulty: Difficulty) -> [Int] {
        puzzles
            .filter { $0.difficulty == difficulty.rawValue }
            .map { $0.rows }
            .unique()
            .sorted()
    }

    /// Total number of loaded puzzles
    var count: Int {
        puzzles.count
    }
}

// MARK: - Array Extension

private extension Array where Element: Hashable {
    func unique() -> [Element] {
        Array(Set(self))
    }
}
