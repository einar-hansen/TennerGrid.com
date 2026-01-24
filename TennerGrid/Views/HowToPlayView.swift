import SwiftUI

// swiftlint:disable closure_body_length

/// How to Play view with detailed strategy guide for Tenner Grid puzzles
/// Provides comprehensive instructions, tips, tricks, and advanced strategies
// swiftlint:disable:next swiftui_view_body
struct HowToPlayView: View {
    // MARK: - Properties

    @Environment(\.colorScheme) private var colorScheme

    // MARK: - Constants

    private let cellSize: CGFloat = 44

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                headerSection
                basicRulesSection
                tipsAndTricksSection
                advancedStrategiesSection
                startTutorialSection
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .navigationTitle("How to Play")
        .navigationBarTitleDisplayMode(.large)
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)

            Text("Master Tenner Grid")
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.center)

            Text("Learn the strategies to solve puzzles efficiently and become an expert")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .padding(.bottom, 8)
    }

    // MARK: - Basic Rules Section

    private var basicRulesSection: some View {
        StrategyCard(
            icon: "list.number",
            title: "Basic Rules",
            description: "Understanding the fundamentals",
            color: .blue
        ) {
            VStack(alignment: .leading, spacing: 16) {
                RuleItem(
                    number: 1,
                    title: "Fill All Cells",
                    description: "Complete the grid by filling all empty cells with numbers from 0 to 9."
                )

                RuleItem(
                    number: 2,
                    title: "No Adjacent Duplicates",
                    description: "Numbers cannot touch each other (horizontally, vertically, or diagonally)."
                )

                RuleItem(
                    number: 3,
                    title: "Unique Rows",
                    description: "Each row must contain only unique numbers - no duplicates allowed."
                )

                RuleItem(
                    number: 4,
                    title: "Match Column Sums",
                    description: "The sum of each column must equal the target number shown below it."
                )
            }
        }
    }

    // MARK: - Tips & Tricks Section

    private var tipsAndTricksSection: some View {
        StrategyCard(
            icon: "lightbulb.fill",
            title: "Tips & Tricks",
            description: "Proven techniques to solve puzzles faster",
            color: .orange
        ) {
            VStack(alignment: .leading, spacing: 20) {
                TipItem(
                    icon: "1.circle.fill",
                    color: .orange,
                    title: "Start with Constraints",
                    description: """
                    Look for cells with the most constraints - those surrounded by many filled cells \
                    or in rows with few empty spaces.
                    """
                )

                TipItem(
                    icon: "2.circle.fill",
                    color: .orange,
                    title: "Use Column Sums",
                    description: """
                    If a column needs a small sum and already has large numbers, \
                    the remaining cells must be small numbers (0-3).
                    """
                )

                TipItem(
                    icon: "3.circle.fill",
                    color: .orange,
                    title: "Watch the Neighbors",
                    description: """
                    When placing a number, always check all 8 adjacent cells. \
                    The neighbor highlighting feature helps you see these cells.
                    """
                )

                TipItem(
                    icon: "4.circle.fill",
                    color: .orange,
                    title: "Process of Elimination",
                    description: """
                    If only one or two cells remain in a row, you can quickly determine \
                    which numbers are still needed.
                    """
                )

                TipItem(
                    icon: "5.circle.fill",
                    color: .orange,
                    title: "Use Pencil Marks",
                    description: """
                    Toggle notes mode to mark possible numbers in a cell. \
                    This helps track your logical deductions.
                    """
                )

                TipItem(
                    icon: "6.circle.fill",
                    color: .orange,
                    title: "Complete Easy Cells First",
                    description: """
                    Solve the obvious cells first. This creates more constraints and makes \
                    harder cells easier to solve.
                    """
                )
            }
        }
    }

    // MARK: - Advanced Strategies Section

    private var advancedStrategiesSection: some View {
        StrategyCard(
            icon: "brain.head.profile",
            title: "Advanced Strategies",
            description: "Expert techniques for difficult puzzles",
            color: .purple
        ) {
            VStack(alignment: .leading, spacing: 20) {
                AdvancedStrategyItem(
                    title: "Column Sum Analysis",
                    description: """
                    Calculate how much sum is remaining in each column. The number pad \
                    automatically disables numbers that would exceed the remaining sum.
                    """,
                    example: "If a column target is 30 and current sum is 27, only 0-3 are valid."
                )

                AdvancedStrategyItem(
                    title: "Forced Placement",
                    description: """
                    When only one position in a row can hold a particular number due to \
                    constraints, place it immediately.
                    """,
                    example: """
                    If 7 must appear in a row but 6 cells already neighbor a 7, \
                    the last cell must contain it.
                    """
                )

                AdvancedStrategyItem(
                    title: "Diagonal Cascades",
                    description: """
                    Placing a number diagonally creates a chain of constraints. \
                    Use this to solve multiple cells in sequence.
                    """,
                    example: "If you place 5 in a corner, all 3 diagonal neighbors cannot be 5."
                )

                AdvancedStrategyItem(
                    title: "Sum Partitioning",
                    description: """
                    For nearly complete columns, determine which combination of remaining \
                    numbers equals the target sum.
                    """,
                    example: """
                    If you need sum=8 in 2 cells, only pairs like (0,8), (1,7), (2,6), \
                    (3,5), (4,4) work.
                    """
                )

                AdvancedStrategyItem(
                    title: "Contradiction Method",
                    description: """
                    If stuck, assume a number in a cell and see if it leads to a contradiction. \
                    If it does, eliminate that option.
                    """,
                    example: """
                    Try placing 6 in a cell. If it forces an impossible situation later, \
                    6 cannot go there.
                    """
                )

                AdvancedStrategyItem(
                    title: "Pattern Recognition",
                    description: """
                    Learn common patterns like checkerboards of alternating numbers or numeric \
                    sequences that satisfy constraints.
                    """,
                    example: """
                    In some configurations, a pattern like 1-3-5-7-9 or 0-2-4-6-8 can appear.
                    """
                )
            }
        }
    }

    // MARK: - Start Tutorial Section

    private var startTutorialSection: some View {
        VStack(spacing: 16) {
            Text("Ready to Practice?")
                .font(.system(size: 24, weight: .bold))

            Text("Start with an easy puzzle and apply these strategies to build your skills.")
                .font(.system(size: 15))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            Button {
                // TODO: Phase 7.3 - Navigate to onboarding tutorial
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 20))
                    Text("Start Tutorial")
                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.green)
                .cornerRadius(12)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)

            Text("Tutorial coming in Phase 7.3")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .padding(.bottom, 20)
    }
}

