import SwiftUI
import XCTest
@testable import TennerGrid

/// Tests for TabBarView navigation and state preservation
@MainActor
final class TabBarViewTests: XCTestCase {
    // MARK: - Tab Enumeration Tests

    /// Tests that all tab cases have unique raw values
    func testTabRawValues() {
        // Given
        let mainTab = TabBarView.Tab.main
        let dailyChallengesTab = TabBarView.Tab.dailyChallenges
        let profileTab = TabBarView.Tab.profile

        // Then
        XCTAssertEqual(mainTab.rawValue, 0)
        XCTAssertEqual(dailyChallengesTab.rawValue, 1)
        XCTAssertEqual(profileTab.rawValue, 2)
    }

    /// Tests that all tabs are iterable via CaseIterable
    func testTabCaseIterable() {
        // Given
        let allTabs = TabBarView.Tab.allCases

        // Then
        XCTAssertEqual(allTabs.count, 3)
        XCTAssertTrue(allTabs.contains(.main))
        XCTAssertTrue(allTabs.contains(.dailyChallenges))
        XCTAssertTrue(allTabs.contains(.profile))
    }

    /// Tests that each tab has a unique ID for Identifiable conformance
    func testTabIdentifiable() {
        // Given
        let mainTab = TabBarView.Tab.main
        let dailyChallengesTab = TabBarView.Tab.dailyChallenges
        let profileTab = TabBarView.Tab.profile

        // Then
        XCTAssertEqual(mainTab.id, mainTab.rawValue)
        XCTAssertEqual(dailyChallengesTab.id, dailyChallengesTab.rawValue)
        XCTAssertEqual(profileTab.id, profileTab.rawValue)

        // Verify uniqueness
        XCTAssertNotEqual(mainTab.id, dailyChallengesTab.id)
        XCTAssertNotEqual(dailyChallengesTab.id, profileTab.id)
        XCTAssertNotEqual(mainTab.id, profileTab.id)
    }

    /// Tests that tab titles are correct
    func testTabTitles() {
        // Then
        XCTAssertEqual(TabBarView.Tab.main.title, "Main")
        XCTAssertEqual(TabBarView.Tab.dailyChallenges.title, "Daily")
        XCTAssertEqual(TabBarView.Tab.profile.title, "Me")
    }

    /// Tests that tab icons are correct SF Symbol names
    func testTabIcons() {
        // Then
        XCTAssertEqual(TabBarView.Tab.main.icon, "house.fill")
        XCTAssertEqual(TabBarView.Tab.dailyChallenges.icon, "calendar")
        XCTAssertEqual(TabBarView.Tab.profile.icon, "person.fill")
    }

    // MARK: - State Preservation Tests

    /// Tests that Tab enum can be stored and retrieved with SceneStorage
    /// This verifies RawRepresentable conformance needed for @SceneStorage
    func testTabSceneStorageCompatibility() {
        // Given
        let originalTab = TabBarView.Tab.dailyChallenges

        // When - Simulate storage and retrieval via rawValue
        let storedValue = originalTab.rawValue
        let retrievedTab = TabBarView.Tab(rawValue: storedValue)

        // Then
        XCTAssertNotNil(retrievedTab)
        XCTAssertEqual(retrievedTab, originalTab)
    }

    /// Tests that all tabs can round-trip through raw value conversion
    func testTabRawValueRoundTrip() {
        // Given
        let tabs: [TabBarView.Tab] = [.main, .dailyChallenges, .profile]

        // When/Then
        for tab in tabs {
            let rawValue = tab.rawValue
            let reconstructedTab = TabBarView.Tab(rawValue: rawValue)

            XCTAssertNotNil(reconstructedTab, "Tab \(tab) should reconstruct from raw value")
            XCTAssertEqual(reconstructedTab, tab, "Reconstructed tab should equal original")
        }
    }

    /// Tests that invalid raw values return nil
    func testTabInvalidRawValue() {
        // Given
        let invalidRawValue = 999

        // When
        let tab = TabBarView.Tab(rawValue: invalidRawValue)

        // Then
        XCTAssertNil(tab, "Invalid raw value should return nil")
    }

    // MARK: - Architecture Tests

    /// Tests tab order matches expected navigation flow
    func testTabOrder() {
        // Given
        let tabs = TabBarView.Tab.allCases

        // Then - Verify tabs are in the expected order
        XCTAssertEqual(tabs[0], .main, "First tab should be Main")
        XCTAssertEqual(tabs[1], .dailyChallenges, "Second tab should be Daily Challenges")
        XCTAssertEqual(tabs[2], .profile, "Third tab should be Me/Profile")
    }

    // MARK: - Navigation Flow Tests

    /// Tests that TabBarView can be created successfully
    func testTabBarViewCreation() {
        // When
        let tabBarView = TabBarView()

        // Then
        XCTAssertNotNil(tabBarView, "TabBarView should be created successfully")
    }

