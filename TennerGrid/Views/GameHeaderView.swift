//
//  GameHeaderView.swift
//  TennerGrid
//
//  Created by Claude on 2026-01-22.
//

import SwiftUI

/// A header view displaying game information: timer, difficulty, and control buttons
struct GameHeaderView: View {
    // MARK: - Properties

    /// The view model managing game state
    @ObservedObject var viewModel: GameViewModel

    /// Action to perform when pause button is tapped
    var onPause: () -> Void

    /// Action to perform when settings/menu button is tapped
    var onSettings: () -> Void

    // MARK: - Body

    var body: some View {
        HStack {
            difficultyLabel
            Spacer()
            timerDisplay
            Spacer()
            controlButtons
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    // MARK: - Subviews

    /// Difficulty label with color indicator
    private var difficultyLabel: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(viewModel.gameState.puzzle.difficulty.color)
                .frame(width: 10, height: 10)

            Text(viewModel.gameState.puzzle.difficulty.displayName)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color.gray.opacity(0.1))
        )
    }

    /// Timer display showing elapsed time in MM:SS format
    private var timerDisplay: some View {
        HStack(spacing: 4) {
            Image(systemName: "clock")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(timerColor)

            Text(viewModel.formattedTime)
                .font(.system(size: 18, weight: .semibold, design: .monospaced))
                .foregroundColor(timerColor)
        }
    }

    /// Control buttons (pause and settings)
    private var controlButtons: some View {
        HStack(spacing: 12) {
            pauseButton
            settingsButton
        }
    }

    /// Pause button
    private var pauseButton: some View {
        Button(action: onPause) {
            Image(systemName: pauseIconName)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.primary)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(Color.gray.opacity(0.1))
                )
        }
        .buttonStyle(.plain)
        .disabled(viewModel.gameState.isCompleted)
        .opacity(viewModel.gameState.isCompleted ? 0.4 : 1.0)
        .accessibilityLabel(viewModel.gameState.isPaused ? "Resume game" : "Pause game")
    }

    /// Settings/menu button
    private var settingsButton: some View {
        Button(action: onSettings) {
            Image(systemName: "gearshape")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.primary)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(Color.gray.opacity(0.1))
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Settings")
    }

    // MARK: - Computed Properties

    /// Timer text color based on game state
    private var timerColor: Color {
        if viewModel.gameState.isCompleted {
            return .green
        } else if viewModel.gameState.isPaused {
            return .secondary
        } else {
            return .primary
        }
    }

    /// Icon name for pause button based on game state
    private var pauseIconName: String {
        viewModel.gameState.isPaused ? "play.fill" : "pause.fill"
    }
}

// MARK: - Previews

#Preview("Header - Default") {
    let generator = PuzzleGenerator()
    let puzzle = generator.generatePuzzle(columns: 5, rows: 3, difficulty: .easy)!
    let viewModel = GameViewModel(puzzle: puzzle)

    return VStack {
        GameHeaderView(
            viewModel: viewModel,
            onPause: {},
            onSettings: {}
        )
        Spacer()
    }
    .padding()
}

#Preview("Header - Medium Difficulty") {
    let generator = PuzzleGenerator()
    let puzzle = generator.generatePuzzle(columns: 6, rows: 4, difficulty: .medium)!
    let viewModel = GameViewModel(puzzle: puzzle)

    return VStack {
        GameHeaderView(
            viewModel: viewModel,
            onPause: {},
            onSettings: {}
        )
        Spacer()
    }
    .padding()
}

#Preview("Header - Hard Difficulty") {
    let generator = PuzzleGenerator()
    let puzzle = generator.generatePuzzle(columns: 7, rows: 4, difficulty: .hard)!
    let viewModel = GameViewModel(puzzle: puzzle)

    return VStack {
        GameHeaderView(
            viewModel: viewModel,
            onPause: {},
            onSettings: {}
        )
        Spacer()
    }
    .padding()
}

#Preview("Header - Expert Difficulty") {
    let generator = PuzzleGenerator()
    let puzzle = generator.generatePuzzle(columns: 8, rows: 5, difficulty: .expert)!
    let viewModel = GameViewModel(puzzle: puzzle)

    return VStack {
        GameHeaderView(
            viewModel: viewModel,
            onPause: {},
            onSettings: {}
        )
        Spacer()
    }
    .padding()
}

#Preview("Header - Calculator Difficulty") {
    let generator = PuzzleGenerator()
    let puzzle = generator.generatePuzzle(columns: 10, rows: 6, difficulty: .calculator)!
    let viewModel = GameViewModel(puzzle: puzzle)

    return VStack {
        GameHeaderView(
            viewModel: viewModel,
            onPause: {},
            onSettings: {}
        )
        Spacer()
    }
    .padding()
}

#Preview("Header - Dark Mode") {
    let generator = PuzzleGenerator()
    let puzzle = generator.generatePuzzle(columns: 5, rows: 3, difficulty: .hard)!
    let viewModel = GameViewModel(puzzle: puzzle)

    return VStack {
        GameHeaderView(
            viewModel: viewModel,
            onPause: {},
            onSettings: {}
        )
        Spacer()
    }
    .padding()
    .preferredColorScheme(.dark)
}

#Preview("iPhone SE") {
    let generator = PuzzleGenerator()
    let puzzle = generator.generatePuzzle(columns: 5, rows: 3, difficulty: .medium)!
    let viewModel = GameViewModel(puzzle: puzzle)

    return VStack {
        GameHeaderView(
            viewModel: viewModel,
            onPause: {},
            onSettings: {}
        )
        Spacer()
    }
    .padding()
    .previewDevice(PreviewDevice(rawValue: "iPhone SE (3rd generation)"))
}

#Preview("iPhone 15 Pro Max") {
    let generator = PuzzleGenerator()
    let puzzle = generator.generatePuzzle(columns: 5, rows: 3, difficulty: .medium)!
    let viewModel = GameViewModel(puzzle: puzzle)

    return VStack {
        GameHeaderView(
            viewModel: viewModel,
            onPause: {},
            onSettings: {}
        )
        Spacer()
    }
    .padding()
    .previewDevice(PreviewDevice(rawValue: "iPhone 15 Pro Max"))
}

#Preview("iPad") {
    let generator = PuzzleGenerator()
    let puzzle = generator.generatePuzzle(columns: 5, rows: 3, difficulty: .medium)!
    let viewModel = GameViewModel(puzzle: puzzle)

    return VStack {
        GameHeaderView(
            viewModel: viewModel,
            onPause: {},
            onSettings: {}
        )
        Spacer()
    }
    .padding()
    .previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch) (6th generation)"))
}
