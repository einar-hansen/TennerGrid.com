//
//  GameView.swift
//  TennerGrid
//
//  Created by Claude on 2026-01-22.
//

import SwiftUI

/// The main game view composing all game UI components
struct GameView: View {
    // MARK: - Properties

    /// The view model managing game state
    @StateObject private var viewModel: GameViewModel

    /// Whether the pause menu is showing
    @State private var showingPauseMenu = false

    /// Whether the settings sheet is showing
    @State private var showingSettings = false

    /// Whether the win screen is showing
    @State private var showingWinScreen = false

    // MARK: - Initialization

    /// Creates a new GameView with the given puzzle
    /// - Parameter puzzle: The puzzle to play
    init(puzzle: TennerGridPuzzle) {
        _viewModel = StateObject(wrappedValue: GameViewModel(puzzle: puzzle))
    }

    /// Creates a new GameView with the given view model
    /// - Parameter viewModel: The view model to use
    init(viewModel: GameViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            // Main game content
            gameContent
                .blur(radius: viewModel.gameState.isPaused ? 10 : 0)
                .disabled(viewModel.gameState.isPaused)

            // Pause overlay
            if viewModel.gameState.isPaused {
                pauseOverlay
            }
        }
        .onChange(of: viewModel.gameState.isCompleted) { isCompleted in
            if isCompleted {
                showingWinScreen = true
            }
        }
        .sheet(isPresented: $showingSettings) {
            settingsPlaceholder
        }
        .sheet(isPresented: $showingWinScreen) {
            winScreenPlaceholder
        }
    }

    // MARK: - Subviews

    /// Main game content layout
    private var gameContent: some View {
        VStack(spacing: 16) {
            // Header with timer, difficulty, and controls
            GameHeaderView(
                viewModel: viewModel,
                onPause: handlePause,
                onSettings: handleSettings
            )

            Spacer()

            // Main puzzle grid
            GridView(viewModel: viewModel)

            Spacer()

            // Game toolbar with action buttons
            GameToolbarView(viewModel: viewModel)
                .padding(.bottom, 8)

            // Number pad for input
            NumberPadView(viewModel: viewModel)
                .padding(.bottom, 16)
        }
    }

    /// Pause overlay shown when game is paused
    private var pauseOverlay: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            // Pause menu content
            VStack(spacing: 24) {
                // Pause icon
                Image(systemName: "pause.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.white)

                Text("Game Paused")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)

                // Resume button
                Button(action: handleResume) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Resume")
                    }
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                    .background(
                        Capsule()
                            .fill(Color.blue)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .transition(.opacity)
    }

    /// Placeholder for settings view (to be implemented in Phase 6)
    private var settingsPlaceholder: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "gearshape")
                    .font(.system(size: 48))
                    .foregroundColor(.secondary)

                Text("Settings")
                    .font(.title)

                Text("Coming soon...")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        showingSettings = false
                    }
                }
            }
        }
    }

    /// Placeholder for win screen (to be implemented in Phase 4.3)
    private var winScreenPlaceholder: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.yellow)

                Text("Congratulations!")
                    .font(.largeTitle.bold())

                VStack(spacing: 8) {
                    Text("Time: \(viewModel.formattedTime)")
                        .font(.title2)

                    Text("Hints used: \(viewModel.gameState.hintsUsed)")
                        .font(.title3)
                        .foregroundColor(.secondary)

                    Text("Difficulty: \(viewModel.gameState.puzzle.difficulty.displayName)")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical)

                Button(action: {
                    showingWinScreen = false
                }) {
                    Text("Done")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 48)
                        .padding(.vertical, 14)
                        .background(Capsule().fill(Color.blue))
                }
                .buttonStyle(.plain)
            }
            .padding()
        }
    }

    // MARK: - Actions

    /// Handles the pause button tap
    private func handlePause() {
        withAnimation(.easeInOut(duration: 0.3)) {
            viewModel.pauseTimer()
        }
    }

    /// Handles the resume button tap
    private func handleResume() {
        withAnimation(.easeInOut(duration: 0.3)) {
            viewModel.resumeTimer()
        }
    }

    /// Handles the settings button tap
    private func handleSettings() {
        showingSettings = true
    }
}

// MARK: - Previews

#Preview("Game View - Easy") {
    let generator = PuzzleGenerator()
    let puzzle = generator.generatePuzzle(columns: 5, rows: 3, difficulty: .easy)!
    return GameView(puzzle: puzzle)
}

#Preview("Game View - Medium") {
    let generator = PuzzleGenerator()
    let puzzle = generator.generatePuzzle(columns: 7, rows: 4, difficulty: .medium)!
    return GameView(puzzle: puzzle)
}

#Preview("Game View - Hard") {
    let generator = PuzzleGenerator()
    let puzzle = generator.generatePuzzle(columns: 8, rows: 5, difficulty: .hard)!
    return GameView(puzzle: puzzle)
}

#Preview("Game View - Expert") {
    let generator = PuzzleGenerator()
    let puzzle = generator.generatePuzzle(columns: 10, rows: 5, difficulty: .expert)!
    return GameView(puzzle: puzzle)
}

#Preview("Dark Mode") {
    let generator = PuzzleGenerator()
    let puzzle = generator.generatePuzzle(columns: 7, rows: 4, difficulty: .medium)!
    return GameView(puzzle: puzzle)
        .preferredColorScheme(.dark)
}

#Preview("iPhone SE") {
    let generator = PuzzleGenerator()
    let puzzle = generator.generatePuzzle(columns: 5, rows: 3, difficulty: .easy)!
    return GameView(puzzle: puzzle)
        .previewDevice(PreviewDevice(rawValue: "iPhone SE (3rd generation)"))
}

#Preview("iPhone 15 Pro Max") {
    let generator = PuzzleGenerator()
    let puzzle = generator.generatePuzzle(columns: 8, rows: 5, difficulty: .hard)!
    return GameView(puzzle: puzzle)
        .previewDevice(PreviewDevice(rawValue: "iPhone 15 Pro Max"))
}

#Preview("iPad") {
    let generator = PuzzleGenerator()
    let puzzle = generator.generatePuzzle(columns: 10, rows: 5, difficulty: .expert)!
    return GameView(puzzle: puzzle)
        .previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch) (6th generation)"))
}
