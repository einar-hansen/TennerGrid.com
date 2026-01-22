//
//  GameToolbarView.swift
//  TennerGrid
//
//  Created by Claude on 2026-01-22.
//

import SwiftUI

/// A toolbar view providing game action buttons: Undo, Erase, Notes, and Hint
struct GameToolbarView: View {
    // MARK: - Properties

    /// The view model managing game state
    @ObservedObject var viewModel: GameViewModel

    /// Maximum hints allowed per game (for displaying remaining)
    var maxHints: Int = 3

    // MARK: - Constants

    private let buttonSize: CGFloat = 44
    private let iconSize: CGFloat = 22
    private let spacing: CGFloat = 24

    // MARK: - Body

    var body: some View {
        HStack(spacing: spacing) {
            undoButton
            eraseButton
            notesButton
            hintButton
        }
        .padding(.horizontal)
    }

    // MARK: - Subviews

    /// Undo button - reverts the last action
    private var undoButton: some View {
        ToolbarButton(
            icon: "arrow.uturn.backward",
            label: "Undo",
            isEnabled: viewModel.canUndo,
            action: { viewModel.undo() }
        )
    }

    /// Erase button - clears the selected cell
    private var eraseButton: some View {
        ToolbarButton(
            icon: "eraser",
            label: "Erase",
            isEnabled: canErase,
            action: { viewModel.clearSelectedCell() }
        )
    }

    /// Notes button - toggles pencil marks mode
    private var notesButton: some View {
        ToolbarButton(
            icon: "pencil.and.list.clipboard",
            label: "Notes",
            isEnabled: true,
            isActive: viewModel.notesMode,
            showIndicator: true,
            action: { viewModel.toggleNotesMode() }
        )
    }

    /// Hint button - provides a hint for the current puzzle state
    private var hintButton: some View {
        ToolbarButton(
            icon: "lightbulb",
            label: "Hint",
            isEnabled: canUseHint,
            badge: remainingHints,
            action: { viewModel.requestHint() }
        )
    }

    // MARK: - Computed Properties

    /// Whether the erase button should be enabled
    private var canErase: Bool {
        guard let selected = viewModel.selectedPosition else { return false }
        guard viewModel.isEditable(at: selected) else { return false }

        // Can erase if cell has a value or pencil marks
        let hasValue = viewModel.value(at: selected) != nil
        let hasMarks = !viewModel.marks(at: selected).isEmpty
        return hasValue || hasMarks
    }

    /// Whether hints can still be used
    private var canUseHint: Bool {
        !viewModel.gameState.isCompleted && remainingHints > 0
    }

    /// Number of hints remaining
    private var remainingHints: Int {
        max(0, maxHints - viewModel.gameState.hintsUsed)
    }
}

// MARK: - Toolbar Button Component

/// A reusable toolbar button with icon, label, and optional state indicators
private struct ToolbarButton: View {
    let icon: String
    let label: String
    let isEnabled: Bool
    var isActive: Bool = false
    var showIndicator: Bool = false
    var badge: Int? = nil
    let action: () -> Void

    private let buttonSize: CGFloat = 44
    private let iconSize: CGFloat = 22

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    // Background circle for active state
                    Circle()
                        .fill(isActive ? Color.blue.opacity(0.15) : Color.clear)
                        .frame(width: buttonSize, height: buttonSize)

                    // Icon
                    Image(systemName: isActive ? "\(icon).fill" : icon)
                        .font(.system(size: iconSize, weight: .medium))
                        .foregroundColor(iconColor)
                        .frame(width: buttonSize, height: buttonSize)

                    // Badge for hint count
                    if let badgeValue = badge, badgeValue > 0 {
                        badgeView(value: badgeValue)
                    }
                }

                // Label with ON/OFF indicator
                HStack(spacing: 2) {
                    Text(label)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(labelColor)

                    if showIndicator {
                        Text(isActive ? "ON" : "OFF")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(isActive ? .blue : .secondary)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(
                                Capsule()
                                    .fill(isActive ? Color.blue.opacity(0.15) : Color.gray.opacity(0.15))
                            )
                    }
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.4)
    }

    /// Icon color based on state
    private var iconColor: Color {
        if isActive {
            return .blue
        }
        return isEnabled ? .primary : .secondary
    }

    /// Label color based on state
    private var labelColor: Color {
        if isActive {
            return .blue
        }
        return isEnabled ? .secondary : .secondary.opacity(0.6)
    }

    /// Badge view showing remaining count
    private func badgeView(value: Int) -> some View {
        VStack {
            HStack {
                Spacer()
                Text("\(value)")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(width: 16, height: 16)
                    .background(Circle().fill(Color.orange))
                    .offset(x: 4, y: -4)
            }
            Spacer()
        }
        .frame(width: buttonSize, height: buttonSize)
    }
}

