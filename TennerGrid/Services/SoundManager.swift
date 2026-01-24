import AVFoundation
import Foundation
#if canImport(UIKit)
    import UIKit
#endif

/// Service responsible for managing sound effects throughout the app
final class SoundManager {
    // MARK: - Singleton

    static let shared = SoundManager()

    // MARK: - Properties

    private var isSoundEnabled: Bool {
        UserDefaults.standard.bool(forKey: "soundEffects")
    }

    /// Audio players for each sound effect (preloaded for minimal latency)
    private var audioPlayers: [SoundAsset: AVAudioPlayer] = [:]

    #if canImport(UIKit)
        /// Audio session configuration (iOS only)
        private let audioSession = AVAudioSession.sharedInstance()
    #endif

    // MARK: - Initialization

    private init() {
        configureAudioSession()
        preloadAllSounds()
    }

    // MARK: - Public Methods

    /// Plays a specific sound effect
    /// - Parameter sound: The sound asset to play
    func play(_ sound: SoundAsset) {
        guard isSoundEnabled else { return }

        // Get the preloaded player or create a new one if needed
        guard let player = audioPlayers[sound] ?? createPlayer(for: sound) else {
            return
        }

        // Reset to beginning and play
        player.currentTime = 0
        player.play()
    }

    /// Plays the click sound (general button tap)
    func playClick() {
        play(.click)
    }

    /// Plays the button tap sound (secondary actions)
    func playButtonTap() {
        play(.buttonTap)
    }

    /// Plays the error sound (invalid move)
    func playError() {
        play(.error)
    }

    /// Plays the success sound (puzzle completion)
    func playSuccess() {
        play(.success)
    }

    /// Stops all currently playing sounds
    func stopAll() {
        audioPlayers.values.forEach { $0.stop() }
    }

    /// Preloads all sound effects for minimal playback latency
    func preloadAllSounds() {
        for sound in SoundAsset.allCases {
            _ = createPlayer(for: sound)
        }
    }

    // MARK: - Private Methods

    /// Configures the audio session for playback
    private func configureAudioSession() {
        #if canImport(UIKit)
            do {
                // Set category to allow sound effects to play alongside other audio
                try audioSession.setCategory(.ambient, mode: .default)
                try audioSession.setActive(true)
            } catch {
                print("Failed to configure audio session: \(error.localizedDescription)")
            }
        #endif
    }

    /// Creates and caches an audio player for a specific sound
    /// - Parameter sound: The sound asset to create a player for
    /// - Returns: The created audio player, or nil if creation failed
    private func createPlayer(for sound: SoundAsset) -> AVAudioPlayer? {
        // Return cached player if it exists
        if let existingPlayer = audioPlayers[sound] {
            return existingPlayer
        }

        // Get the sound file URL
        guard let url = sound.url else {
            print("Sound file not found: \(sound.filename)")
            return nil
        }

        // Create the audio player
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.volume = 1.0

            // Cache the player for reuse
            audioPlayers[sound] = player

            return player
        } catch {
            print("Failed to create audio player for \(sound.filename): \(error.localizedDescription)")
            return nil
        }
    }

    /// Sets the volume for a specific sound effect
    /// - Parameters:
    ///   - volume: Volume level (0.0 to 1.0)
    ///   - sound: The sound asset to adjust
    func setVolume(_ volume: Float, for sound: SoundAsset) {
        guard let player = audioPlayers[sound] else { return }
        player.volume = max(0.0, min(1.0, volume))
    }

    /// Sets the volume for all sound effects
    /// - Parameter volume: Volume level (0.0 to 1.0)
    func setGlobalVolume(_ volume: Float) {
        let clampedVolume = max(0.0, min(1.0, volume))
        audioPlayers.values.forEach { $0.volume = clampedVolume }
    }
}

// MARK: - Debug & Validation

extension SoundManager {
    /// Validates that all sound assets are available and can be loaded
    /// - Returns: Array of sound assets that failed to load
    func validateSounds() -> [SoundAsset] {
        var failedSounds: [SoundAsset] = []

        for sound in SoundAsset.allCases {
            if audioPlayers[sound] == nil, createPlayer(for: sound) == nil {
                failedSounds.append(sound)
            }
        }

        return failedSounds
    }

    /// Prints debug information about loaded sounds
    func printDebugInfo() {
        print("=== SoundManager Debug Info ===")
        print("Sound effects enabled: \(isSoundEnabled)")
        print("Loaded sounds: \(audioPlayers.count)/\(SoundAsset.allCases.count)")

        for sound in SoundAsset.allCases {
            let status = audioPlayers[sound] != nil ? "✓ Loaded" : "✗ Not loaded"
            print("  \(sound.filename): \(status)")
        }
        print("==============================")
    }
}
