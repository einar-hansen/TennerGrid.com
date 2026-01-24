import SwiftUI

/// Onboarding view with multi-page carousel shown on first launch
/// Introduces users to the game with welcome message, rules, and controls
// swiftlint:disable closure_body_length swiftui_view_body
struct OnboardingView: View {
    // MARK: - Properties

    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0
    @State private var showingGame = false

    private let totalPages = 5

    // MARK: - Body

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.6),
                    Color.purple.opacity(0.6),
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    if currentPage < totalPages - 1 {
                        Button {
                            completeOnboarding()
                        } label: {
                            Text("Skip")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                // Page content
                TabView(selection: $currentPage) {
                    WelcomePage()
                        .tag(0)

                    BasicRulesPage()
                        .tag(1)

                    ConstraintsPage()
                        .tag(2)

                    ControlsPage()
                        .tag(3)

                    GetStartedPage(onGetStarted: completeOnboarding)
                        .tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))

                // Navigation buttons
                if currentPage < totalPages - 1 {
                    HStack(spacing: 16) {
                        if currentPage > 0 {
                            Button {
                                withAnimation {
                                    currentPage -= 1
                                }
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "chevron.left")
                                    Text("Back")
                                }
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(12)
                            }
                        }

                        Button {
                            withAnimation {
                                currentPage += 1
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Text("Next")
                                Image(systemName: "chevron.right")
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white.opacity(0.3))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .fullScreenCover(isPresented: $showingGame) {
            TabBarView()
        }
    }

    // MARK: - Actions

    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        dismiss()
    }
}

// MARK: - Onboarding Pages

/// Page 1: Welcome and game overview
private struct WelcomePage: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Icon
            Image(systemName: "number.square.fill")
                .font(.system(size: 100))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)

            VStack(spacing: 16) {
                Text("Welcome to")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))

                Text("Tenner Grid")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)

                Text("The addictive number puzzle game")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            Spacer()

            VStack(spacing: 12) {
                FeatureRow(icon: "brain.head.profile", text: "Challenge your logic skills")
                FeatureRow(icon: "chart.line.uptrend.xyaxis", text: "Track your progress")
                FeatureRow(icon: "calendar", text: "Daily puzzles to master")
            }
            .padding(.horizontal, 40)

            Spacer()
        }
    }
}

/// Page 2: Basic rules with visuals
private struct BasicRulesPage: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Header
            VStack(spacing: 12) {
                Image(systemName: "list.number")
                    .font(.system(size: 60))
                    .foregroundColor(.white)

                Text("Three Simple Rules")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)

                Text("Master these to solve any puzzle")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.9))
            }

            Spacer()

            // Rules
            VStack(spacing: 24) {
                RuleRow(
                    number: 1,
                    title: "No Adjacent Duplicates",
                    description: "Same numbers can't touch (including diagonals)",
                    color: .red
                )

                RuleRow(
                    number: 2,
                    title: "Unique Rows",
                    description: "Each row must have different numbers",
                    color: .blue
                )

                RuleRow(
                    number: 3,
                    title: "Match Column Sums",
                    description: "Column total must equal target below",
                    color: .purple
                )
            }
            .padding(.horizontal, 30)

            Spacer()
        }
    }
}

/// Page 3: Constraints explanation
private struct ConstraintsPage: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Header
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.yellow)

                Text("Understanding Constraints")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)

                Text("Use these to solve puzzles faster")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.9))
            }

            Spacer()

            // Constraint examples
            VStack(spacing: 20) {
                ConstraintCard(
                    icon: "arrow.up.and.down.and.arrow.left.and.right",
                    title: "8 Neighbors Matter",
                    description: "Each cell has up to 8 adjacent cells that affect what numbers you can place."
                )

                ConstraintCard(
                    icon: "sum",
                    title: "Sum Limits Choices",
                    description: """
                    The number pad disables numbers that would exceed a column's remaining sum.
                    """
                )

                ConstraintCard(
                    icon: "checkmark.circle",
                    title: "Start with Easy Cells",
                    description: "Look for cells with the most constraints - they're easier to solve first."
                )
            }
            .padding(.horizontal, 30)

            Spacer()
        }
    }
}

/// Page 4: How to play (controls)
private struct ControlsPage: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Header
            VStack(spacing: 12) {
                Image(systemName: "hand.tap.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white)

                Text("How to Play")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)

                Text("Simple controls, powerful features")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.9))
            }

            Spacer()

            // Controls
            VStack(spacing: 20) {
                ControlCard(
                    icon: "hand.point.up.fill",
                    title: "Select a Cell",
                    description: "Tap any empty cell to select it"
                )

                ControlCard(
                    icon: "keyboard",
                    title: "Enter a Number",
                    description: "Use the number pad to fill the cell (0-9)"
                )

                ControlCard(
                    icon: "pencil",
                    title: "Use Notes",
                    description: "Toggle notes mode to mark possible numbers"
                )

                ControlCard(
                    icon: "arrow.uturn.backward",
                    title: "Undo Mistakes",
                    description: "Made an error? Use undo to go back"
                )

                ControlCard(
                    icon: "lightbulb.fill",
                    title: "Get Hints",
                    description: "Stuck? Use a hint to reveal the next move"
                )
            }
            .padding(.horizontal, 30)

            Spacer()
        }
    }
}

/// Page 5: Get started
private struct GetStartedPage: View {
    let onGetStarted: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Success icon
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 140, height: 140)

                Circle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 110, height: 110)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
            }

            VStack(spacing: 16) {
                Text("You're Ready!")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)

                Text("Start solving puzzles and track your progress")
                    .font(.system(size: 18))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            Spacer()

            // Features list
            VStack(spacing: 16) {
                GetStartedFeature(icon: "chart.bar.fill", text: "Track your statistics")
                GetStartedFeature(icon: "trophy.fill", text: "Earn achievements")
                GetStartedFeature(icon: "calendar.badge.clock", text: "Complete daily challenges")
                GetStartedFeature(icon: "slider.horizontal.3", text: "Choose your difficulty")
            }
            .padding(.horizontal, 40)

            Spacer()

            // Get started button
            Button {
                onGetStarted()
            } label: {
                HStack(spacing: 12) {
                    Text("Get Started")
                        .font(.system(size: 20, weight: .bold))
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 24))
                }
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
    }
}

// MARK: - Supporting Views

/// Feature row for welcome page
private struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.white)
                .frame(width: 28)

            Text(text)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)

            Spacer()
        }
    }
}

/// Rule row for basic rules page
private struct RuleRow: View {
    let number: Int
    let title: String
    let description: String
    let color: Color

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Number badge
            Text("\(number)")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(color)
                .clipShape(Circle())

            // Content
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)

                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.85))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.15))
        )
    }
}

/// Constraint card for constraints page
private struct ConstraintCard: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(.yellow)
                    .frame(width: 32)

                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }

            Text(description)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.85))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.15))
        )
    }
}

/// Control card for controls page
private struct ControlCard: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(Color.white.opacity(0.2))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)

                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.85))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.15))
        )
    }
}

/// Get started feature row
private struct GetStartedFeature: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.white)
                .frame(width: 28)

            Text(text)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)

            Spacer()
        }
    }
}

// MARK: - Previews

#Preview("Onboarding - Page 1") {
    OnboardingView()
}

#Preview("Onboarding - Dark Mode") {
    OnboardingView()
        .preferredColorScheme(.dark)
}

// swiftlint:enable closure_body_length swiftui_view_body
