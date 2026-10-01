import AppKit
import Foundation

protocol DockEffects {
    var isAppActive: Bool { get }
    func setBadge(_ text: String?)
    func requestAttention()
    func playSound(named: String?)
}

final class LiveDockEffects: DockEffects {
    var isAppActive: Bool {
        NSApp.isActive
    }

    func setBadge(_ text: String?) {
        NSApp.dockTile.badgeLabel = text ?? ""
    }

    func requestAttention() {
        _ = NSApp.requestUserAttention(.informationalRequest)
    }
    func playSound(named: String?) {
        if let named, let sound = NSSound(named: named) {
            sound.play()
        } else {
            NSSound(named: "Funk")?.play()
        }
    }
}

final class DockCoordinator {
    private static let seenCap = 1000

    private let store: PreferencesStore
    private let effects: DockEffects
    private var seen: [String] = []

    init(store: PreferencesStore, effects: DockEffects) {
        self.store = store
        self.effects = effects
    }

    func setUnreadCount(_ count: Int?) {
        guard let count, count > 0 else {
            effects.setBadge(nil)
            return
        }
        effects.setBadge("\(count)")
    }

    func clear() {
        effects.setBadge(nil)
    }

    @discardableResult
    func handleFreshIncoming(eventID: String) -> Bool {
        guard IncomingEvent.isValidID(eventID), !seen.contains(eventID) else { return false }
        seen.append(eventID)
        if seen.count > Self.seenCap {
            seen.removeFirst(seen.count - Self.seenCap)
        }
        if !effects.isAppActive, store.bounceEnabled {
            effects.requestAttention()
        }
        let name = store.soundName
        if name != "none" {
            effects.playSound(named: name == "default" ? nil : name)
        }
        return true
    }
}