// MARK: - Previews

#Preview("Toolbar - Default") {
    let generator = PuzzleGenerator()
    let puzzle = generator.generatePuzzle(columns: 5, rows: 3, difficulty: .easy)!
    let viewModel = GameViewModel(puzzle: puzzle)

    return VStack {
        Spacer()
        GameToolbarView(viewModel: viewModel)
        Spacer()
    }
    .padding()
}

#Preview("Toolbar - Cell Selected") {
    let generator = PuzzleGenerator()
    let puzzle = generator.generatePuzzle(columns: 5, rows: 3, difficulty: .easy)!
    let viewModel = GameViewModel(puzzle: puzzle)

    // Select an empty cell
    for row in 0 ..< puzzle.rows {
        for col in 0 ..< puzzle.columns {
            let pos = CellPosition(row: row, column: col)
            if !puzzle.isPrefilled(at: pos) {
                viewModel.selectCell(at: pos)
                break
            }
        }
    }

    return VStack {
        Text("Empty cell selected")
            .font(.caption)
            .foregroundColor(.secondary)
        Spacer()
        GameToolbarView(viewModel: viewModel)
        Spacer()
    }
    .padding()
}

#Preview("Toolbar - Notes Mode ON") {
    let generator = PuzzleGenerator()
    let puzzle = generator.generatePuzzle(columns: 5, rows: 3, difficulty: .easy)!
    let viewModel = GameViewModel(puzzle: puzzle)

    // Enable notes mode
    viewModel.toggleNotesMode()

    return VStack {
        Text("Notes mode enabled")
            .font(.caption)
            .foregroundColor(.secondary)
        Spacer()
        GameToolbarView(viewModel: viewModel)
        Spacer()
    }
    .padding()
}

#Preview("Toolbar - With Undo Available") {
    let generator = PuzzleGenerator()
    let puzzle = generator.generatePuzzle(columns: 5, rows: 3, difficulty: .easy)!
    let viewModel = GameViewModel(puzzle: puzzle)

    // Make some moves to enable undo
    for row in 0 ..< puzzle.rows {
        for col in 0 ..< puzzle.columns {
            let pos = CellPosition(row: row, column: col)
            if !puzzle.isPrefilled(at: pos) {
                viewModel.selectCell(at: pos)
                viewModel.enterNumber(puzzle.solution[row][col])
                break
            }
        }
    }

    return VStack {
        Text("Undo available after entering a number")
            .font(.caption)
            .foregroundColor(.secondary)
        Spacer()
        GameToolbarView(viewModel: viewModel)
        Spacer()
    }
    .padding()
}

#Preview("Toolbar - Dark Mode") {
    let generator = PuzzleGenerator()
    let puzzle = generator.generatePuzzle(columns: 5, rows: 3, difficulty: .easy)!
    let viewModel = GameViewModel(puzzle: puzzle)

    viewModel.toggleNotesMode()

    return VStack {
        Spacer()
        GameToolbarView(viewModel: viewModel)
        Spacer()
    }
    .padding()
    .preferredColorScheme(.dark)
}

#Preview("iPhone SE") {
    let generator = PuzzleGenerator()
    let puzzle = generator.generatePuzzle(columns: 5, rows: 3, difficulty: .easy)!
    let viewModel = GameViewModel(puzzle: puzzle)

    return VStack {
        Spacer()
        GameToolbarView(viewModel: viewModel)
        Spacer()
    }
    .padding()
    .previewDevice(PreviewDevice(rawValue: "iPhone SE (3rd generation)"))
}

#Preview("iPad") {
    let generator = PuzzleGenerator()
    let puzzle = generator.generatePuzzle(columns: 5, rows: 3, difficulty: .easy)!
    let viewModel = GameViewModel(puzzle: puzzle)

    return VStack {
        Spacer()
        GameToolbarView(viewModel: viewModel)
        Spacer()
    }
    .padding()
    .previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch) (6th generation)"))
}
