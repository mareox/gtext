import Foundation

enum AppearanceMode: String, CaseIterable {
    case system, light, dark
}

enum SpaceMode: String, CaseIterable {
    case retainOriginal, followActive
}

enum ScrollbarMode: String, CaseIterable {
    case google, system
}

final class PreferencesStore {
    static let zoomMinimum = 0.50
    static let zoomMaximum = 2.00
    static let zoomStep = 0.05
    static let defaultZoom = 1.00

    private enum Keys {
        static let zoom = "gtext.zoom"
        static let appearance = "gtext.appearance"
        static let spaceMode = "gtext.spaceMode"
        static let runInBackground = "gtext.runInBackground"
        static let notificationsEnabled = "gtext.notificationsEnabled"
        static let showNotificationPreviews = "gtext.showNotificationPreviews"
        static let unreadBadgeEnabled = "gtext.unreadBadgeEnabled"
        static let bounceEnabled = "gtext.bounceEnabled"
        static let soundName = "gtext.soundName"
        static let inlineRepliesEnabled = "gtext.inlineRepliesEnabled"
        static let autoCopyOTP = "gtext.autoCopyOTP"
        static let showWindowAfterReply = "gtext.showWindowAfterReply"
        static let useCustomDownloadFolder = "gtext.useCustomDownloadFolder"
        static let scrollbarMode = "gtext.scrollbarMode"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    // MARK: - Zoom

    var zoom: Double {
        get {
            guard let raw = defaults.object(forKey: Keys.zoom) as? Double else {
                return Self.defaultZoom
            }
            return Self.clampZoom(raw)
        }
        set {
            defaults.set(Self.clampZoom(newValue), forKey: Keys.zoom)
        }
    }

    func setZoom(_ value: Double) {
        zoom = value
    }

    func resetZoom() {
        defaults.set(Self.defaultZoom, forKey: Keys.zoom)
    }

    static func clampZoom(_ value: Double) -> Double {
        guard value.isFinite else { return defaultZoom }
        let clamped = min(zoomMaximum, max(zoomMinimum, value))
        return (clamped / zoomStep).rounded() * zoomStep
    }

    // MARK: - Modes

    var appearance: AppearanceMode {
        get {
            guard let raw = defaults.string(forKey: Keys.appearance),
                  let mode = AppearanceMode(rawValue: raw) else { return .system }
            return mode
        }
        set { defaults.set(newValue.rawValue, forKey: Keys.appearance) }
    }

    var spaceMode: SpaceMode {
        get {
            guard let raw = defaults.string(forKey: Keys.spaceMode),
                  let mode = SpaceMode(rawValue: raw) else { return .retainOriginal }
            return mode
        }
        set { defaults.set(newValue.rawValue, forKey: Keys.spaceMode) }
    }

    var scrollbarMode: ScrollbarMode {
        get {
            guard let raw = defaults.string(forKey: Keys.scrollbarMode),
                  let mode = ScrollbarMode(rawValue: raw) else { return .google }
            return mode
        }
        set { defaults.set(newValue.rawValue, forKey: Keys.scrollbarMode) }
    }

    // MARK: - Flags

    var runInBackground: Bool {
        get { defaults.object(forKey: Keys.runInBackground) as? Bool ?? false }
        set { defaults.set(newValue, forKey: Keys.runInBackground) }
    }

    var notificationsEnabled: Bool {
        get { defaults.object(forKey: Keys.notificationsEnabled) as? Bool ?? false }
        set { defaults.set(newValue, forKey: Keys.notificationsEnabled) }
    }

    var showNotificationPreviews: Bool {
        get { defaults.object(forKey: Keys.showNotificationPreviews) as? Bool ?? false }
        set { defaults.set(newValue, forKey: Keys.showNotificationPreviews) }
    }

    var unreadBadgeEnabled: Bool {
        get { defaults.object(forKey: Keys.unreadBadgeEnabled) as? Bool ?? true }
        set { defaults.set(newValue, forKey: Keys.unreadBadgeEnabled) }
    }

    var bounceEnabled: Bool {
        get { defaults.object(forKey: Keys.bounceEnabled) as? Bool ?? false }
        set { defaults.set(newValue, forKey: Keys.bounceEnabled) }
    }

    var soundName: String {
        get { defaults.string(forKey: Keys.soundName) ?? "none" }
        set { defaults.set(newValue, forKey: Keys.soundName) }
    }

    var inlineRepliesEnabled: Bool {
        get { defaults.object(forKey: Keys.inlineRepliesEnabled) as? Bool ?? false }
        set { defaults.set(newValue, forKey: Keys.inlineRepliesEnabled) }
    }

    var autoCopyOTP: Bool {
        get { defaults.object(forKey: Keys.autoCopyOTP) as? Bool ?? false }
        set { defaults.set(newValue, forKey: Keys.autoCopyOTP) }
    }

    var showWindowAfterReply: Bool {
        get { defaults.object(forKey: Keys.showWindowAfterReply) as? Bool ?? false }
        set { defaults.set(newValue, forKey: Keys.showWindowAfterReply) }
    }

    var useCustomDownloadFolder: Bool {
        get { defaults.object(forKey: Keys.useCustomDownloadFolder) as? Bool ?? false }
        set { defaults.set(newValue, forKey: Keys.useCustomDownloadFolder) }
    }

    var downloadFolderBookmark: Data? {
        get { defaults.data(forKey: "gtext.downloadFolderBookmark") }
        set { defaults.set(newValue, forKey: "gtext.downloadFolderBookmark") }
    }

    // MARK: - Reset

    func resetNonSensitivePreferences() {
        defaults.set(Self.defaultZoom, forKey: Keys.zoom)
        defaults.set(AppearanceMode.system.rawValue, forKey: Keys.appearance)
        defaults.set(SpaceMode.retainOriginal.rawValue, forKey: Keys.spaceMode)
        defaults.set(ScrollbarMode.google.rawValue, forKey: Keys.scrollbarMode)
        defaults.set(false, forKey: Keys.runInBackground)
        defaults.set(false, forKey: Keys.notificationsEnabled)
        defaults.set(false, forKey: Keys.showNotificationPreviews)
        defaults.set(true, forKey: Keys.unreadBadgeEnabled)
        defaults.set(false, forKey: Keys.bounceEnabled)
        defaults.set("none", forKey: Keys.soundName)
        defaults.set(false, forKey: Keys.inlineRepliesEnabled)
        defaults.set(false, forKey: Keys.autoCopyOTP)
        defaults.set(false, forKey: Keys.showWindowAfterReply)
        defaults.set(false, forKey: Keys.useCustomDownloadFolder)
    }
}
