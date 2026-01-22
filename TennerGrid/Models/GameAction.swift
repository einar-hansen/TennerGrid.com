//
//  GameAction.swift
//  TennerGrid
//
//  Created by Claude on 2026-01-22.
//

import Foundation

/// Represents an action that can be undone/redone in the game
struct GameAction: Equatable, Codable {
    /// The type of action performed
    let type: ActionType

    /// The cell position where the action occurred
    let position: CellPosition

    /// The previous value before the action (nil if empty)
    let oldValue: Int?

    /// The new value after the action (nil if cleared)
    let newValue: Int?

    /// Previous pencil marks before the action
    let oldPencilMarks: Set<Int>

    /// New pencil marks after the action
    let newPencilMarks: Set<Int>

    /// Timestamp when the action was performed
    let timestamp: Date

    /// Creates a new game action
    /// - Parameters:
    ///   - type: The type of action
    ///   - position: The cell position
    ///   - oldValue: The previous cell value
    ///   - newValue: The new cell value
    ///   - oldPencilMarks: The previous pencil marks
    ///   - newPencilMarks: The new pencil marks
    ///   - timestamp: When the action occurred (defaults to now)
    init(
        type: ActionType,
        position: CellPosition,
        oldValue: Int? = nil,
        newValue: Int? = nil,
        oldPencilMarks: Set<Int> = [],
        newPencilMarks: Set<Int> = [],
        timestamp: Date = Date()
    ) {
        self.type = type
        self.position = position
        self.oldValue = oldValue
        self.newValue = newValue
        self.oldPencilMarks = oldPencilMarks
        self.newPencilMarks = newPencilMarks
        self.timestamp = timestamp
    }
}

// MARK: - ActionType

extension GameAction {
    /// The type of action that was performed
    enum ActionType: String, Codable, CaseIterable {
        /// User entered or changed a number in a cell
        case setValue

        /// User cleared a cell value
        case clearValue

        /// User added or modified pencil marks
        case setPencilMarks

        /// User cleared pencil marks
        case clearPencilMarks

        /// User toggled a single pencil mark
        case togglePencilMark

        /// User cleared both value and pencil marks
        case clearCell
    }
}

// MARK: - Factory Methods

extension GameAction {
    /// Creates an action for setting a cell value
    /// - Parameters:
    ///   - position: The cell position
    ///   - oldValue: The previous value
    ///   - newValue: The new value
    ///   - oldPencilMarks: Any pencil marks that were cleared
    /// - Returns: A setValue action
    static func setValue(
        at position: CellPosition,
        from oldValue: Int?,
        to newValue: Int,
        clearingMarks oldPencilMarks: Set<Int> = []
    ) -> GameAction {
        GameAction(
            type: .setValue,
            position: position,
            oldValue: oldValue,
            newValue: newValue,
            oldPencilMarks: oldPencilMarks,
            newPencilMarks: []
        )
    }

    /// Creates an action for clearing a cell value
    /// - Parameters:
    ///   - position: The cell position
    ///   - oldValue: The value being cleared
    /// - Returns: A clearValue action
    static func clearValue(
        at position: CellPosition,
        from oldValue: Int
    ) -> GameAction {
        GameAction(
            type: .clearValue,
            position: position,
            oldValue: oldValue,
            newValue: nil
        )
    }

    /// Creates an action for setting pencil marks
    /// - Parameters:
    ///   - position: The cell position
    ///   - oldMarks: The previous pencil marks
    ///   - newMarks: The new pencil marks
    /// - Returns: A setPencilMarks action
    static func setPencilMarks(
        at position: CellPosition,
        from oldMarks: Set<Int>,
        to newMarks: Set<Int>
    ) -> GameAction {
        GameAction(
            type: .setPencilMarks,
            position: position,
            oldPencilMarks: oldMarks,
            newPencilMarks: newMarks
        )
    }

    /// Creates an action for toggling a pencil mark
    /// - Parameters:
    ///   - mark: The mark that was toggled
    ///   - position: The cell position
    ///   - oldMarks: The previous pencil marks
    ///   - newMarks: The new pencil marks
    /// - Returns: A togglePencilMark action
    static func togglePencilMark(
        _: Int,
        at position: CellPosition,
        from oldMarks: Set<Int>,
        to newMarks: Set<Int>
    ) -> GameAction {
        GameAction(
            type: .togglePencilMark,
            position: position,
            oldPencilMarks: oldMarks,
            newPencilMarks: newMarks
        )
    }

    /// Creates an action for clearing a cell completely
    /// - Parameters:
    ///   - position: The cell position
    ///   - oldValue: The value being cleared
    ///   - oldMarks: The pencil marks being cleared
    /// - Returns: A clearCell action
    static func clearCell(
        at position: CellPosition,
        from oldValue: Int?,
        clearingMarks oldMarks: Set<Int>
    ) -> GameAction {
        GameAction(
            type: .clearCell,
            position: position,
            oldValue: oldValue,
            newValue: nil,
            oldPencilMarks: oldMarks,
            newPencilMarks: []
        )
    }
}

// MARK: - Action Properties

extension GameAction {
    /// Whether this action changed a cell value
    var changedValue: Bool {
        oldValue != newValue
    }

    /// Whether this action changed pencil marks
    var changedPencilMarks: Bool {
        oldPencilMarks != newPencilMarks
    }

    /// Whether this action made any changes
    var madeChanges: Bool {
        changedValue || changedPencilMarks
    }

    /// Creates the inverse action for undo
    /// - Returns: A GameAction that reverses this action
    func inverse() -> GameAction {
        GameAction(
            type: type,
            position: position,
            oldValue: newValue,
            newValue: oldValue,
            oldPencilMarks: newPencilMarks,
            newPencilMarks: oldPencilMarks,
            timestamp: timestamp
        )
    }
}

// MARK: - CustomStringConvertible

extension GameAction: CustomStringConvertible {
    var description: String {
        let valueChange: String
        if oldValue != newValue {
            valueChange = "value: \(oldValue?.description ?? "nil") → \(newValue?.description ?? "nil")"
        } else {
            valueChange = ""
        }

        let marksChange: String
        if oldPencilMarks != newPencilMarks {
            marksChange = "marks: \(oldPencilMarks) → \(newPencilMarks)"
        } else {
            marksChange = ""
        }

        let changes = [valueChange, marksChange]
            .filter { !$0.isEmpty }
            .joined(separator: ", ")

        return "GameAction(\(type.rawValue) at \(position): \(changes))"
    }
}
