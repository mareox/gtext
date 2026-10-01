import AppKit
import WebKit

final class MessagesApp: NSObject, NSApplicationDelegate, WKUIDelegate, WKNavigationDelegate, NSWindowDelegate {
    private var window: NSWindow!
    private var webView: WKWebView!
    private var popupWindows: [ObjectIdentifier: NSWindow] = [:]
    private let store = PreferencesStore()
    private var windowCoordinator: WindowCoordinator!
    private var settingsController: SettingsWindowController?
    private var replyInFlight = false
    private var downloadCoordinator: DownloadCoordinator!
    private var notificationCoordinator: NotificationCoordinator!
    private var dockCoordinator: DockCoordinator!

    func applicationDidFinishLaunching(_ notification: Notification) {
        windowCoordinator = WindowCoordinator(store: store)
        downloadCoordinator = DownloadCoordinator(store: store)
        let poster = LiveNotificationPoster()
        notificationCoordinator = NotificationCoordinator(store: store, poster: poster)
        notificationCoordinator.registerCategory()
        poster.refresh()
        dockCoordinator = DockCoordinator(store: store, effects: LiveDockEffects())
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.pageZoom = store.zoom
        if #available(macOS 13.3, *) {
            let os = ProcessInfo.processInfo.operatingSystemVersion
            webView.isInspectable = InspectionGate.isEnabled(osMajor: os.majorVersion, osMinor: os.minorVersion)
        } else {
            webView.isInspectable = false
        }
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1050, height: 760),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.isReleasedWhenClosed = false
        window.title = "Gtext"
        window.contentView = webView
        windowCoordinator.configure(window)
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        webView.load(URLRequest(url: URL(string: "https://messages.google.com/web/")!))
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        !store.runInBackground
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            window.makeKeyAndOrderFront(nil)
        }
        return true
    }

    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        let alert = NSAlert()
        alert.messageText = "The Google Messages page stopped responding."
        alert.informativeText = "Reloading may lose an unsent draft. Reload only if you are sure there is nothing unsent."
        alert.addButton(withTitle: "Reload Google Messages")
        alert.addButton(withTitle: "Not now")
        if alert.runModal() == .alertFirstButtonReturn {
            requestReloadAfterWarning()
        }
    }

    @objc func openSettings(_ sender: Any?) {
        if settingsController == nil {
            settingsController = SettingsWindowController(store: store, notifications: notificationCoordinator)
        }
        settingsController?.showWindow(sender)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func zoomIn(_ sender: Any?) {
        store.setZoom(store.zoom + PreferencesStore.zoomStep)
        webView.pageZoom = store.zoom
    }

    @objc func zoomOut(_ sender: Any?) {
        store.setZoom(store.zoom - PreferencesStore.zoomStep)
        webView.pageZoom = store.zoom
    }

    @objc func actualSize(_ sender: Any?) {
        store.resetZoom()
        webView.pageZoom = store.zoom
    }

    @objc func reloadMessages(_ sender: Any?) {
        requestReloadAfterWarning()
    }

    private func requestReloadAfterWarning() {
        guard ReloadPolicy.authorize(replyInFlight: replyInFlight,
                                     draftPossiblyNonEmpty: true,
                                     warningAccepted: false) != .deniedInFlight else { return }
        let alert = NSAlert()
        alert.messageText = "Reload Google Messages?"
        alert.informativeText = "The composer may hold an unsent draft. Reloading discards nothing on Google's side, but anything typed and unsent can be lost."
        alert.addButton(withTitle: "Reload")
        alert.addButton(withTitle: "Cancel")
        if alert.runModal() == .alertFirstButtonReturn {
            webView.reload()
        }
    }

    func webView(_ webView: WKWebView,
                 createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction,
                 windowFeatures: WKWindowFeatures) -> WKWebView? {
        guard navigationAction.targetFrame == nil else { return nil }
        let popup = WKWebView(frame: .zero, configuration: configuration)
        popup.uiDelegate = self
        let popupWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 680, height: 720),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        popupWindow.isReleasedWhenClosed = false
        popupWindow.title = "Google sign-in"
        popupWindow.contentView = popup
        popupWindow.delegate = self
        popupWindows[ObjectIdentifier(popup)] = popupWindow
        popupWindow.center()
        popupWindow.makeKeyAndOrderFront(nil)
        return popup
    }

    func webViewDidClose(_ webView: WKWebView) {
        popupWindows[ObjectIdentifier(webView)]?.close()
    }

    func windowWillClose(_ notification: Notification) {
        guard let popupWindow = notification.object as? NSWindow,
              let popup = popupWindow.contentView as? WKWebView else { return }
        popupWindows.removeValue(forKey: ObjectIdentifier(popup))
    }

    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.shouldPerformDownload {
            decisionHandler(.download)
            return
        }
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationResponse: WKNavigationResponse,
                 decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if navigationResponse.isForMainFrame,
           !navigationResponse.canShowMIMEType,
           let url = navigationResponse.response.url,
           !DownloadCoordinator.isLoginRedirect(url: url) {
            decisionHandler(.download)
            return
        }
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView,
                 navigationAction: WKNavigationAction,
                 didBecome download: WKDownload) {
        download.delegate = downloadCoordinator
    }

    func webView(_ webView: WKWebView,
                 navigationResponse: WKNavigationResponse,
                 didBecome download: WKDownload) {
        download.delegate = downloadCoordinator
    }
}

let app = NSApplication.shared
let delegate = MessagesApp()
app.delegate = delegate
app.setActivationPolicy(.regular)
let mainMenu = NSMenu()
let appMenuItem = NSMenuItem()
let appMenu = NSMenu()
appMenu.addItem(withTitle: "Settings...", action: #selector(MessagesApp.openSettings(_:)), keyEquivalent: ",")
appMenu.addItem(NSMenuItem.separator())
appMenu.addItem(withTitle: "Quit Gtext", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
appMenuItem.submenu = appMenu
mainMenu.addItem(appMenuItem)
let viewMenuItem = NSMenuItem()
let viewMenu = NSMenu(title: "View")
viewMenu.addItem(withTitle: "Zoom In", action: #selector(MessagesApp.zoomIn(_:)), keyEquivalent: "+")
viewMenu.addItem(withTitle: "Zoom Out", action: #selector(MessagesApp.zoomOut(_:)), keyEquivalent: "-")
viewMenu.addItem(withTitle: "Actual Size", action: #selector(MessagesApp.actualSize(_:)), keyEquivalent: "0")
viewMenu.addItem(NSMenuItem.separator())
viewMenu.addItem(withTitle: "Reload Google Messages", action: #selector(MessagesApp.reloadMessages(_:)), keyEquivalent: "r")
viewMenuItem.submenu = viewMenu
mainMenu.addItem(viewMenuItem)
let editMenuItem = NSMenuItem()
let editMenu = NSMenu(title: "Edit")
editMenu.addItem(withTitle: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
editMenu.addItem(withTitle: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
editMenu.addItem(withTitle: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")
editMenuItem.submenu = editMenu
mainMenu.addItem(editMenuItem)
app.mainMenu = mainMenu
app.run()
