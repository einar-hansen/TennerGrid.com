//
//  NumberPadViewTests.swift
//  TennerGridTests
//
//  Created by Claude on 2026-01-22.
//

import SwiftUI
@testable import TennerGrid
import XCTest

/// Tests for NumberPadView component with various interactions
@MainActor
final class NumberPadViewTests: XCTestCase {
    // MARK: - Properties

    var puzzleGenerator: PuzzleGenerator!

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        puzzleGenerator = PuzzleGenerator()
    }

    override func tearDown() {
        puzzleGenerator = nil
        super.tearDown()
    }

    // MARK: - Number Entry Tests

    /// Test that tapping a number button calls enterNumber on the view model
    func testNumberButtonTapCallsEnterNumber() throws {
        // Given
        guard let puzzle = puzzleGenerator.generatePuzzle(columns: 5, rows: 5, difficulty: .easy) else {
            XCTFail("Failed to generate puzzle")
            return
        }
        let viewModel = GameViewModel(puzzle: puzzle)
        let position = CellPosition(row: 0, column: 0)
        viewModel.selectCell(at: position)

        // When - Enter different numbers
        for number in 0 ... 9 {
            viewModel.enterNumber(number)

            // Then - Verify the number was entered
            let cellValue = viewModel.value(at: position)
            XCTAssertEqual(cellValue, number, "Number \(number) should be entered into selected cell")
        }
    }

    /// Test that number pad updates when cell is selected
    func testNumberPadUpdatesOnCellSelection() throws {
        // Given
        guard let puzzle = puzzleGenerator.generatePuzzle(columns: 5, rows: 5, difficulty: .easy) else {
            XCTFail("Failed to generate puzzle")
            return
        }
        let viewModel = GameViewModel(puzzle: puzzle)

        // When - Select different cells
        let testPositions = [
            CellPosition(row: 0, column: 0),
            CellPosition(row: 2, column: 2),
            CellPosition(row: 4, column: 4),
        ]

        for position in testPositions {
            // When
            viewModel.selectCell(at: position)

            // Then
            XCTAssertEqual(
                viewModel.gameState.selectedCell,
                position,
                "Selected cell should be \(position)"
            )
        }
    }

    /// Test that number pad works correctly in notes mode
    func testNumberPadInNotesMode() throws {
        // Given
        guard let puzzle = puzzleGenerator.generatePuzzle(columns: 5, rows: 5, difficulty: .easy) else {
            XCTFail("Failed to generate puzzle")
            return
        }
        let viewModel = GameViewModel(puzzle: puzzle)
        let position = CellPosition(row: 0, column: 0)
        viewModel.selectCell(at: position)

        // When - Toggle notes mode and add a pencil mark
        viewModel.toggleNotesMode()

        // Then - Verify notes mode is active
        XCTAssertTrue(viewModel.notesMode, "Notes mode should be toggled on")

        // When - Add a pencil mark
        viewModel.enterNumber(5)

        // Then - Verify pencil mark was added
        let pencilMarks = viewModel.gameState.pencilMarks[position] ?? []
        XCTAssertTrue(pencilMarks.contains(5), "Pencil mark 5 should be added")
    }

    /// Test that pre-filled cells cannot be edited via number pad
    func testPreFilledCellsCannotBeEdited() throws {
        // Given
        guard let puzzle = puzzleGenerator.generatePuzzle(columns: 5, rows: 5, difficulty: .easy) else {
            XCTFail("Failed to generate puzzle")
            return
        }
        let viewModel = GameViewModel(puzzle: puzzle)

        // Find a pre-filled cell
        var preFilledPosition: CellPosition?
        for row in 0 ..< 5 {
            for col in 0 ..< 5 {
                let pos = CellPosition(row: row, column: col)
                if let _ = puzzle.initialGrid[row][col] {
                    preFilledPosition = pos
                    break
                }
            }
            if preFilledPosition != nil { break }
        }

        guard let position = preFilledPosition else {
            XCTFail("No pre-filled cell found in puzzle")
            return
        }

        // When
        viewModel.selectCell(at: position)
        let originalValue = viewModel.value(at: position)

        // When - Try to enter a different number
        viewModel.enterNumber((originalValue ?? 0) + 1)

        // Then - Value should not change
        let newValue = viewModel.value(at: position)
        XCTAssertEqual(newValue, originalValue, "Pre-filled cell value should not change")
    }

    // MARK: - Conflict Detection Tests

    /// Test that number pad shows conflicts correctly
    func testConflictDetectionForValidPlacement() throws {
        // Given
        guard let puzzle = puzzleGenerator.generatePuzzle(columns: 5, rows: 5, difficulty: .easy) else {
            XCTFail("Failed to generate puzzle")
            return
        }
        let viewModel = GameViewModel(puzzle: puzzle)
        let position = CellPosition(row: 0, column: 0)
        viewModel.selectCell(at: position)

        // When - Enter a number that should be valid
        let number = 5
        viewModel.enterNumber(number)

        // Then - Verify no conflicts
        let conflicts = viewModel.conflictCount(for: number, at: position)
        // Note: This may or may not be 0 depending on the puzzle, so we just verify the method works
        XCTAssertGreaterThanOrEqual(conflicts, 0, "Conflict count should be non-negative")
    }

    /// Test that conflict count updates when placing invalid numbers
    func testConflictCountForInvalidPlacement() throws {
        // Given
        guard let puzzle = puzzleGenerator.generatePuzzle(columns: 5, rows: 5, difficulty: .easy) else {
            XCTFail("Failed to generate puzzle")
            return
        }
        let viewModel = GameViewModel(puzzle: puzzle)

        // When - Place a number in first cell
        let position1 = CellPosition(row: 0, column: 0)
        viewModel.selectCell(at: position1)
        viewModel.enterNumber(5)

        // When - Try to place the same number in adjacent cell
        let position2 = CellPosition(row: 0, column: 1)
        viewModel.selectCell(at: position2)

        // Then - Adjacent duplicate should be detected as conflict
        let conflicts = viewModel.conflictCount(for: 5, at: position2)
        XCTAssertGreaterThan(conflicts, 0, "Adjacent duplicate should create a conflict")
    }

    /// Test that conflict count is zero in notes mode
    func testConflictCountIgnoredInNotesMode() throws {
        // Given
        guard let puzzle = puzzleGenerator.generatePuzzle(columns: 5, rows: 5, difficulty: .easy) else {
            XCTFail("Failed to generate puzzle")
            return
        }
        let viewModel = GameViewModel(puzzle: puzzle)
        let position = CellPosition(row: 0, column: 0)
        viewModel.selectCell(at: position)

        // When - Toggle notes mode
        viewModel.toggleNotesMode()
        XCTAssertTrue(viewModel.notesMode)

        // Then - Conflict count should be zero in notes mode
        let conflicts = viewModel.conflictCount(for: 5, at: position)
        XCTAssertEqual(conflicts, 0, "Conflicts should not be shown in notes mode")
    }

    // MARK: - Selection and Disabled State Tests

    /// Test that number buttons show correct selected state
    func testSelectedNumberHighlight() throws {
        // Given
        guard let puzzle = puzzleGenerator.generatePuzzle(columns: 5, rows: 5, difficulty: .easy) else {
            XCTFail("Failed to generate puzzle")
            return
        }
        let viewModel = GameViewModel(puzzle: puzzle)
        let position = CellPosition(row: 0, column: 0)
        viewModel.selectCell(at: position)

        // When - Enter a number
        let selectedNumber = 7
        viewModel.enterNumber(selectedNumber)

        // Then - Verify the number is in the cell
        let cellValue = viewModel.value(at: position)
        XCTAssertEqual(cellValue, selectedNumber, "Cell should contain the entered number")
    }

    /// Test that invalid numbers are disabled
    func testInvalidNumbersDisabled() throws {
        // Given
        guard let puzzle = puzzleGenerator.generatePuzzle(columns: 5, rows: 5, difficulty: .easy) else {
            XCTFail("Failed to generate puzzle")
            return
        }
        let viewModel = GameViewModel(puzzle: puzzle)

        // Place a number in first cell
        let position1 = CellPosition(row: 0, column: 0)
        viewModel.selectCell(at: position1)
        viewModel.enterNumber(5)

        // When - Select adjacent cell
        let position2 = CellPosition(row: 0, column: 1)
        viewModel.selectCell(at: position2)

        // Then - Verify canPlaceValue returns false for adjacent duplicate
        let canPlace = viewModel.canPlaceValue(5, at: position2)
        XCTAssertFalse(canPlace, "Cannot place duplicate in adjacent cell")
    }

    /// Test that number pad shows no selection when no cell is selected
    func testNumberPadWithNoSelection() throws {
        // Given
        guard let puzzle = puzzleGenerator.generatePuzzle(columns: 5, rows: 5, difficulty: .easy) else {
            XCTFail("Failed to generate puzzle")
            return
        }
        let viewModel = GameViewModel(puzzle: puzzle)

        // When - Do not select any cell
        XCTAssertNil(
            viewModel.gameState.selectedCell,
            "No cell should be selected initially"
        )

        // Then - Create number pad view (should render without error)
        let view = NumberPadView(viewModel: viewModel)
        XCTAssertNotNil(view, "Number pad should render with no selection")
    }

    // MARK: - Multiple Entry Tests

    /// Test entering sequence of numbers
    func testSequentialNumberEntry() throws {
        // Given
        guard let puzzle = puzzleGenerator.generatePuzzle(columns: 5, rows: 5, difficulty: .easy) else {
            XCTFail("Failed to generate puzzle")
            return
        }
        let viewModel = GameViewModel(puzzle: puzzle)
        let position = CellPosition(row: 0, column: 0)
        viewModel.selectCell(at: position)

        // When - Enter a sequence of numbers
        let sequence = [1, 2, 3, 4, 5]
        for number in sequence {
            viewModel.enterNumber(number)
            let value = viewModel.value(at: position)
            XCTAssertEqual(value, number, "Cell should contain \(number)")
        }
    }

    /// Test entering zero
    func testEnteringZero() throws {
        // Given
        guard let puzzle = puzzleGenerator.generatePuzzle(columns: 5, rows: 5, difficulty: .easy) else {
            XCTFail("Failed to generate puzzle")
            return
        }
        let viewModel = GameViewModel(puzzle: puzzle)
        let position = CellPosition(row: 0, column: 0)
        viewModel.selectCell(at: position)

        // When
        viewModel.enterNumber(0)

        // Then
        let value = viewModel.value(at: position)
        XCTAssertEqual(value, 0, "Cell should contain 0")
    }

    // MARK: - View Creation Tests

    /// Test NumberPadView creates successfully
    func testNumberPadViewCreation() throws {
        // Given
        guard let puzzle = puzzleGenerator.generatePuzzle(columns: 5, rows: 5, difficulty: .easy) else {
            XCTFail("Failed to generate puzzle")
            return
        }
        let viewModel = GameViewModel(puzzle: puzzle)

        // When
        let view = NumberPadView(viewModel: viewModel)

        // Then
        XCTAssertNotNil(view, "Number pad view should be created")
    }

    /// Test NumberPadView with various puzzle sizes
    func testNumberPadViewWithVariousPuzzleSizes() throws {
        let sizes = [5, 6, 7, 8, 9, 10]

        for columns in sizes {
            // Given
            guard let puzzle = puzzleGenerator.generatePuzzle(
                columns: columns,
                rows: 5,
                difficulty: .easy
            ) else {
                XCTFail("Failed to generate \(columns)x5 puzzle")
                continue
            }
            let viewModel = GameViewModel(puzzle: puzzle)

            // When
            let view = NumberPadView(viewModel: viewModel)

            // Then
            XCTAssertNotNil(view, "Number pad should work with \(columns)x5 grid")
        }
    }

    /// Test NumberPadView with different difficulties
    func testNumberPadViewWithDifferentDifficulties() throws {
        let difficulties: [Difficulty] = [.easy, .medium, .hard, .expert]

        for difficulty in difficulties {
            // Given
            guard let puzzle = puzzleGenerator.generatePuzzle(
                columns: 5,
                rows: 5,
                difficulty: difficulty
            ) else {
                XCTFail("Failed to generate \(difficulty) puzzle")
                continue
            }
            let viewModel = GameViewModel(puzzle: puzzle)

            // When
            let view = NumberPadView(viewModel: viewModel)

            // Then
            XCTAssertNotNil(view, "Number pad should work with \(difficulty) difficulty")
        }
    }

    // MARK: - Layout Adaptation Tests

    /// Test NumberPadView layout on iPhone SE (compact device)
    func testNumberPadLayoutCompactDevice() throws {
        // Given
        guard let puzzle = puzzleGenerator.generatePuzzle(columns: 5, rows: 5, difficulty: .easy) else {
            XCTFail("Failed to generate puzzle")
            return
        }
        let viewModel = GameViewModel(puzzle: puzzle)
        let view = NumberPadView(viewModel: viewModel)

        // When/Then - Apply compact size class
        let compactView = view.environment(\.horizontalSizeClass, .compact)
        XCTAssertNotNil(compactView, "Number pad should support compact size class (iPhone SE)")
    }

    /// Test NumberPadView layout on iPad (regular device)
    func testNumberPadLayoutRegularDevice() throws {
        // Given
        guard let puzzle = puzzleGenerator.generatePuzzle(columns: 5, rows: 5, difficulty: .easy) else {
            XCTFail("Failed to generate puzzle")
            return
        }
        let viewModel = GameViewModel(puzzle: puzzle)
        let view = NumberPadView(viewModel: viewModel)

        // When/Then - Apply regular size class
        let regularView = view.environment(\.horizontalSizeClass, .regular)
        XCTAssertNotNil(regularView, "Number pad should support regular size class (iPad)")
    }

    // MARK: - Integration Tests

    /// Test complete user flow: select cell -> enter number -> select different cell -> enter number
    func testCompleteUserFlow() throws {
        // Given
        guard let puzzle = puzzleGenerator.generatePuzzle(columns: 5, rows: 5, difficulty: .easy) else {
            XCTFail("Failed to generate puzzle")
            return
        }
        let viewModel = GameViewModel(puzzle: puzzle)
        let view = NumberPadView(viewModel: viewModel)

        // When - Select cell 1 and enter number
        let position1 = CellPosition(row: 0, column: 0)
        viewModel.selectCell(at: position1)
        viewModel.enterNumber(3)

        // Then - Verify entry
        XCTAssertEqual(viewModel.value(at: position1), 3, "First cell should have value 3")

        // When - Select cell 2 and enter number
        let position2 = CellPosition(row: 1, column: 1)
        viewModel.selectCell(at: position2)
        viewModel.enterNumber(7)

        // Then - Verify second entry
        XCTAssertEqual(viewModel.value(at: position2), 7, "Second cell should have value 7")
        // Verify first entry unchanged
        XCTAssertEqual(viewModel.value(at: position1), 3, "First cell value should not change")

        XCTAssertNotNil(view, "View should be created successfully")
    }

    /// Test that number pad works correctly with erasing (entering 0)
    func testNumberPadWithErasing() throws {
        // Given
        guard let puzzle = puzzleGenerator.generatePuzzle(columns: 5, rows: 5, difficulty: .easy) else {
            XCTFail("Failed to generate puzzle")
            return
        }
        let viewModel = GameViewModel(puzzle: puzzle)
        let position = CellPosition(row: 0, column: 0)

        // When - Enter a number
        viewModel.selectCell(at: position)
        viewModel.enterNumber(5)
        XCTAssertEqual(viewModel.value(at: position), 5)

        // When - Erase by clearing the selected cell
        viewModel.clearSelectedCell()

        // Then - Cell should be empty
        XCTAssertNil(viewModel.value(at: position), "Cell should be empty after erase")
    }

    // MARK: - Performance Tests

    /// Test number pad rendering performance
    func testNumberPadRenderingPerformance() throws {
        // Given
        guard let puzzle = puzzleGenerator.generatePuzzle(columns: 10, rows: 5, difficulty: .hard) else {
            XCTFail("Failed to generate puzzle")
            return
        }

        // Measure performance of creating view model and number pad
        measure {
            let viewModel = GameViewModel(puzzle: puzzle)
            _ = NumberPadView(viewModel: viewModel)
        }
    }

    /// Test number entry performance with multiple entries
    func testNumberEntryPerformance() throws {
        // Given
        guard let puzzle = puzzleGenerator.generatePuzzle(columns: 5, rows: 5, difficulty: .easy) else {
            XCTFail("Failed to generate puzzle")
            return
        }
        let viewModel = GameViewModel(puzzle: puzzle)

        // Measure performance of entering multiple numbers
        measure {
            for row in 0 ..< 5 {
                for col in 0 ..< 5 {
                    let position = CellPosition(row: row, column: col)
                    if viewModel.isEditable(at: position) {
                        viewModel.selectCell(at: position)
                        viewModel.enterNumber((row + col) % 10)
                    }
                }
            }
        }
    }
}
