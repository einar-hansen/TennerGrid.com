//
//  ContentView.swift
//  TennerGrid
//
//  Created by Einar-Johan Hansen on 21/01/2026.
//

import SwiftUI

@MainActor
struct ContentView: View {
    @StateObject private var puzzleManager = PuzzleManager()
    @State private var gameViewModel: GameViewModel?

    var body: some View {
        Group {
            if let viewModel = gameViewModel {
                GameView(viewModel: viewModel)
            } else {
                VStack(spacing: 20) {
                    Text("Tenner Grid")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Button("Start New Game") {
                        startNewGame()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .task {
            // Start with a puzzle on first launch
            if gameViewModel == nil {
                startNewGame()
            }
        }
    }

    private func startNewGame() {
        // Get a random puzzle from the bundled puzzles
        if let puzzle = puzzleManager.randomPuzzle(rows: 5, difficulty: .easy) {
            gameViewModel = GameViewModel(puzzle: puzzle)
        }
    }
}

#Preview {
    ContentView()
}
