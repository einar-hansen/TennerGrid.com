import SwiftUI

/// View displaying daily challenges in a calendar-style layout
/// Shows completion status for each day and current streak information
// swiftlint:disable:next swiftui_view_body type_body_length
struct DailyChallengesView: View {
    // MARK: - Properties

    /// Puzzle manager for accessing daily puzzles (unused currently, but kept for future integration)
    var puzzleManager: PuzzleManager?

    /// Callback when user wants to play a daily puzzle for a specific date
    var onPlayDaily: ((Date) -> Void)?

    /// Current calendar for date calculations
    private let calendar = Calendar.current

    /// Current date for highlighting today
    @State private var currentDate = Date()

    /// Currently displayed month
    @State private var displayedMonth = Date()

    /// Completed daily puzzles (keyed by date string in "yyyy-MM-dd" format)
    @State private var completedDates: Set<String> = []

    /// Current streak count
    @State private var currentStreak: Int = 0

    /// Best streak count
    @State private var bestStreak: Int = 0

    /// Total completed this month
    @State private var monthlyCompletedCount: Int = 0

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    streakSection

                    monthlyStatsSection

                    calendarSection

                    playTodayButton
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(backgroundGradient)
            .navigationTitle("Daily Challenges")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadCompletionData()
            }
        }
    }

    // MARK: - Subviews

    /// Background gradient
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color.orange.opacity(0.1),
                Color.red.opacity(0.05),
                Color.clear,
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    /// Streak information section
    private var streakSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 20) {
                streakCard(
                    title: "Current Streak",
                    value: currentStreak,
                    icon: "flame.fill",
                    gradient: [.orange, .red]
                )

                streakCard(
                    title: "Best Streak",
                    value: bestStreak,
                    icon: "star.fill",
                    gradient: [.yellow, .orange]
                )
            }
        }
    }

    /// Individual streak card
    /// - Parameters:
    ///   - title: Card title
    ///   - value: Streak count
    ///   - icon: SF Symbol name
    ///   - gradient: Color gradient for icon
    /// - Returns: Streak card view
    private func streakCard(
        title: String,
        value: Int,
        icon: String,
        gradient: [Color]
    ) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundStyle(
                    LinearGradient(
                        colors: gradient,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(spacing: 4) {
                Text("\(value)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)

                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }

    /// Monthly statistics section
    private var monthlyStatsSection: some View {
        VStack(spacing: 12) {
            monthHeader
            monthCompletionInfo
        }
        .padding(16)
        .background(cardBackground)
    }

    /// Month header with title and navigation
    private var monthHeader: some View {
        HStack {
            Text("This Month")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)

            Spacer()

            monthNavigationButtons
        }
    }

    /// Month completion information
    private var monthCompletionInfo: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 16))
                .foregroundColor(.green)

            Text("\(monthlyCompletedCount) days completed")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)

            Spacer()
        }
    }

    /// Month navigation buttons
    private var monthNavigationButtons: some View {
        HStack(spacing: 12) {
            monthNavigationButton(direction: -1, icon: "chevron.left", enabled: canNavigateToPreviousMonth)
            monthLabel
            monthNavigationButton(direction: 1, icon: "chevron.right", enabled: canNavigateToNextMonth)
        }
    }

    /// Month label displaying current month and year
    private var monthLabel: some View {
        Text(displayedMonthText)
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.primary)
            .frame(minWidth: 100)
    }

    /// Creates a month navigation button
    /// - Parameters:
    ///   - direction: 1 for next month, -1 for previous month
    ///   - icon: SF Symbol name for the button
    ///   - enabled: Whether the button is enabled
    /// - Returns: Navigation button view
    private func monthNavigationButton(direction: Int, icon: String, enabled: Bool) -> some View {
        Button {
            changeMonth(by: direction)
        } label: {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
                .padding(8)
                .background(
                    Circle()
                        .fill(Color(.systemGray5))
                )
        }
        .disabled(!enabled)
    }

    /// Card background with rounded rectangle and shadow
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color(.systemBackground))
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }

    /// Calendar section with day grid
    private var calendarSection: some View {
        VStack(spacing: 16) {
            weekdayHeaders

            dayGrid
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }

    /// Weekday header labels (S M T W T F S)
    private var weekdayHeaders: some View {
        HStack(spacing: 0) {
            ForEach(calendar.shortWeekdaySymbols, id: \.self) { symbol in
                Text(String(symbol.prefix(1)))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    /// Grid of day cells
    private var dayGrid: some View {
        let days = daysInMonth
        let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)

        return LazyVGrid(columns: columns, spacing: 8) {
            ForEach(days, id: \.self) { date in
                if let date {
                    dayCell(for: date)
                } else {
                    // Empty cell for padding
                    Color.clear
                        .frame(height: 44)
                }
            }
        }
    }

    /// Individual day cell
    /// - Parameter date: The date for this cell
    /// - Returns: Day cell view
    private func dayCell(for date: Date) -> some View {
        let state = DayCellState(date: date, currentDate: currentDate, calendar: calendar)
        let isCompleted = completedDates.contains(dateString(for: date))

        return Button {
            if !state.isFuture {
                onPlayDaily?(date)
            }
        } label: {
            ZStack {
                dayCellBackground(isCompleted: isCompleted, state: state)
                dayCellNumber(for: date, isCompleted: isCompleted, state: state)
                if isCompleted {
                    dayCellCheckmark
                }
            }
            .frame(height: 44)
        }
        .disabled(state.isFuture)
        .buttonStyle(.plain)
    }

    /// Background for day cell
    @ViewBuilder
    private func dayCellBackground(isCompleted: Bool, state: DayCellState) -> some View {
        if isCompleted {
            completedDayBackground
        } else if state.isToday {
            todayDayBackground
        } else if state.isPast {
            missedDayBackground
        } else {
            futureDayBackground
        }
    }

    /// Background for completed day
    private var completedDayBackground: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [.green, .green.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }

    /// Background for today
    private var todayDayBackground: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [.orange, .red],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }

    /// Background for missed day (past but not completed)
    private var missedDayBackground: some View {
        Circle()
            .strokeBorder(Color.red.opacity(0.3), lineWidth: 2)
    }

    /// Background for future day
    private var futureDayBackground: some View {
        Circle()
            .fill(Color(.systemGray6))
    }

    /// Day number text
    private func dayCellNumber(for date: Date, isCompleted: Bool, state: DayCellState) -> some View {
        Text("\(calendar.component(.day, from: date))")
            .font(.system(size: 16, weight: state.isToday || isCompleted ? .bold : .medium))
            .foregroundColor(dayCellNumberColor(isCompleted: isCompleted, state: state))
    }

    /// Color for day number text
    private func dayCellNumberColor(isCompleted: Bool, state: DayCellState) -> Color {
        if isCompleted || state.isToday {
            .white
        } else if state.isFuture {
            .secondary.opacity(0.5)
        } else {
            .primary
        }
    }

    /// Checkmark overlay for completed days
    private var dayCellCheckmark: some View {
        VStack {
            HStack {
                Spacer()
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 10))
                    .foregroundColor(.white)
                    .offset(x: 4, y: -4)
            }
            Spacer()
        }
    }

    /// Helper struct to encapsulate day cell state
    private struct DayCellState {
        let isToday: Bool
        let isPast: Bool
        let isFuture: Bool

        init(date: Date, currentDate: Date, calendar: Calendar) {
            isToday = calendar.isDateInToday(date)
            isPast = date < currentDate && !calendar.isDateInToday(date)
            isFuture = date > currentDate
        }
    }

    /// Play today's challenge button
    private var playTodayButton: some View {
        Button {
            onPlayDaily?(currentDate)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "play.fill")
                    .font(.system(size: 18, weight: .semibold))

                Text("Play Today's Challenge")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [.orange, .red],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: .orange.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .disabled(completedDates.contains(dateString(for: currentDate)))
        .opacity(completedDates.contains(dateString(for: currentDate)) ? 0.5 : 1.0)
    }

    // MARK: - Computed Properties

    /// Returns array of dates (or nil for empty cells) for the current month grid
    private var daysInMonth: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth),
              let firstWeekday = calendar.dateComponents([.weekday], from: monthInterval.start).weekday
        else {
            return []
        }

        var days: [Date?] = []

        // Add empty cells for days before the first day of month
        // weekday is 1-based (1 = Sunday in US locale)
        let firstWeekdayIndex = (firstWeekday - calendar.firstWeekday + 7) % 7
        days.append(contentsOf: Array(repeating: nil, count: firstWeekdayIndex))

        // Add all days in the month
        var currentDay = monthInterval.start
        while currentDay < monthInterval.end {
            days.append(currentDay)
            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDay) else {
                break
            }
            currentDay = nextDay
        }

        return days
    }

    /// Formatted month and year for display (e.g., "January 2026")
    private var displayedMonthText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: displayedMonth)
    }

    /// Whether user can navigate to previous month
    /// Limits to puzzles from January 2026 onwards
    private var canNavigateToPreviousMonth: Bool {
        guard let previousMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth),
              let januaryStart = calendar.date(from: DateComponents(year: 2026, month: 1, day: 1))
        else {
            return false
        }
        return previousMonth >= januaryStart
    }

    /// Whether user can navigate to next month
    /// Prevents navigating beyond current month
    private var canNavigateToNextMonth: Bool {
        guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) else {
            return false
        }
        return nextMonth <= currentDate
    }

    // MARK: - Helper Methods

    /// Converts date to string key for storage
    /// - Parameter date: Date to convert
    /// - Returns: Date string in "yyyy-MM-dd" format
    private func dateString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    /// Changes the displayed month
    /// - Parameter months: Number of months to add/subtract
    private func changeMonth(by months: Int) {
        guard let newMonth = calendar.date(byAdding: .month, value: months, to: displayedMonth) else {
            return
        }
        displayedMonth = newMonth
        calculateMonthlyStats()
    }

    /// Loads completion data from UserDefaults
    private func loadCompletionData() {
        // Load completed dates
        if let savedDates = UserDefaults.standard.array(forKey: "completedDailyDates") as? [String] {
            completedDates = Set(savedDates)
        }

        // Calculate streaks
        calculateStreaks()

        // Calculate monthly stats
        calculateMonthlyStats()
    }

    /// Calculates current and best streak
    private func calculateStreaks() {
        // Current streak: count backwards from yesterday
        var streak = 0
        var checkDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate

        while completedDates.contains(dateString(for: checkDate)) {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else {
                break
            }
            checkDate = previousDay
        }

        currentStreak = streak

        // Best streak: scan through all completed dates
        // For now, use current streak as best (will be enhanced with persistence later)
        bestStreak = max(streak, UserDefaults.standard.integer(forKey: "bestDailyStreak"))
    }

    /// Calculates monthly completion count for displayed month
    private func calculateMonthlyStats() {
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth) else {
            monthlyCompletedCount = 0
            return
        }

        var count = 0
        var currentDay = monthInterval.start

        while currentDay < monthInterval.end {
            if completedDates.contains(dateString(for: currentDay)) {
                count += 1
            }
            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDay) else {
                break
            }
            currentDay = nextDay
        }

        monthlyCompletedCount = count
    }
}

// MARK: - Previews

#Preview("Daily Challenges - No Progress") {
    DailyChallengesView()
}

#Preview("Daily Challenges - With Progress") {
    // Simulate some completed dates
    let calendar = Calendar.current
    let today = Date()
    var completedDates: [String] = []

    // Add last 5 days
    for i in 1 ... 5 {
        if let date = calendar.date(byAdding: .day, value: -i, to: today) {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            completedDates.append(formatter.string(from: date))
        }
    }

    UserDefaults.standard.set(completedDates, forKey: "completedDailyDates")

    return DailyChallengesView()
}

#Preview("Daily Challenges - Dark Mode") {
    DailyChallengesView()
        .preferredColorScheme(.dark)
}
