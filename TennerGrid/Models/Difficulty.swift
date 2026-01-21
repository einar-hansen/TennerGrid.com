//
//  Difficulty.swift
//  TennerGrid
//
//  Created by Claude on 2026-01-22.
//

import Foundation
import SwiftUI

/// Represents the difficulty levels available in Tenner Grid puzzles
enum Difficulty: String, Codable, CaseIterable, Identifiable {
    case easy
    case medium
    case hard
    case expert
    case calculator

    var id: String { rawValue }

    /// Display name for the difficulty level
    var displayName: String {
        switch self {
        case .easy:
            "Easy"
        case .medium:
            "Medium"
        case .hard:
            "Hard"
        case .expert:
            "Expert"
        case .calculator:
            "Calculator"
        }
    }

    /// Color associated with the difficulty level
    var color: Color {
        switch self {
        case .easy:
            .green
        case .medium:
            .blue
        case .hard:
            .orange
        case .expert:
            .red
        case .calculator:
            .purple
        }
    }

    /// Number of pre-filled cells as a percentage (0.0 to 1.0)
    var prefilledPercentage: Double {
        switch self {
        case .easy:
            0.45 // 45% of cells pre-filled
        case .medium:
            0.35 // 35% of cells pre-filled
        case .hard:
            0.25 // 25% of cells pre-filled
        case .expert:
            0.15 // 15% of cells pre-filled
        case .calculator:
            0.05 // 5% of cells pre-filled (extremely challenging)
        }
    }

    /// Estimated time to complete puzzle in minutes
    var estimatedMinutes: Int {
        switch self {
        case .easy:
            5
        case .medium:
            10
        case .hard:
            20
        case .expert:
            35
        case .calculator:
            60
        }
    }

    /// Description of the difficulty level
    var description: String {
        switch self {
        case .easy:
            "Perfect for beginners. Plenty of clues to get you started."
        case .medium:
            "A balanced challenge with moderate pre-filled cells."
        case .hard:
            "Requires logical deduction and strategic thinking."
        case .expert:
            "Very challenging puzzles for experienced players."
        case .calculator:
            "The ultimate challenge. Minimal clues, maximum difficulty."
        }
    }

    /// Points awarded for completing a puzzle of this difficulty
    var points: Int {
        switch self {
        case .easy:
            10
        case .medium:
            25
        case .hard:
            50
        case .expert:
            100
        case .calculator:
            200
        }
    }
}
