import SwiftUI

/// A toolbar view providing game action buttons: Undo, Erase, Notes, and Hint
// swiftlint:disable:next swiftui_view_body
struct GameToolbarView: View {
    // MARK: - Properties

    /// The view model managing game state
    @ObservedObject var viewModel: GameViewModel

    /// Maximum hints allowed per game (for displaying remaining)
    var maxHints: Int = 3

    // MARK: - Environment

    /// Size class to detect iPad vs iPhone
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    // MARK: - Constants

    /// Check if running on iPad based on size classes
    private var isIPad: Bool {
        horizontalSizeClass == .regular && verticalSizeClass == .regular
    }

    /// Button size scales with device
    private var buttonSize: CGFloat {
        isIPad ? 56 : 44
    }

    /// Icon size scales with device
    private var iconSize: CGFloat {
        isIPad ? 28 : 22
    }

    /// Spacing between buttons scales with device
    private var spacing: CGFloat {
        isIPad ? 32 : 24
    }

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
            buttonSize: buttonSize,
            iconSize: iconSize,
            action: { viewModel.undo() }
        )
    }

    /// Erase button - clears the selected cell
    private var eraseButton: some View {
        ToolbarButton(
            icon: "eraser",
            label: "Erase",
            isEnabled: canErase,
            buttonSize: buttonSize,
            iconSize: iconSize,
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
            buttonSize: buttonSize,
            iconSize: iconSize,
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
            buttonSize: buttonSize,
            iconSize: iconSize,
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
// swiftlint:disable:next swiftui_view_body
private struct ToolbarButton: View {
    let icon: String
    let label: String
    let isEnabled: Bool
    var isActive: Bool = false
    var showIndicator: Bool = false
    var badge: Int?
    let buttonSize: CGFloat
    let iconSize: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                iconStack
                labelStack
            }
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.4)
        .accessibilityLabel(buttonAccessibilityLabel)
        .accessibilityValue(buttonAccessibilityValue)
        .accessibilityHint(buttonAccessibilityHint)
        .accessibilityAddTraits(isActive ? .isSelected : [])
    }

    /// Icon stack with background and optional badge
    private var iconStack: some View {
        ZStack {
            // Background circle for active state
            Circle()
                .fill(isActive ? Color.blue.opacity(0.15) : Color.clear)
                .frame(width: buttonSize, height: buttonSize)

            // Icon
            Image(systemName: activeIcon)
                .font(.system(size: iconSize, weight: .medium))
                .foregroundColor(iconColor)
                .frame(width: buttonSize, height: buttonSize)

            // Badge for hint count
            if let badgeValue = badge, badgeValue > 0 {
                badgeView(value: badgeValue)
            }
        }
    }

    /// Label with optional ON/OFF indicator
    private var labelStack: some View {
        let fontSize: CGFloat = buttonSize > 50 ? 13 : 11
        let indicatorFontSize: CGFloat = buttonSize > 50 ? 11 : 9

        return HStack(spacing: 2) {
            Text(label)
                .font(.system(size: fontSize, weight: .medium))
                .foregroundColor(labelColor)

            if showIndicator {
                statusIndicator(fontSize: indicatorFontSize)
            }
        }
    }

    /// ON/OFF status indicator
    private func statusIndicator(fontSize: CGFloat) -> some View {
        Text(isActive ? "ON" : "OFF")
            .font(.system(size: fontSize, weight: .bold))
            .foregroundColor(isActive ? .blue : .secondary)
            .padding(.horizontal, buttonSize > 50 ? 6 : 4)
            .padding(.vertical, buttonSize > 50 ? 2 : 1)
            .background(
                Capsule()
                    .fill(isActive ? Color.blue.opacity(0.15) : Color.themeButtonSecondary)
            )
    }

    /// Active icon name - handles special cases where .fill variant doesn't exist
    private var activeIcon: String {
        // Special case: pencil.and.list.clipboard doesn't have a .fill variant
        // Use pencil.tip.crop.circle.fill for notes mode when active
        if isActive, icon == "pencil.and.list.clipboard" {
            return "pencil.tip.crop.circle.fill"
        }
        // For other icons, use .fill variant when active
        return isActive ? "\(icon).fill" : icon
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
        let badgeSize: CGFloat = buttonSize > 50 ? 20 : 16
        let badgeFontSize: CGFloat = buttonSize > 50 ? 12 : 10
        let badgeOffset: CGFloat = buttonSize > 50 ? 6 : 4

        return VStack {
            HStack {
                Spacer()
                Text("\(value)")
                    .font(.system(size: badgeFontSize, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(width: badgeSize, height: badgeSize)
                    .background(Circle().fill(Color.orange))
                    .offset(x: badgeOffset, y: -badgeOffset)
            }
            Spacer()
        }
        .frame(width: buttonSize, height: buttonSize)
    }

    // MARK: - Accessibility

    /// Accessibility label for the button
    private var buttonAccessibilityLabel: String {
        label
    }

    /// Accessibility value for the button
    private var buttonAccessibilityValue: String {
        if let badgeValue = badge, badgeValue > 0 {
            return "\(badgeValue) remaining"
        }
        if showIndicator {
            return isActive ? "On" : "Off"
        }
        return ""
    }

    /// Accessibility hint for the button
    private var buttonAccessibilityHint: String {
        if !isEnabled {
            switch label {
            case "Undo":
                return "No actions to undo"
            case "Erase":
                return "Select a cell with a value or pencil marks to erase"
            case "Hint":
                return "No hints remaining or puzzle is complete"
            default:
                return "Button is disabled"
            }
        }

        switch label {
        case "Undo":
            return "Double tap to undo the last action"
        case "Erase":
            return "Double tap to erase the selected cell"
        case "Notes":
            return isActive ? "Double tap to turn off notes mode" : "Double tap to turn on notes mode"
        case "Hint":
            return "Double tap to get a hint for the current puzzle"
        default:
            return "Double tap to activate"
        }
    }
}

// MARK: - Previews

#Preview("Toolbar - Default") {
    let viewModel = GameViewModel(puzzle: PreviewPuzzles.easy3Row)
    return VStack {
        Spacer()
        GameToolbarView(viewModel: viewModel)
        Spacer()
    }
    .padding()
}

#Preview("Toolbar - Cell Selected") {
    let puzzle = PreviewPuzzles.easy3Row
    let viewModel = GameViewModel(puzzle: puzzle)
    viewModel.selectCell(at: CellPosition(row: 0, column: 2))
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
    let viewModel = GameViewModel(puzzle: PreviewPuzzles.easy3Row)
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
    let puzzle = PreviewPuzzles.easy3Row
    let viewModel = GameViewModel(puzzle: puzzle)
    viewModel.selectCell(at: CellPosition(row: 0, column: 2))
    viewModel.enterNumber(2)
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
    let viewModel = GameViewModel(puzzle: PreviewPuzzles.easy3Row)
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
    let viewModel = GameViewModel(puzzle: PreviewPuzzles.easy3Row)
    return VStack {
        Spacer()
        GameToolbarView(viewModel: viewModel)
        Spacer()
    }
    .padding()
}

#Preview("iPad") {
    let viewModel = GameViewModel(puzzle: PreviewPuzzles.easy3Row)
    return VStack {
        Spacer()
        GameToolbarView(viewModel: viewModel)
        Spacer()
    }
    .padding()
}
