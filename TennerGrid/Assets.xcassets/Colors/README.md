# Dark Mode Color Palette

This directory contains the color sets for the Tenner Grid app, supporting both light and dark mode.

## Usage

All colors are accessible via the `Color+Theme.swift` extension:

```swift
// Background colors
.background(Color.background)
.foregroundColor(.primaryText)

// Cell state colors
.background(Color.cellSelectedBackground)
.foregroundColor(.cellUserEnteredText)

// Semantic colors
.foregroundColor(.errorColor)
.background(Color.successColor)
```

## Color Categories

### Background Colors
- **Background**: Primary background (white/black)
- **SecondaryBackground**: Cards and surfaces
- **TertiaryBackground**: Elevated surfaces
- **GroupedBackground**: Table view backgrounds

### Text Colors
- **PrimaryText**: Main text content
- **SecondaryText**: Secondary/supporting text
- **TertiaryText**: De-emphasized text

### Border & Separator Colors
- **BorderColor**: Default borders
- **SeparatorColor**: Divider lines

### Cell State Colors
Used in the game grid to indicate different cell states:

- **CellSelectedBackground/Border**: Currently selected cell
- **CellErrorBackground/Border/Text**: Invalid placement
- **CellHighlightedBackground**: Related cells (same row/column)
- **CellSameNumberBackground**: Cells with matching values
- **CellNeighborBackground**: Adjacent cells (constraint helper)
- **CellInitialBackground/Text**: Pre-filled cells
- **CellUserEnteredText**: User-entered values

### Difficulty Colors
- **DifficultyEasy**: Green (easy puzzles)
- **DifficultyMedium**: Blue (medium puzzles)
- **DifficultyHard**: Orange (hard puzzles)

### Semantic Colors
- **SuccessColor**: Positive actions and feedback
- **WarningColor**: Caution and warnings
- **ErrorColor**: Errors and destructive actions
- **InfoColor**: Informational messages

### Button & Interactive Colors
- **ButtonPrimary**: Primary action buttons
- **ButtonSecondary**: Secondary action buttons
- **ButtonDestructive**: Destructive action buttons

### Card & Surface Colors
- **CardBackground**: Card components
- **SurfaceBackground**: Surface containers

### Overlay Colors
- **OverlayBackground**: Semi-transparent overlays

## Color Palette Reference

### Light Mode Colors
- Background: `#FFFFFF` (White)
- Text: `#000000` (Black)
- Borders: `#C6C6C8` (Light Gray)
- Selected: `#007AFF` (iOS Blue)
- Error: `#FF3B30` (iOS Red)
- Success: `#34C759` (iOS Green)
- Warning: `#FF9500` (iOS Orange)

### Dark Mode Colors
- Background: `#000000` (Black)
- Text: `#FFFFFF` (White)
- Borders: `#38383A` (Dark Gray)
- Selected: `#0A84FF` (Lighter Blue)
- Error: `#FF453A` (Lighter Red)
- Success: `#32D74B` (Lighter Green)
- Warning: `#FF9F0A` (Lighter Orange)

## Design Principles

1. **Adaptive Colors**: All colors automatically adapt to light/dark mode
2. **Accessibility**: Colors meet WCAG contrast requirements
3. **Consistency**: Use semantic names, not literal colors
4. **iOS Guidelines**: Follows Apple's Human Interface Guidelines
5. **Opacity**: Adjust opacity for overlays and states, not base colors

## Testing Dark Mode

To test dark mode in previews:

```swift
#Preview("Dark Mode") {
    YourView()
        .preferredColorScheme(.dark)
}
```

To test dynamic switching:
1. Open Settings app on device/simulator
2. Go to Display & Brightness
3. Toggle between Light and Dark appearance
4. App colors should adapt automatically

## Adding New Colors

1. Create a new `.colorset` directory in this folder
2. Add `Contents.json` with both light and dark variants
3. Add the color to `Color+Theme.swift` extension
4. Document it in this README

Example Contents.json structure:
```json
{
  "colors": [
    {
      "color": {
        "color-space": "srgb",
        "components": {
          "alpha": "1.000",
          "blue": "1.000",
          "green": "1.000",
          "red": "1.000"
        }
      },
      "idiom": "universal"
    },
    {
      "appearances": [
        {
          "appearance": "luminosity",
          "value": "dark"
        }
      ],
      "color": {
        "color-space": "srgb",
        "components": {
          "alpha": "1.000",
          "blue": "0.000",
          "green": "0.000",
          "red": "0.000"
        }
      },
      "idiom": "universal"
    }
  ],
  "info": {
    "author": "xcode",
    "version": 1
  }
}
```
