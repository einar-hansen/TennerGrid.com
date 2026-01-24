import SwiftUI

/// Extension providing semantic color names from the Assets catalog
/// All colors support both light and dark mode appearances
extension Color {
    // MARK: - Background Colors

    /// Primary background color (white in light mode, black in dark mode)
    static let themeBackground = Color("Background")

    /// Secondary background for cards/surfaces
    static let themeSecondaryBackground = Color("SecondaryBackground")

    /// Tertiary background for elevated surfaces
    static let themeTertiaryBackground = Color("TertiaryBackground")

    /// Grouped background for table views
    static let themeGroupedBackground = Color("GroupedBackground")

    // MARK: - Text Colors

    /// Primary text color
    static let themePrimaryText = Color("PrimaryText")

    /// Secondary text color
    static let themeSecondaryText = Color("SecondaryText")

    /// Tertiary text color with reduced opacity
    static let themeTertiaryText = Color("TertiaryText")

    // MARK: - Border & Separator Colors

    /// Default border color
    static let themeBorderColor = Color("BorderColor")

    /// Separator line color
    static let themeSeparatorColor = Color("SeparatorColor")

    // MARK: - Cell State Colors

    /// Background for selected cell
    static let themeCellSelectedBackground = Color("CellSelectedBackground")

    /// Border for selected cell
    static let themeCellSelectedBorder = Color("CellSelectedBorder")

    /// Background for error cell
    static let themeCellErrorBackground = Color("CellErrorBackground")

    /// Border for error cell
    static let themeCellErrorBorder = Color("CellErrorBorder")

    /// Text color for error cell
    static let themeCellErrorText = Color("CellErrorText")

    /// Background for highlighted cell
    static let themeCellHighlightedBackground = Color("CellHighlightedBackground")

    /// Background for cells with same number
    static let themeCellSameNumberBackground = Color("CellSameNumberBackground")

    /// Background for neighbor cells
    static let themeCellNeighborBackground = Color("CellNeighborBackground")

    /// Background for initial/pre-filled cells
    static let themeCellInitialBackground = Color("CellInitialBackground")

    /// Text color for initial cells
    static let themeCellInitialText = Color("CellInitialText")

    /// Text color for user-entered values
    static let themeCellUserEnteredText = Color("CellUserEnteredText")

    // MARK: - Difficulty Colors

    /// Color for easy difficulty
    static let themeDifficultyEasy = Color("DifficultyEasy")

    /// Color for medium difficulty
    static let themeDifficultyMedium = Color("DifficultyMedium")

    /// Color for hard difficulty
    static let themeDifficultyHard = Color("DifficultyHard")

    // MARK: - Semantic Colors

    /// Success/positive action color
    static let themeSuccessColor = Color("SuccessColor")

    /// Warning/caution color
    static let themeWarningColor = Color("WarningColor")

    /// Error/destructive action color
    static let themeErrorColor = Color("ErrorColor")

    /// Informational color
    static let themeInfoColor = Color("InfoColor")

    // MARK: - Button & Interactive Colors

    /// Primary button background
    static let themeButtonPrimary = Color("ButtonPrimary")

    /// Secondary button background
    static let themeButtonSecondary = Color("ButtonSecondary")

    /// Destructive button background
    static let themeButtonDestructive = Color("ButtonDestructive")

    // MARK: - Card & Surface Colors

    /// Card background color
    static let themeCardBackground = Color("CardBackground")

    /// Surface background color
    static let themeSurfaceBackground = Color("SurfaceBackground")

    // MARK: - Overlay Colors

    /// Semi-transparent overlay background
    static let themeOverlayBackground = Color("OverlayBackground")

    // MARK: - High Contrast Colors

    /// High contrast background for error cells (stronger red)
    static let highContrastErrorBackground = Color(red: 1.0, green: 0.3, blue: 0.3).opacity(0.3)

    /// High contrast border for error cells (strong red)
    static let highContrastErrorBorder = Color(red: 0.9, green: 0.1, blue: 0.1)

    /// High contrast text for error cells (dark red)
    static let highContrastErrorText = Color(red: 0.7, green: 0.0, blue: 0.0)

    /// High contrast background for selected cells (stronger blue)
    static let highContrastSelectedBackground = Color(red: 0.2, green: 0.5, blue: 1.0).opacity(0.25)

    /// High contrast border for selected cells (strong blue)
    static let highContrastSelectedBorder = Color(red: 0.0, green: 0.3, blue: 0.9)

    /// High contrast background for same number cells (stronger yellow/amber)
    static let highContrastSameNumberBackground = Color(red: 1.0, green: 0.8, blue: 0.0).opacity(0.25)

    /// High contrast background for neighbor cells (stronger purple)
    static let highContrastNeighborBackground = Color(red: 0.6, green: 0.3, blue: 0.9).opacity(0.25)

    /// High contrast background for highlighted cells (lighter blue)
    static let highContrastHighlightedBackground = Color(red: 0.4, green: 0.7, blue: 1.0).opacity(0.15)

    /// High contrast text for user-entered values (strong blue)
    static let highContrastUserEnteredText = Color(red: 0.0, green: 0.3, blue: 0.9)
}
