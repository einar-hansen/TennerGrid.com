import UIKit

/// Service responsible for managing haptic feedback throughout the app
final class HapticManager {
    // MARK: - Singleton

    static let shared = HapticManager()

    // MARK: - Properties

    private var isHapticsEnabled: Bool {
        UserDefaults.standard.bool(forKey: "hapticFeedback")
    }

    // MARK: - Feedback Generators

    private let lightImpactGenerator = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpactGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpactGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let selectionGenerator = UISelectionFeedbackGenerator()
    private let notificationGenerator = UINotificationFeedbackGenerator()

    // MARK: - Initialization

    private init() {
        // Prepare all generators for minimal latency
        prepareAll()
    }

    // MARK: - Public Methods

    /// Provides light impact feedback (e.g., for cell selection)
    func lightImpact() {
        guard isHapticsEnabled else { return }
        lightImpactGenerator.impactOccurred()
    }

    /// Provides medium impact feedback (e.g., for number entry)
    func mediumImpact() {
        guard isHapticsEnabled else { return }
        mediumImpactGenerator.impactOccurred()
    }

    /// Provides heavy impact feedback (e.g., for significant actions)
    func heavyImpact() {
        guard isHapticsEnabled else { return }
        heavyImpactGenerator.impactOccurred()
    }

    /// Provides selection feedback (e.g., for UI element selection)
    func selection() {
        guard isHapticsEnabled else { return }
        selectionGenerator.selectionChanged()
    }

    /// Provides success notification feedback (e.g., for puzzle completion)
    func success() {
        guard isHapticsEnabled else { return }
        notificationGenerator.notificationOccurred(.success)
    }

    /// Provides warning notification feedback (e.g., for invalid moves)
    func warning() {
        guard isHapticsEnabled else { return }
        notificationGenerator.notificationOccurred(.warning)
    }

    /// Provides error notification feedback (e.g., for critical errors)
    func error() {
        guard isHapticsEnabled else { return }
        notificationGenerator.notificationOccurred(.error)
    }

    // MARK: - Preparation Methods

    /// Prepares all feedback generators for minimal latency
    func prepareAll() {
        lightImpactGenerator.prepare()
        mediumImpactGenerator.prepare()
        heavyImpactGenerator.prepare()
        selectionGenerator.prepare()
        notificationGenerator.prepare()
    }

    /// Prepares specific feedback generator for minimal latency
    /// - Parameter type: The type of feedback to prepare
    func prepare(_ type: FeedbackType) {
        switch type {
        case .lightImpact:
            lightImpactGenerator.prepare()
        case .mediumImpact:
            mediumImpactGenerator.prepare()
        case .heavyImpact:
            heavyImpactGenerator.prepare()
        case .selection:
            selectionGenerator.prepare()
        case .notification:
            notificationGenerator.prepare()
        }
    }
}

// MARK: - Feedback Type

extension HapticManager {
    /// Types of haptic feedback available
    enum FeedbackType {
        case lightImpact
        case mediumImpact
        case heavyImpact
        case selection
        case notification
    }
}
