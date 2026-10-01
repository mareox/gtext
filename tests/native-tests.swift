import AppKit
import Foundation

// Stage 2: settings, zoom, appearance/space defaults, window frame
// validation, manual reload policy. No app launch, no credentials,
// no notifications, no page access. Fabricated data only.
@main
struct NativeTests {
    static func main() {
        var failures = 0
        func check(_ condition: Bool, _ name: String) {
            if !condition {
                failures += 1
                print("FAIL \(name)")
            }
        }

        let suite = UserDefaults(suiteName: "gtext-stage2-tests")!
        suite.removePersistentDomain(forName: "gtext-stage2-tests")

        // Zoom clamping through the store.
        let prefs = PreferencesStore(defaults: suite)
        prefs.setZoom(0.1)
        check(prefs.zoom == 0.50, "zoom 0.1 clamps to 0.50 (got \(prefs.zoom))")
        prefs.setZoom(9)
        check(prefs.zoom == 2.00, "zoom 9 clamps to 2.00 (got \(prefs.zoom))")
        prefs.setZoom(1.33)
        check(abs(prefs.zoom - 1.35) < 0.001, "zoom rounds to 0.05 steps (got \(prefs.zoom))")
        prefs.resetZoom()
        check(prefs.zoom == 1.00, "zoom reset returns 1.00 (got \(prefs.zoom))")

        // Malformed preferences restore safe defaults.
        suite.set("not-a-number", forKey: "gtext.zoom")
        check(PreferencesStore(defaults: suite).zoom == 1.00, "string zoom restores 1.00")
        suite.set(Double.nan, forKey: "gtext.zoom")
        check(PreferencesStore(defaults: suite).zoom == 1.00, "NaN zoom restores 1.00")
        suite.set(Double.infinity, forKey: "gtext.zoom")
        check(PreferencesStore(defaults: suite).zoom == 1.00, "infinite zoom restores 1.00")
        suite.set("neon", forKey: "gtext.appearance")
        check(PreferencesStore(defaults: suite).appearance == .system, "bogus appearance restores system")
        suite.set("everywhere", forKey: "gtext.spaceMode")
        check(PreferencesStore(defaults: suite).spaceMode == .retainOriginal, "bogus space mode restores retainOriginal")
        suite.set("paper", forKey: "gtext.scrollbarMode")
        check(PreferencesStore(defaults: suite).scrollbarMode == .google, "bogus scrollbar restores google")

        // Defaults for a fresh store.
        suite.removePersistentDomain(forName: "gtext-stage2-tests")
        let fresh = PreferencesStore(defaults: suite)
        check(fresh.zoom == 1.00, "fresh zoom is 1.00")
        check(fresh.runInBackground == false, "fresh runInBackground is false")
        check(fresh.unreadBadgeEnabled == true, "fresh unreadBadgeEnabled is true")
        fresh.setZoom(2.0)
        fresh.resetNonSensitivePreferences()
        check(fresh.zoom == 1.00 && fresh.appearance == .system, "reset restores non-sensitive defaults")

        // Frame validation stays on screen.
        let visible = NSRect(x: 0, y: 0, width: 1920, height: 1080)
        let tiny = WindowCoordinator.validatedFrame(NSRect(x: 100, y: 100, width: 200, height: 200), visible: visible)
        check(tiny.width >= 640 && tiny.height >= 480, "tiny frame grows to minimum 640x480 (got \(tiny))")
        check(visible.intersects(tiny), "grown frame stays in visible bounds")
        let offscreen = WindowCoordinator.validatedFrame(NSRect(x: 5000, y: 5000, width: 800, height: 600), visible: visible)
        check(visible.intersects(offscreen), "offscreen frame returns to visible screen")
        let zero = WindowCoordinator.validatedFrame(.zero, visible: visible)
        check(visible.intersects(zero) && zero.width >= 640, "zero frame centers at minimum size")

        // Reload policy: manual recovery, never automatic.
        let terminated = ReloadPolicy.authorize(replyInFlight: false, draftPossiblyNonEmpty: true, warningAccepted: false)
        check(terminated == .promptWarning, "terminated page with unknown draft warns instead of reloading")
        let declined = ReloadPolicy.authorize(replyInFlight: false, draftPossiblyNonEmpty: true, warningAccepted: false)
        check(declined != .reload, "declined warning performs zero reloads")
        let accepted = ReloadPolicy.authorize(replyInFlight: false, draftPossiblyNonEmpty: true, warningAccepted: true)
        check(accepted == .reload, "accepted warning reloads once")
        let clear = ReloadPolicy.authorize(replyInFlight: false, draftPossiblyNonEmpty: false, warningAccepted: false)
        check(clear == .reload, "known-empty composer reloads without warning")
        let inFlight = ReloadPolicy.authorize(replyInFlight: true, draftPossiblyNonEmpty: false, warningAccepted: true)
        check(inFlight == .deniedInFlight, "in-flight reply disables reload")

        // Download helpers: sanitization, destination decision, folder scope, bookmark, login guard.
        check(DownloadCoordinator.sanitizedBaseName("photo.png") == "photo.png", "safe filename preserved")
        check(DownloadCoordinator.sanitizedBaseName("a/b") == "ab", "slash separator dropped")
        check(DownloadCoordinator.sanitizedBaseName("a\u{01}b") == "ab", "control character dropped")
        check(DownloadCoordinator.sanitizedBaseName("   ") == "download", "blank filename falls back")
        check(DownloadCoordinator.sanitizedBaseName("") == "download", "empty filename falls back")
        if case .cancel = DownloadCoordinator.decideDestination(panelURL: nil) {
            check(true, "panel cancel returns cancel")
        } else {
            check(false, "panel cancel returns cancel")
        }
        let chosenURL = URL(fileURLWithPath: "/tmp/gtext-fixture-a.txt")
        if case .save(let url) = DownloadCoordinator.decideDestination(panelURL: chosenURL) {
            check(url == chosenURL, "panel choice saves the exact URL with no silent rename")
        } else {
            check(false, "panel choice saves the exact URL with no silent rename")
        }
        let scopeFolder = URL(fileURLWithPath: "/tmp/gtext-scope")
        check(DownloadCoordinator.isWithin(URL(fileURLWithPath: "/tmp/gtext-scope/a.txt"), folder: scopeFolder) == true, "file inside custom folder is within scope")
        check(DownloadCoordinator.isWithin(URL(fileURLWithPath: "/tmp/elsewhere/a.txt"), folder: scopeFolder) == false, "file outside custom folder is out of scope")
        check(DownloadCoordinator.bookmarkUsable(nil) == false, "nil bookmark requires save panel")
        check(DownloadCoordinator.bookmarkUsable(Data([0, 1, 2, 3])) == false, "malformed bookmark requires save panel")
        check(DownloadCoordinator.isLoginRedirect(url: URL(string: "https://accounts.google.com/signin")!) == true, "Google login redirect never a download")
        check(DownloadCoordinator.isLoginRedirect(url: URL(string: "https://messages.google.com/web/")!) == false, "Messages page not a login redirect")

        // Lifecycle ledger: exactly-once release across success, failure, cancel, duplicates.
        var ledger = DownloadLifecycle()
        let first = NSObject()
        let firstID = ObjectIdentifier(first)
        check(ledger.release(firstID) == false && ledger.releases == 0, "release without acquisition does nothing")
        ledger.acquired(firstID)
        let finishedURL = URL(fileURLWithPath: "/tmp/gtext-scope/a.txt")
        check(ledger.release(firstID) == true && ledger.releases == 1, "acquired access releases exactly once on success")
        ledger.noteFinished(firstID, url: finishedURL)
        check(ledger.finishedURL(for: firstID) == finishedURL, "finished URL recorded only on success")
        check(ledger.release(firstID) == false && ledger.releases == 1, "duplicate terminal callback releases nothing more")
        let second = NSObject()
        let secondID = ObjectIdentifier(second)
        ledger.acquired(secondID)
        check(ledger.release(secondID) == true, "failure path releases held access")
        ledger.clearFinished(secondID)
        check(ledger.finishedURL(for: secondID) == nil, "failed download records no finished URL")
        check(ledger.releases == 2, "failure release counted once")
        let third = NSObject()
        let thirdID = ObjectIdentifier(third)
        ledger.acquired(thirdID)
        check(ledger.release(thirdID) == true, "cancel path releases held access")
        ledger.clearFinished(thirdID)
        check(ledger.finishedURL(for: thirdID) == nil, "cancelled download records no finished URL")
        check(ledger.releases == 3, "cancel release counted once")
        let fourth = NSObject()
        let fourthID = ObjectIdentifier(fourth)
        check(ledger.release(fourthID) == false && ledger.releases == 3, "terminal without acquisition on failed acquire releases nothing")

        // Login item: simulated error leaves actual status off.
        final class FakeLoginService: LoginItemService {
            var enabled: Bool
            let throwsOnSet: Bool
            init(enabled: Bool, throwsOnSet: Bool) {
                self.enabled = enabled
                self.throwsOnSet = throwsOnSet
            }
            var isEnabled: Bool { enabled }
            func setEnabled(_ value: Bool) throws {
                if throwsOnSet {
                    struct Boom: Error {}
                    throw Boom()
                }
                enabled = value
            }
        }
        let failing = LoginItemCoordinator(service: FakeLoginService(enabled: false, throwsOnSet: true))
        check(failing.setEnabled(true) == false, "login-item error reports not enabled")
        check(failing.isEnabled == false, "login-item error keeps actual status")
        let working = LoginItemCoordinator(service: FakeLoginService(enabled: false, throwsOnSet: false))
        check(working.setEnabled(true) == true, "login-item success reports enabled")

        // Stage 4: synthetic notification and dock plumbing. Fakes only;
        // no permission prompt, no banner, no bounce, no sound runs here.
        final class FakePoster: NotificationPoster {
            var authorized = true
            var requestedAuth = false
            var posted: [String] = []
            var canPost: Bool { authorized }
            func requestAuthorization() { requestedAuth = true }
            func post(requestID: String) { posted.append(requestID) }
        }
        final class FakeEffects: DockEffects {
            var active = false
            var badge: String?
            var attentions = 0
            var sounds: [String] = []
            var isAppActive: Bool { active }
            func setBadge(_ text: String?) { badge = text }
            func requestAttention() { attentions += 1 }
            func playSound(named: String?) { sounds.append(named ?? "system") }
        }
        let noteSuite = UserDefaults(suiteName: "gtext-stage4-tests")!
        noteSuite.removePersistentDomain(forName: "gtext-stage4-tests")
        let notePrefs = PreferencesStore(defaults: noteSuite)
        notePrefs.notificationsEnabled = true
        notePrefs.bounceEnabled = true
        notePrefs.soundName = "default"
        let poster = FakePoster()
        let notes = NotificationCoordinator(store: notePrefs, poster: poster)
        let effects = FakeEffects()
        let dock = DockCoordinator(store: notePrefs, effects: effects)
        func syntheticEvent(_ id: String, _ token: String, unread: Int? = 1) -> IncomingEvent {
            IncomingEvent(eventID: id, conversationToken: token, observedAt: Date(timeIntervalSince1970: 1_700_000_000), unreadCount: unread, isHistoryReplay: false, isOutgoing: false)
        }

        // Duplicate event posts and bounces once.
        let dup = syntheticEvent("synthetic-dup-01", "synthetic-convo-dup")
        check(notes.handleIncoming(dup, activeConversationToken: nil) == true, "first delivery posts")
        check(dock.handleFreshIncoming(eventID: dup.eventID) == true, "first delivery bounces")
        check(notes.handleIncoming(dup, activeConversationToken: nil) == false, "duplicate delivery suppressed")
        check(dock.handleFreshIncoming(eventID: dup.eventID) == false, "duplicate delivery bounces nothing more")
        check(poster.posted.filter({ $0 == dup.eventID }).count == 1, "duplicate event yields one synthetic request")
        check(effects.attentions == 1, "duplicate event yields one bounce")
        check(effects.sounds.filter({ $0 == "system" }).count == 1, "duplicate event yields one sound play")

        // Disabled and denied stay quiet.
        notePrefs.notificationsEnabled = false
        check(notes.handleIncoming(syntheticEvent("synthetic-off-01", "synthetic-convo-off"), activeConversationToken: nil) == false, "disabled preference posts nothing")
        notePrefs.notificationsEnabled = true
        poster.authorized = false
        check(notes.handleIncoming(syntheticEvent("synthetic-denied-01", "synthetic-convo-denied"), activeConversationToken: nil) == false, "denied permission posts nothing")
        poster.authorized = true
        check(poster.posted.contains("synthetic-off-01") == false, "disabled event left zero requests")
        check(poster.posted.contains("synthetic-denied-01") == false, "denied event left zero requests")

        // Same visible conversation stays suppressed; bad IDs rejected.
        check(notes.handleIncoming(syntheticEvent("synthetic-active-01", "synthetic-convo-active"), activeConversationToken: "synthetic-convo-active") == false, "active conversation stays quiet")
        check(notes.handleIncoming(syntheticEvent("", "synthetic-convo-x"), activeConversationToken: nil) == false, "empty event ID rejected")
        check(notes.handleIncoming(syntheticEvent(String(repeating: "s", count: 129), "synthetic-convo-x"), activeConversationToken: nil) == false, "oversized event ID rejected")
        var history = syntheticEvent("synthetic-history-01", "synthetic-convo-h")
        history.isHistoryReplay = true
        check(notes.handleIncoming(history, activeConversationToken: nil) == false, "history replay posts nothing")
        var outgoing = syntheticEvent("synthetic-outgoing-01", "synthetic-convo-o")
        outgoing.isOutgoing = true
        check(notes.handleIncoming(outgoing, activeConversationToken: nil) == false, "outgoing echo posts nothing")

        // Badge: unknown and negative stay quiet, positive shows, zero clears.
        dock.setUnreadCount(nil)
        check(effects.badge == nil, "unknown unread sets no badge")
        dock.setUnreadCount(-3)
        check(effects.badge == nil, "negative unread sets no badge")
        dock.setUnreadCount(4)
        check(effects.badge == "4", "positive unread shows badge")
        dock.setUnreadCount(0)
        check(effects.badge == nil, "zero unread clears badge")
        dock.clear()
        check(effects.badge == nil, "clear removes badge")

        // Fixture drive: ten distinct synthetic events yield ten requests.
        let fixtureURL = URL(fileURLWithPath: "tests/fixtures/page-events.html")
        let fixtureHTML = try! String(contentsOf: fixtureURL, encoding: .utf8)
        let fixtureJSON = fixtureHTML.components(separatedBy: "<script type=\"application/json\" id=\"synthetic-events\">")[1]
            .components(separatedBy: "</script>")[0]
        let fixtureData = fixtureJSON.data(using: .utf8)!
        let fixtureRoot = try! JSONSerialization.jsonObject(with: fixtureData) as! [String: Any]
        let fixtureEvents = fixtureRoot["events"] as! [[String: Any]]
        let activeToken = fixtureRoot["activeToken"] as! String
        let fixturePoster = FakePoster()
        let fixtureNotes = NotificationCoordinator(store: notePrefs, poster: fixturePoster)
        var distinctPosted = 0
        for raw in fixtureEvents {
            let event = IncomingEvent(
                eventID: raw["eventID"] as! String,
                conversationToken: raw["conversationToken"] as! String,
                observedAt: Date(timeIntervalSince1970: 1_700_000_000),
                unreadCount: raw["unreadCount"] as? Int,
                isHistoryReplay: raw["isHistoryReplay"] as! Bool,
                isOutgoing: raw["isOutgoing"] as! Bool)
            check(event.eventID.hasPrefix("synthetic-") && event.conversationToken.hasPrefix("synthetic-"), "fixture IDs stay fabricated (\(event.eventID))")
            if fixtureNotes.handleIncoming(event, activeConversationToken: activeToken) {
                distinctPosted += 1
            }
        }
        check(distinctPosted == 10, "ten distinct synthetic events yield ten requests (got \(distinctPosted))")
        check(Set(fixturePoster.posted).count == 10, "ten distinct synthetic request IDs")

        noteSuite.removePersistentDomain(forName: "gtext-stage4-tests")
        suite.removePersistentDomain(forName: "gtext-stage2-tests")

        // Stage 5 preparation: inspection opt-in gate only. No page access here.
        check(InspectionGate.isEnabled(arguments: ["Gtext"], osMajor: 14, osMinor: 0) == false, "inspection off without flag")
        check(InspectionGate.isEnabled(arguments: ["Gtext", "--inspect-page"], osMajor: 14, osMinor: 0) == true, "inspection on with flag on macOS 14")
        check(InspectionGate.isEnabled(arguments: ["Gtext", "--inspect-page"], osMajor: 13, osMinor: 3) == true, "inspection on with flag on macOS 13.3")
        check(InspectionGate.isEnabled(arguments: ["Gtext", "--inspect-page"], osMajor: 13, osMinor: 2) == false, "inspection off below macOS 13.3")
        check(InspectionGate.isEnabled(arguments: ["Gtext", "--inspect-page"], osMajor: 12, osMinor: 6) == false, "inspection off on macOS 12")

        if failures == 0 {
            print("PASS native tests")
        } else {
            exit(1)
        }
    }
}