// MARK: - Supporting Views

/// Card view for displaying strategy sections
private struct StrategyCard<Content: View>: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .frame(width: 48, height: 48)
                    .background(color)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 20, weight: .bold))

                    Text(description)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }

            // Content
            content
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.secondarySystemGroupedBackground))
                )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

/// Basic rule item with number, title, and description
// swiftlint:disable:next swiftui_view_body
private struct RuleItem: View {
    let number: Int
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Number badge
            Text("\(number)")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(Color.blue)
                .clipShape(Circle())

            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))

                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
        }
    }
}

/// Tip item with icon, title, and description
// swiftlint:disable:next swiftui_view_body
private struct TipItem: View {
    let icon: String
    let color: Color
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))

                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

/// Advanced strategy item with title, description, and example
// swiftlint:disable:next swiftui_view_body
private struct AdvancedStrategyItem: View {
    let title: String
    let description: String
    let example: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.purple)

            Text(description)
                .font(.system(size: 14))
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.yellow)

                Text(example)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .italic()
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 4)
        }
    }
}

// swiftlint:enable closure_body_length

// MARK: - Previews

#Preview("How to Play - Light Mode") {
    NavigationStack {
        HowToPlayView()
    }
}

#Preview("How to Play - Dark Mode") {
    NavigationStack {
        HowToPlayView()
            .preferredColorScheme(.dark)
    }
}

#Preview("How to Play - Compact") {
    NavigationStack {
        HowToPlayView()
    }
}
