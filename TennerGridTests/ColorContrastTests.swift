import SwiftUI
import XCTest
@testable import TennerGrid

/// Tests to ensure all color combinations meet WCAG AA accessibility standards
/// WCAG AA requires:
/// - 4.5:1 contrast ratio for normal text (< 18pt or < 14pt bold)
/// - 3:1 contrast ratio for large text (≥ 18pt or ≥ 14pt bold)
/// - 3:1 contrast ratio for UI components and graphical objects
final class ColorContrastTests: XCTestCase {
    // MARK: - Contrast Calculation

    /// Calculate relative luminance of an RGB color (sRGB color space)
    /// Formula from WCAG 2.1: https://www.w3.org/TR/WCAG21/#dfn-relative-luminance
    private func relativeLuminance(r: CGFloat, g: CGFloat, b: CGFloat) -> CGFloat {
        let rsRGB = r
        let gsRGB = g
        let bsRGB = b

        let rLinear = rsRGB <= 0.03928 ? rsRGB / 12.92 : pow((rsRGB + 0.055) / 1.055, 2.4)
        let gLinear = gsRGB <= 0.03928 ? gsRGB / 12.92 : pow((gsRGB + 0.055) / 1.055, 2.4)
        let bLinear = bsRGB <= 0.03928 ? bsRGB / 12.92 : pow((bsRGB + 0.055) / 1.055, 2.4)

        return 0.2126 * rLinear + 0.7152 * gLinear + 0.0722 * bLinear
    }

    /// Calculate contrast ratio between two colors
    /// Formula from WCAG 2.1: (L1 + 0.05) / (L2 + 0.05) where L1 is lighter
    private func contrastRatio(
        color1: (r: CGFloat, g: CGFloat, b: CGFloat),
        color2: (r: CGFloat, g: CGFloat, b: CGFloat)
    ) -> CGFloat {
        let lum1 = relativeLuminance(r: color1.r, g: color1.g, b: color1.b)
        let lum2 = relativeLuminance(r: color2.r, g: color2.g, b: color2.b)

        let lighter = max(lum1, lum2)
        let darker = min(lum1, lum2)

        return (lighter + 0.05) / (darker + 0.05)
    }

    // MARK: - Color Definitions (from Assets)

    // Light mode colors
    private let lightBackground = (r: CGFloat(1.0), g: CGFloat(1.0), b: CGFloat(1.0)) // White
    private let lightPrimaryText = (r: CGFloat(0.0), g: CGFloat(0.0), b: CGFloat(0.0)) // Black
    private let lightSecondaryText = (r: CGFloat(0.235), g: CGFloat(0.235), b: CGFloat(0.263))
    private let lightCellUserEnteredText = (
        r: CGFloat(0.0),
        g: CGFloat(0.431),
        b: CGFloat(0.933)
    ) // Darker blue for contrast
    private let lightCellInitialText = (r: CGFloat(0.0), g: CGFloat(0.0), b: CGFloat(0.0)) // Black
    private let lightCellErrorText = (
        r: CGFloat(0.831),
        g: CGFloat(0.176),
        b: CGFloat(0.149)
    ) // Darker red for contrast
    private let lightCellErrorBackground = (
        r: CGFloat(0.831),
        g: CGFloat(0.176),
        b: CGFloat(0.149)
    ) // Darker red for contrast
    private let lightCellSelectedBackground = (
        r: CGFloat(0.0),
        g: CGFloat(0.431),
        b: CGFloat(0.933)
    ) // Darker blue for contrast
    private let lightButtonPrimary = (r: CGFloat(0.0), g: CGFloat(0.431), b: CGFloat(0.933)) // Darker blue for contrast

    // Dark mode colors
    private let darkBackground = (r: CGFloat(0.0), g: CGFloat(0.0), b: CGFloat(0.0)) // Black
    private let darkPrimaryText = (r: CGFloat(1.0), g: CGFloat(1.0), b: CGFloat(1.0)) // White
    private let darkSecondaryText = (r: CGFloat(0.922), g: CGFloat(0.922), b: CGFloat(0.961))
    private let darkCellUserEnteredText = (r: CGFloat(0.039), g: CGFloat(0.518), b: CGFloat(1.0)) // Lighter blue
    private let darkCellInitialText = (r: CGFloat(1.0), g: CGFloat(1.0), b: CGFloat(1.0)) // White
    private let darkCellErrorText = (r: CGFloat(1.0), g: CGFloat(0.271), b: CGFloat(0.227)) // Lighter red
    private let darkCellErrorBackground = (r: CGFloat(1.0), g: CGFloat(0.271), b: CGFloat(0.227)) // Lighter red
    private let darkCellSelectedBackground = (r: CGFloat(0.039), g: CGFloat(0.518), b: CGFloat(1.0)) // Lighter blue
    private let darkButtonPrimary = (r: CGFloat(0.039), g: CGFloat(0.518), b: CGFloat(1.0)) // Lighter blue