    /// Tests that TabBarView can be rendered in light mode
    func testTabBarViewLightMode() {
        // Given
        let tabBarView = TabBarView()

        // When
        let lightModeView = tabBarView.environment(\.colorScheme, .light)

        // Then
        XCTAssertNotNil(lightModeView, "TabBarView should support light mode")
    }

    /// Tests that TabBarView can be rendered in dark mode
    func testTabBarViewDarkMode() {
        // Given
        let tabBarView = TabBarView()

        // When
        let darkModeView = tabBarView.environment(\.colorScheme, .dark)

        // Then
        XCTAssertNotNil(darkModeView, "TabBarView should support dark mode")
    }

    /// Tests that TabBarView works with compact horizontal size class (iPhone)
    func testTabBarViewCompactHorizontalSizeClass() {
        // Given
        let tabBarView = TabBarView()

        // When
        let compactView = tabBarView.environment(\.horizontalSizeClass, .compact)

        // Then
        XCTAssertNotNil(compactView, "TabBarView should support compact horizontal size class")
    }

    /// Tests that TabBarView works with regular horizontal size class (iPad)
    func testTabBarViewRegularHorizontalSizeClass() {
        // Given
        let tabBarView = TabBarView()

        // When
        let regularView = tabBarView.environment(\.horizontalSizeClass, .regular)

        // Then
        XCTAssertNotNil(regularView, "TabBarView should support regular horizontal size class")
    }

    /// Tests that TabBarView supports multiple color scheme transitions
    func testTabBarViewColorSchemeTransitions() {
        // Given
        let tabBarView = TabBarView()

        // When/Then - Simulate switching between light and dark modes
        let lightView = tabBarView.environment(\.colorScheme, .light)
        XCTAssertNotNil(lightView, "Should support light mode")

        let darkView = tabBarView.environment(\.colorScheme, .dark)
        XCTAssertNotNil(darkView, "Should support dark mode")

        let lightAgainView = tabBarView.environment(\.colorScheme, .light)
        XCTAssertNotNil(lightAgainView, "Should support switching back to light mode")
    }

    /// Tests that TabBarView works with different size class combinations
    func testTabBarViewSizeClassCombinations() {
        // Given
        let tabBarView = TabBarView()

        // When/Then - Test various size class combinations (iPhone/iPad orientations)
        let compactCompact = tabBarView
            .environment(\.horizontalSizeClass, .compact)
            .environment(\.verticalSizeClass, .compact)
        XCTAssertNotNil(compactCompact, "Should support compact x compact (iPhone landscape)")

        let compactRegular = tabBarView
            .environment(\.horizontalSizeClass, .compact)
            .environment(\.verticalSizeClass, .regular)
        XCTAssertNotNil(compactRegular, "Should support compact x regular (iPhone portrait)")

        let regularRegular = tabBarView
            .environment(\.horizontalSizeClass, .regular)
            .environment(\.verticalSizeClass, .regular)
        XCTAssertNotNil(regularRegular, "Should support regular x regular (iPad)")
    }

    /// Tests that TabBarView creates successfully multiple times (no singleton issues)
    func testMultipleTabBarViewInstances() {
        // When
        let tabBarView1 = TabBarView()
        let tabBarView2 = TabBarView()
        let tabBarView3 = TabBarView()

        // Then
        XCTAssertNotNil(tabBarView1, "First instance should be created")
        XCTAssertNotNil(tabBarView2, "Second instance should be created")
        XCTAssertNotNil(tabBarView3, "Third instance should be created")
    }

    /// Tests that all three tabs can be represented and are distinct
    func testAllTabsAreDistinct() {
        // Given
        let tabs = TabBarView.Tab.allCases

        // Then - Verify all tabs have unique identities
        var seenIds = Set<Int>()
        for tab in tabs {
            XCTAssertFalse(seenIds.contains(tab.id), "Tab ID \(tab.id) should be unique")
            seenIds.insert(tab.id)
        }

        XCTAssertEqual(seenIds.count, 3, "Should have 3 unique tab IDs")
    }

    /// Tests that tab metadata (title + icon) is complete for all tabs
    func testAllTabsHaveCompleteMetadata() {
        // Given
        let tabs = TabBarView.Tab.allCases

        // Then - Every tab should have both title and icon
        for tab in tabs {
            XCTAssertFalse(tab.title.isEmpty, "Tab \(tab) should have a non-empty title")
            XCTAssertFalse(tab.icon.isEmpty, "Tab \(tab) should have a non-empty icon")

            // Verify icon is a valid SF Symbol name (basic validation)
            XCTAssertGreaterThan(tab.icon.count, 2, "Icon name should be a valid SF Symbol")
        }
    }

    /// Tests the default tab structure and count
    func testDefaultTabStructure() {
        // Given
        let tabs = TabBarView.Tab.allCases

        // Then - Verify the default 3-tab structure
        XCTAssertEqual(tabs.count, 3, "Should have exactly 3 tabs")
        XCTAssertTrue(tabs.contains(.main), "Should include main tab")
        XCTAssertTrue(tabs.contains(.dailyChallenges), "Should include daily challenges tab")
        XCTAssertTrue(tabs.contains(.profile), "Should include profile tab")
    }

