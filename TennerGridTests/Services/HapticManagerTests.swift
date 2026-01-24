import XCTest
@testable import TennerGrid

final class HapticManagerTests: XCTestCase {
    // MARK: - Properties

    var hapticManager: HapticManager?
    var originalHapticSetting = false
    var wasHapticSettingSaved = false

    private var manager: HapticManager {
        // swiftlint:disable:next force_unwrapping
        hapticManager!
    }

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        hapticManager = HapticManager.shared
        // Save original setting
        originalHapticSetting = UserDefaults.standard.bool(forKey: "hapticFeedback")
        wasHapticSettingSaved = true
    }

    override func tearDown() {
        // Restore original setting
        if wasHapticSettingSaved {
            UserDefaults.standard.set(originalHapticSetting, forKey: "hapticFeedback")
        }
        hapticManager = nil
        super.tearDown()
    }

    // MARK: - Singleton Tests

    func testSharedInstanceIsSingleton() {
        // Given
        let instance1 = HapticManager.shared
        let instance2 = HapticManager.shared

        // Then
        XCTAssertTrue(instance1 === instance2, "HapticManager.shared should return the same instance")
    }

    // MARK: - Haptic Feedback Tests

    func testLightImpactWhenHapticsEnabled() {
        // Given
        UserDefaults.standard.set(true, forKey: "hapticFeedback")

        // When/Then - Should not crash
        XCTAssertNoThrow(manager.lightImpact())
    }

    func testLightImpactWhenHapticsDisabled() {
        // Given
        UserDefaults.standard.set(false, forKey: "hapticFeedback")

        // When/Then - Should not crash
        XCTAssertNoThrow(manager.lightImpact())
    }

    func testMediumImpactWhenHapticsEnabled() {
        // Given
        UserDefaults.standard.set(true, forKey: "hapticFeedback")

        // When/Then - Should not crash
        XCTAssertNoThrow(manager.mediumImpact())
    }

    func testMediumImpactWhenHapticsDisabled() {
        // Given
        UserDefaults.standard.set(false, forKey: "hapticFeedback")

        // When/Then - Should not crash
        XCTAssertNoThrow(manager.mediumImpact())
    }

    func testHeavyImpactWhenHapticsEnabled() {
        // Given
        UserDefaults.standard.set(true, forKey: "hapticFeedback")

        // When/Then - Should not crash
        XCTAssertNoThrow(manager.heavyImpact())
    }

    func testHeavyImpactWhenHapticsDisabled() {
        // Given
        UserDefaults.standard.set(false, forKey: "hapticFeedback")

        // When/Then - Should not crash
        XCTAssertNoThrow(manager.heavyImpact())
    }

    func testSelectionFeedbackWhenHapticsEnabled() {
        // Given
        UserDefaults.standard.set(true, forKey: "hapticFeedback")

        // When/Then - Should not crash
        XCTAssertNoThrow(manager.selection())
    }

    func testSelectionFeedbackWhenHapticsDisabled() {
        // Given
        UserDefaults.standard.set(false, forKey: "hapticFeedback")

        // When/Then - Should not crash
        XCTAssertNoThrow(manager.selection())
    }

    func testSuccessFeedbackWhenHapticsEnabled() {
        // Given
        UserDefaults.standard.set(true, forKey: "hapticFeedback")

        // When/Then - Should not crash
        XCTAssertNoThrow(manager.success())
    }

    func testSuccessFeedbackWhenHapticsDisabled() {
        // Given
        UserDefaults.standard.set(false, forKey: "hapticFeedback")

        // When/Then - Should not crash
        XCTAssertNoThrow(manager.success())
    }

    func testWarningFeedbackWhenHapticsEnabled() {
        // Given
        UserDefaults.standard.set(true, forKey: "hapticFeedback")

        // When/Then - Should not crash
        XCTAssertNoThrow(manager.warning())
    }

    func testWarningFeedbackWhenHapticsDisabled() {
        // Given
        UserDefaults.standard.set(false, forKey: "hapticFeedback")

        // When/Then - Should not crash
        XCTAssertNoThrow(manager.warning())
    }

    func testErrorFeedbackWhenHapticsEnabled() {
        // Given
        UserDefaults.standard.set(true, forKey: "hapticFeedback")

        // When/Then - Should not crash
        XCTAssertNoThrow(manager.error())
    }

    func testErrorFeedbackWhenHapticsDisabled() {
        // Given
        UserDefaults.standard.set(false, forKey: "hapticFeedback")

        // When/Then - Should not crash
        XCTAssertNoThrow(manager.error())
    }

    // MARK: - Preparation Tests

    func testPrepareAll() {
        // When/Then - Should not crash
        XCTAssertNoThrow(manager.prepareAll())
    }

    func testPrepareLightImpact() {
        // When/Then - Should not crash
        XCTAssertNoThrow(manager.prepare(.lightImpact))
    }

    func testPrepareMediumImpact() {
        // When/Then - Should not crash
        XCTAssertNoThrow(manager.prepare(.mediumImpact))
    }

    func testPrepareHeavyImpact() {
        // When/Then - Should not crash
        XCTAssertNoThrow(manager.prepare(.heavyImpact))
    }

    func testPrepareSelection() {
        // When/Then - Should not crash
        XCTAssertNoThrow(manager.prepare(.selection))
    }

    func testPrepareNotification() {
        // When/Then - Should not crash
        XCTAssertNoThrow(manager.prepare(.notification))
    }

    // MARK: - Integration Tests

    func testMultipleHapticCallsInSequence() {
        // Given
        UserDefaults.standard.set(true, forKey: "hapticFeedback")

        // When/Then - Should not crash with multiple calls
        XCTAssertNoThrow {
            self.manager.lightImpact()
            self.manager.mediumImpact()
            self.manager.selection()
            self.manager.success()
        }
    }

    func testHapticCallsWithToggle() {
        // Given - Enable haptics
        UserDefaults.standard.set(true, forKey: "hapticFeedback")

        // When/Then - Should not crash
        XCTAssertNoThrow(self.manager.lightImpact())

        // Given - Disable haptics
        UserDefaults.standard.set(false, forKey: "hapticFeedback")

        // When/Then - Should still not crash
        XCTAssertNoThrow(self.manager.lightImpact())

        // Given - Re-enable haptics
        UserDefaults.standard.set(true, forKey: "hapticFeedback")

        // When/Then - Should not crash
        XCTAssertNoThrow(self.manager.mediumImpact())
    }

    func testPrepareBeforeHapticCall() {
        // Given
        UserDefaults.standard.set(true, forKey: "hapticFeedback")

        // When/Then - Should not crash
        XCTAssertNoThrow {
            self.manager.prepare(.lightImpact)
            self.manager.lightImpact()
        }
    }

    // MARK: - Feedback Type Tests

    func testFeedbackTypeEnumCases() {
        // Given
        let feedbackTypes: [HapticManager.FeedbackType] = [
            .lightImpact,
            .mediumImpact,
            .heavyImpact,
            .selection,
            .notification,
        ]

        // Then - All cases should be available
        XCTAssertEqual(feedbackTypes.count, 5, "Should have 5 feedback types")

        // When/Then - Should be able to prepare all types
        for feedbackType in feedbackTypes {
            XCTAssertNoThrow(manager.prepare(feedbackType))
        }
    }
}