    // MARK: - Test Light Mode Contrast

    func testLightModePrimaryTextContrast() {
        let ratio = contrastRatio(color1: lightPrimaryText, color2: lightBackground)
        XCTAssertGreaterThanOrEqual(
            ratio,
            4.5,
            "Primary text (black) on background (white) must have 4.5:1 contrast. Got: \(ratio):1"
        )
    }

    func testLightModeSecondaryTextContrast() {
        let ratio = contrastRatio(color1: lightSecondaryText, color2: lightBackground)
        XCTAssertGreaterThanOrEqual(
            ratio,
            4.5,
            "Secondary text must have 4.5:1 contrast on background. Got: \(ratio):1"
        )
    }

    func testLightModeUserEnteredTextContrast() {
        let ratio = contrastRatio(color1: lightCellUserEnteredText, color2: lightBackground)
        XCTAssertGreaterThanOrEqual(
            ratio,
            4.5,
            "User entered text (blue) must have 4.5:1 contrast. Got: \(ratio):1"
        )
    }

    func testLightModeInitialTextContrast() {
        let ratio = contrastRatio(color1: lightCellInitialText, color2: lightBackground)
        XCTAssertGreaterThanOrEqual(
            ratio,
            4.5,
            "Initial cell text must have 4.5:1 contrast. Got: \(ratio):1"
        )
    }

    func testLightModeErrorTextContrast() {
        let ratio = contrastRatio(color1: lightCellErrorText, color2: lightBackground)
        // Error text should be 4.5:1 for readability
        XCTAssertGreaterThanOrEqual(
            ratio,
            4.5,
            "Error text must have 4.5:1 contrast. Got: \(ratio):1"
        )
    }

    func testLightModeButtonPrimaryContrast() {
        // Button background vs white background (UI component, 3:1 minimum)
        let ratio = contrastRatio(color1: lightButtonPrimary, color2: lightBackground)
        XCTAssertGreaterThanOrEqual(
            ratio,
            3.0,
            "Button primary color must have 3:1 contrast with background. Got: \(ratio):1"
        )
    }

    // MARK: - Test Dark Mode Contrast

    func testDarkModePrimaryTextContrast() {
        let ratio = contrastRatio(color1: darkPrimaryText, color2: darkBackground)
        XCTAssertGreaterThanOrEqual(
            ratio,
            4.5,
            "Primary text (white) on background (black) must have 4.5:1 contrast. Got: \(ratio):1"
        )
    }

    func testDarkModeSecondaryTextContrast() {
        let ratio = contrastRatio(color1: darkSecondaryText, color2: darkBackground)
        XCTAssertGreaterThanOrEqual(
            ratio,
            4.5,
            "Secondary text must have 4.5:1 contrast on dark background. Got: \(ratio):1"
        )
    }

    func testDarkModeUserEnteredTextContrast() {
        let ratio = contrastRatio(color1: darkCellUserEnteredText, color2: darkBackground)
        XCTAssertGreaterThanOrEqual(
            ratio,
            4.5,
            "User entered text (blue) must have 4.5:1 contrast in dark mode. Got: \(ratio):1"
        )
    }

    func testDarkModeInitialTextContrast() {
        let ratio = contrastRatio(color1: darkCellInitialText, color2: darkBackground)
        XCTAssertGreaterThanOrEqual(
            ratio,
            4.5,
            "Initial cell text must have 4.5:1 contrast in dark mode. Got: \(ratio):1"
        )
    }

    func testDarkModeErrorTextContrast() {
        let ratio = contrastRatio(color1: darkCellErrorText, color2: darkBackground)
        XCTAssertGreaterThanOrEqual(
            ratio,
            4.5,
            "Error text must have 4.5:1 contrast in dark mode. Got: \(ratio):1"
        )
    }

    func testDarkModeButtonPrimaryContrast() {
        let ratio = contrastRatio(color1: darkButtonPrimary, color2: darkBackground)
        XCTAssertGreaterThanOrEqual(
            ratio,
            3.0,
            "Button primary color must have 3:1 contrast with dark background. Got: \(ratio):1"
        )
    }

    // MARK: - Test Text on Colored Backgrounds

