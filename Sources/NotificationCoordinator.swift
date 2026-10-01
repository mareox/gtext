import Foundation
import UserNotifications

struct IncomingEvent {
    var eventID: String
    var conversationToken: String
    var observedAt: Date
    var unreadCount: Int?
    var isHistoryReplay: Bool
    var isOutgoing: Bool

    static func isValidID(_ value: String) -> Bool {
        !value.isEmpty && value.count <= 128
    }
}

protocol NotificationPoster {
    var canPost: Bool { get }
    func requestAuthorization()
    func post(requestID: String)
}

final class LiveNotificationPoster: NotificationPoster {
    private(set) var authorized = false

    var canPost: Bool {
        authorized
    }

    func refresh() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            self?.authorized = settings.authorizationStatus == .authorized
        }
    }

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _ in
            self?.authorized = granted
        }
    }

    func post(requestID: String) {
        let content = UNMutableNotificationContent()
        content.title = "Gtext"
        content.body = "New message"
        content.categoryIdentifier = NotificationCoordinator.categoryID
        let request = UNNotificationRequest(identifier: requestID, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}

final class NotificationCoordinator {
    static let categoryID = "GTEXT_MESSAGE"
    private static let seenCap = 1000

    private let store: PreferencesStore
    private let poster: NotificationPoster
    private var seen: [String] = []

    init(store: PreferencesStore, poster: NotificationPoster) {
        self.store = store
        self.poster = poster
    }

    func registerCategory() {
        let category = UNNotificationCategory(identifier: Self.categoryID,
                                              actions: [],
                                              intentIdentifiers: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }

    func requestAuthorization() {
        poster.requestAuthorization()
    }

    @discardableResult
    func handleIncoming(_ event: IncomingEvent, activeConversationToken: String?) -> Bool {
        guard store.notificationsEnabled else { return false }
        guard poster.canPost else { return false }
        guard IncomingEvent.isValidID(event.eventID),
              IncomingEvent.isValidID(event.conversationToken) else { return false }
        guard !event.isHistoryReplay, !event.isOutgoing else { return false }
        if let active = activeConversationToken, active == event.conversationToken { return false }
        guard !seen.contains(event.eventID) else { return false }
        seen.append(event.eventID)
        if seen.count > Self.seenCap {
            seen.removeFirst(seen.count - Self.seenCap)
        }
        poster.post(requestID: event.eventID)
        return true
    }

    func clearAccountState() {
        seen.removeAll()
    }
}
