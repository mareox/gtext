import AppKit

final class WindowCoordinator {
    static let autosaveName = "GtextMainWindow"
    static let minimumSize = NSSize(width: 640, height: 480)

    private let store: PreferencesStore

    init(store: PreferencesStore) {
        self.store = store
    }

    func configure(_ window: NSWindow) {
        window.setFrameAutosaveName(Self.autosaveName)
        let visible = window.screen?.visibleFrame
            ?? NSScreen.main?.visibleFrame
            ?? window.frame
        window.setFrame(Self.validatedFrame(window.frame, visible: visible), display: false)
        applyAppearance(to: window)
        applySpaceMode(to: window)
    }

    func applyAppearance(to window: NSWindow) {
        switch store.appearance {
        case .system:
            window.appearance = nil
        case .light:
            window.appearance = NSAppearance(named: .aqua)
        case .dark:
            window.appearance = NSAppearance(named: .darkAqua)
        }
    }

    func applySpaceMode(to window: NSWindow) {
        switch store.spaceMode {
        case .retainOriginal:
            window.collectionBehavior.remove(.canJoinAllSpaces)
        case .followActive:
            window.collectionBehavior.insert(.moveToActiveSpace)
        }
    }

    static func validatedFrame(_ frame: NSRect, visible: NSRect) -> NSRect {
        var result = frame
        if result.width < minimumSize.width || result.height < minimumSize.height {
            result.size.width = max(result.width, minimumSize.width)
            result.size.height = max(result.height, minimumSize.height)
        }
        if result.width > visible.width {
            result.size.width = visible.width
        }
        if result.height > visible.height {
            result.size.height = visible.height
        }
        if NSEqualRects(result, .zero) || !visible.intersects(result) {
            result.origin.x = visible.midX - result.width / 2
            result.origin.y = visible.midY - result.height / 2
        } else {
            if result.minX < visible.minX { result.origin.x = visible.minX }
            if result.minY < visible.minY { result.origin.y = visible.minY }
            if result.maxX > visible.maxX { result.origin.x = visible.maxX - result.width }
            if result.maxY > visible.maxY { result.origin.y = visible.maxY - result.height }
        }
        return result
    }
}

// MARK: - Reload policy (F17 manual recovery)

enum ReloadAuthorization {
    case reload
    case promptWarning
    case deniedInFlight
}

struct ReloadPolicy {
    static func authorize(replyInFlight: Bool,
                         draftPossiblyNonEmpty: Bool,
                         warningAccepted: Bool) -> ReloadAuthorization {
        if replyInFlight {
            return .deniedInFlight
        }
        if draftPossiblyNonEmpty && !warningAccepted {
            return .promptWarning
        }
        return .reload
    }
}
