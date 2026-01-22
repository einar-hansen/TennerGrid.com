//
//  PuzzleSolver.swift
//  TennerGrid
//
//  Created by Claude on 2026-01-22.
//

import Foundation

/// Service responsible for solving Tenner Grid puzzles using backtracking algorithm
struct PuzzleSolver {
    private let validationService = ValidationService()

    /// Solves a Tenner Grid puzzle using backtracking algorithm
    /// - Parameters:
    ///   - puzzle: The puzzle to solve
    ///   - initialGrid: The initial grid state (optional, defaults to puzzle's initial grid)
    /// - Returns: The solved grid if a solution exists, nil if no solution is found
    func solve(puzzle: TennerGridPuzzle, initialGrid: [[Int?]]? = nil) -> [[Int]]? {
        var grid = initialGrid ?? puzzle.initialGrid

        // Validate dimensions match
        guard grid.count == puzzle.rows,
              grid.allSatisfy({ $0.count == puzzle.columns })
        else {
            return nil
        }

        guard solveBacktrack(grid: &grid, puzzle: puzzle) else {
            return nil
        }

        // Convert [[Int?]] to [[Int]] - we know all cells are filled after successful solve
        return grid.map { row in
            row.compactMap { $0 }
        }
    }

    /// Recursive backtracking algorithm to solve the puzzle
    /// - Parameters:
    ///   - grid: The current grid state (will be modified in place)
    ///   - puzzle: The puzzle definition
    /// - Returns: True if solution is found, false otherwise
    private func solveBacktrack(grid: inout [[Int?]], puzzle: TennerGridPuzzle) -> Bool {
        // Find next empty cell
        guard let position = findNextEmptyCell(in: grid, puzzle: puzzle) else {
            // No empty cells left - check if solution is valid
            return validationService.isPuzzleComplete(grid: grid, puzzle: puzzle)
        }

        // Try values 0-9
        for value in 0 ... 9 {
            // Check if this value is valid at this position
            if validationService.isValidPlacement(
                value: value,
                at: position,
                in: grid,
                puzzle: puzzle
            ) {
                // Place the value
                grid[position.row][position.column] = value

                // Apply constraint propagation (early pruning)
                if canColumnSumBeReached(column: position.column, in: grid, puzzle: puzzle) {
                    // Recursively try to solve the rest
                    if solveBacktrack(grid: &grid, puzzle: puzzle) {
                        return true
                    }
                }

                // Backtrack - remove the value
                grid[position.row][position.column] = nil
            }
        }

        // No valid value found for this cell
        return false
    }

    /// Finds the next empty cell in the grid
    /// - Parameters:
    ///   - grid: The current grid state
    ///   - puzzle: The puzzle definition
    /// - Returns: Position of the next empty cell, or nil if grid is full
    private func findNextEmptyCell(in grid: [[Int?]], puzzle: TennerGridPuzzle) -> CellPosition? {
        for row in 0 ..< puzzle.rows {
            for column in 0 ..< puzzle.columns {
                if grid[row][column] == nil {
                    return CellPosition(row: row, column: column)
                }
            }
        }
        return nil
    }

    /// Constraint propagation: checks if a column sum can still reach the target
    /// This is an early pruning optimization to avoid exploring invalid branches
    /// - Parameters:
    ///   - column: The column index to check
    ///   - grid: The current grid state
    ///   - puzzle: The puzzle definition
    /// - Returns: True if the column sum can potentially reach the target, false if it's impossible
    private func canColumnSumBeReached(column: Int, in grid: [[Int?]], puzzle: TennerGridPuzzle) -> Bool {
        guard column >= 0, column < puzzle.columns else { return false }
        guard column < puzzle.targetSums.count else { return false }

        let targetSum = puzzle.targetSums[column]
        var currentSum = 0
        var emptyCount = 0

        // Calculate current sum and count empty cells
        for row in 0 ..< puzzle.rows {
            if let value = grid[row][column] {
                currentSum += value
            } else {
                emptyCount += 1
            }
        }

        // If column is fully filled, check if sum matches target
        if emptyCount == 0 {
            return currentSum == targetSum
        }

        // Check if current sum already exceeds target (impossible to reach)
        if currentSum > targetSum {
            return false
        }

        // Check if we can reach the target with remaining cells
        // Minimum possible: current sum + (empty cells * 0)
        // Maximum possible: current sum + (empty cells * 9)
        let remainingSum = targetSum - currentSum
        let maxPossible = emptyCount * 9
        let minPossible = 0

        // The target is reachable if it's within the possible range
        return remainingSum >= minPossible && remainingSum <= maxPossible
    }
}