    func testLightModeTextOnSelectedBackground() {
        // White text on blue selected background
        let whiteText = (r: CGFloat(1.0), g: CGFloat(1.0), b: CGFloat(1.0))
        let ratio = contrastRatio(color1: whiteText, color2: lightCellSelectedBackground)
        XCTAssertGreaterThanOrEqual(
            ratio,
            4.5,
            "White text on selected cell background must have 4.5:1 contrast. Got: \(ratio):1"
        )
    }

    func testDarkModeTextOnSelectedBackground() {
        // Black text on blue selected background
        let blackText = (r: CGFloat(0.0), g: CGFloat(0.0), b: CGFloat(0.0))
        let ratio = contrastRatio(color1: blackText, color2: darkCellSelectedBackground)
        XCTAssertGreaterThanOrEqual(
            ratio,
            4.5,
            "Black text on selected cell background must have 4.5:1 contrast in dark mode. Got: \(ratio):1"
        )
    }

    func testLightModeTextOnErrorBackground() {
        // White text on red error background
        let whiteText = (r: CGFloat(1.0), g: CGFloat(1.0), b: CGFloat(1.0))
        let ratio = contrastRatio(color1: whiteText, color2: lightCellErrorBackground)
        XCTAssertGreaterThanOrEqual(
            ratio,
            4.5,
            "White text on error background must have 4.5:1 contrast. Got: \(ratio):1"
        )
    }

    func testDarkModeTextOnErrorBackground() {
        // Black text on red error background
        let blackText = (r: CGFloat(0.0), g: CGFloat(0.0), b: CGFloat(0.0))
        let ratio = contrastRatio(color1: blackText, color2: darkCellErrorBackground)
        XCTAssertGreaterThanOrEqual(
            ratio,
            4.5,
            "Black text on error background must have 4.5:1 contrast in dark mode. Got: \(ratio):1"
        )
    }

    // MARK: - Comprehensive Report

    func testGenerateContrastReport() {
        print("\n=== WCAG Contrast Ratio Report ===\n")

        print("LIGHT MODE:")
        print(
            "  Primary Text/Background: \(String(format: "%.2f", contrastRatio(color1: lightPrimaryText, color2: lightBackground))):1"
        )
        print(
            "  Secondary Text/Background: \(String(format: "%.2f", contrastRatio(color1: lightSecondaryText, color2: lightBackground))):1"
        )
        print(
            "  User Text/Background: \(String(format: "%.2f", contrastRatio(color1: lightCellUserEnteredText, color2: lightBackground))):1"
        )
        print(
            "  Error Text/Background: \(String(format: "%.2f", contrastRatio(color1: lightCellErrorText, color2: lightBackground))):1"
        )
        print(
            "  Button/Background: \(String(format: "%.2f", contrastRatio(color1: lightButtonPrimary, color2: lightBackground))):1"
        )

        let whiteText = (r: CGFloat(1.0), g: CGFloat(1.0), b: CGFloat(1.0))
        print(
            "  White/Selected BG: \(String(format: "%.2f", contrastRatio(color1: whiteText, color2: lightCellSelectedBackground))):1"
        )
        print(
            "  White/Error BG: \(String(format: "%.2f", contrastRatio(color1: whiteText, color2: lightCellErrorBackground))):1"
        )

        print("\nDARK MODE:")
        print(
            "  Primary Text/Background: \(String(format: "%.2f", contrastRatio(color1: darkPrimaryText, color2: darkBackground))):1"
        )
        print(
            "  Secondary Text/Background: \(String(format: "%.2f", contrastRatio(color1: darkSecondaryText, color2: darkBackground))):1"
        )
        print(
            "  User Text/Background: \(String(format: "%.2f", contrastRatio(color1: darkCellUserEnteredText, color2: darkBackground))):1"
        )
        print(
            "  Error Text/Background: \(String(format: "%.2f", contrastRatio(color1: darkCellErrorText, color2: darkBackground))):1"
        )
        print(
            "  Button/Background: \(String(format: "%.2f", contrastRatio(color1: darkButtonPrimary, color2: darkBackground))):1"
        )

        let blackText = (r: CGFloat(0.0), g: CGFloat(0.0), b: CGFloat(0.0))
        print(
            "  Black/Selected BG: \(String(format: "%.2f", contrastRatio(color1: blackText, color2: darkCellSelectedBackground))):1"
        )
        print(
            "  Black/Error BG: \(String(format: "%.2f", contrastRatio(color1: blackText, color2: darkCellErrorBackground))):1"
        )

        print("\nWCAG AA Requirements:")
        print("  Normal text: 4.5:1 minimum")
        print("  Large text: 3.0:1 minimum")
        print("  UI components: 3.0:1 minimum\n")
    }
}