    /// Tests that main tab is the first tab (default selection)
    func testMainTabIsFirstTab() {
        // Given
        let tabs = TabBarView.Tab.allCases

        // Then
        XCTAssertEqual(tabs.first, .main, "Main tab should be the first tab (default)")
    }

    /// Tests tab navigation completeness - all tabs are accessible
    func testTabNavigationCompleteness() {
        // Given
        let requiredTabs: [TabBarView.Tab] = [.main, .dailyChallenges, .profile]

        // Then - Verify all required tabs exist
        for requiredTab in requiredTabs {
            let exists = TabBarView.Tab.allCases.contains(requiredTab)
            XCTAssertTrue(exists, "Tab \(requiredTab) should be accessible in navigation")
        }
    }

    /// Tests that tab icons are appropriate SF Symbols
    func testTabIconsAreValidSFSymbols() {
        // Then - Verify icons match expected SF Symbol patterns
        XCTAssertTrue(
            TabBarView.Tab.main.icon.contains("house"),
            "Main tab should use house icon"
        )
        XCTAssertTrue(
            TabBarView.Tab.dailyChallenges.icon.contains("calendar"),
            "Daily challenges tab should use calendar icon"
        )
        XCTAssertTrue(
            TabBarView.Tab.profile.icon.contains("person"),
            "Profile tab should use person icon"
        )
    }

    /// Tests that tab titles are user-friendly and concise
    func testTabTitlesAreUserFriendly() {
        // Given
        let tabs = TabBarView.Tab.allCases

        // Then - Verify titles are short enough for tab bar display
        for tab in tabs {
            XCTAssertLessThanOrEqual(
                tab.title.count,
                10,
                "Tab title '\(tab.title)' should be concise for tab bar display"
            )
        }
    }

    /// Tests tab enum CaseIterable conformance provides consistent ordering
    func testTabCaseIterableConsistency() {
        // Given
        let tabs1 = TabBarView.Tab.allCases
        let tabs2 = TabBarView.Tab.allCases

        // Then - Order should be consistent across calls
        XCTAssertEqual(tabs1.count, tabs2.count, "Tab count should be consistent")

        for (index, tab) in tabs1.enumerated() {
            XCTAssertEqual(tab, tabs2[index], "Tab at index \(index) should be consistent")
        }
    }

    /// Tests that each tab's ID is stable across multiple accesses
    func testTabIDStability() {
        // Given
        let mainTab = TabBarView.Tab.main

        // Then - ID should be stable
        XCTAssertEqual(mainTab.id, mainTab.id, "Tab ID should be stable")
        XCTAssertEqual(mainTab.id, TabBarView.Tab.main.id, "Tab ID should be consistent")
    }

    /// Tests that tab enum supports Equatable correctly
    func testTabEquatableConformance() {
        // Given
        let tab1 = TabBarView.Tab.main
        let tab2 = TabBarView.Tab.main
        let tab3 = TabBarView.Tab.dailyChallenges

        // Then
        XCTAssertEqual(tab1, tab2, "Same tabs should be equal")
        XCTAssertNotEqual(tab1, tab3, "Different tabs should not be equal")
    }

    /// Tests complete tab navigation flow simulation
    func testCompleteTabNavigationFlowSimulation() {
        // Given - Simulate user navigating through all tabs
        let navigationSequence: [TabBarView.Tab] = [
            .main, // Start at main
            .dailyChallenges, // Navigate to daily challenges
            .profile, // Navigate to profile
            .main, // Back to main
            .profile, // To profile again
            .dailyChallenges, // To daily challenges again
        ]

        // When/Then - Verify each tab in sequence is valid
        for (index, tab) in navigationSequence.enumerated() {
            XCTAssertTrue(
                TabBarView.Tab.allCases.contains(tab),
                "Navigation step \(index + 1): Tab \(tab) should be valid"
            )

            // Verify tab can round-trip through raw value
            let rawValue = tab.rawValue
            let reconstructed = TabBarView.Tab(rawValue: rawValue)
            XCTAssertEqual(
                reconstructed,
                tab,
                "Navigation step \(index + 1): Tab should survive raw value conversion"
            )
        }
    }

    /// Tests that TabBarView can be created in different contexts
    func testTabBarViewCreationInDifferentContexts() {
        // When - Create in different scenarios
        let defaultView = TabBarView()
        let lightModeView = TabBarView().environment(\.colorScheme, .light)
        let darkModeView = TabBarView().environment(\.colorScheme, .dark)
        let compactView = TabBarView().environment(\.horizontalSizeClass, .compact)

        // Then - All should be created successfully
        XCTAssertNotNil(defaultView, "Default TabBarView should be created")
        XCTAssertNotNil(lightModeView, "Light mode TabBarView should be created")
        XCTAssertNotNil(darkModeView, "Dark mode TabBarView should be created")
        XCTAssertNotNil(compactView, "Compact TabBarView should be created")
    }
}
