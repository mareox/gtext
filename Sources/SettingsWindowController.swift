import AppKit
import ServiceManagement

final class SettingsWindowController: NSWindowController {
    private let store: PreferencesStore

    init(store: PreferencesStore, notifications: NotificationCoordinator) {
        self.store = store
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 560),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "Gtext Settings"
        super.init(window: window)
        window.contentViewController = SettingsViewController(store: store, notifications: notifications)
        window.center()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private final class SettingsViewController: NSViewController {
    private let store: PreferencesStore
    private let notifications: NotificationCoordinator

    init(store: PreferencesStore, notifications: NotificationCoordinator) {
        self.store = store
        self.notifications = notifications
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let scroll = NSScrollView()
        scroll.hasVerticalScroller = true
        scroll.autohidesScrollers = true
        let stack = NSStackView()
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 12
        stack.edgeInsets = NSEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        scroll.documentView = stack
        self.view = scroll

        stack.addArrangedSubview(groupLabel("General"))
        stack.addArrangedSubview(checkRow(title: "Keep running in background after closing window",
                                         keyPath: \PreferencesStore.runInBackground))
        stack.addArrangedSubview(loginRow())
        stack.addArrangedSubview(zoomRow())

        stack.addArrangedSubview(groupLabel("Appearance"))
        stack.addArrangedSubview(popRow(title: "Appearance",
                                       items: AppearanceMode.allCases.map { $0.rawValue },
                                       selected: store.appearance.rawValue,
                                       enabled: true,
                                       reason: nil,
                                       onSelect: { [weak self] raw in
                                           guard let self, let mode = AppearanceMode(rawValue: raw) else { return }
                                           self.store.appearance = mode
                                       }))
        stack.addArrangedSubview(popRow(title: "Spaces",
                                       items: SpaceMode.allCases.map { $0.rawValue },
                                       selected: store.spaceMode.rawValue,
                                       enabled: true,
                                       reason: nil,
                                       onSelect: { [weak self] raw in
                                           guard let self, let mode = SpaceMode(rawValue: raw) else { return }
                                           self.store.spaceMode = mode
                                       }))
        stack.addArrangedSubview(popRow(title: "Scrollbar",
                                       items: ScrollbarMode.allCases.map { $0.rawValue },
                                       selected: store.scrollbarMode.rawValue,
                                       enabled: false,
                                       reason: "Custom scrollbar needs the stage-5 compatibility addendum",
                                       onSelect: { _ in }))

        stack.addArrangedSubview(groupLabel("Notifications"))
        stack.addArrangedSubview(notificationsRow())
        stack.addArrangedSubview(checkRow(title: "Show unread badge",
                                         keyPath: \PreferencesStore.unreadBadgeEnabled))
        stack.addArrangedSubview(checkRow(title: "Bounce Dock icon on new message",
                                         keyPath: \PreferencesStore.bounceEnabled))
        stack.addArrangedSubview(disabledRow(title: "Show message previews",
                                            reason: "Message-preview extraction not approved"))

        stack.addArrangedSubview(groupLabel("Downloads"))
        stack.addArrangedSubview(checkRow(title: "Use custom download folder",
                                         keyPath: \PreferencesStore.useCustomDownloadFolder))
        stack.addArrangedSubview(downloadFolderRow())

        stack.addArrangedSubview(groupLabel("Privacy"))
        stack.addArrangedSubview(disabledRow(title: "Copy OTP codes automatically",
                                            reason: "OTP extraction not approved"))
        stack.addArrangedSubview(disabledRow(title: "Inline replies from notifications",
                                            reason: "Inline reply not approved"))
        stack.addArrangedSubview(disabledRow(title: "Show window after reply",
                                            reason: "Inline reply not approved"))
    }

    private func groupLabel(_ text: String) -> NSTextField {
        let label = NSTextField(labelWithString: text)
        label.font = NSFont.boldSystemFont(ofSize: 13)
        return label
    }

    private func checkRow(title: String, keyPath: ReferenceWritableKeyPath<PreferencesStore, Bool>) -> NSButton {
        let button = NSButton(checkboxWithTitle: title, target: self, action: #selector(checkToggled(_:)))
        button.state = store[keyPath: keyPath] ? .on : .off
        button.identifier = NSUserInterfaceItemIdentifier(title)
        objc_setAssociatedObject(button, &checkKeyHandle, keyPath, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return button
    }

    @objc private func checkToggled(_ sender: NSButton) {
        guard let keyPath = objc_getAssociatedObject(sender, &checkKeyHandle) as? ReferenceWritableKeyPath<PreferencesStore, Bool> else { return }
        store[keyPath: keyPath] = (sender.state == .on)
    }

    private func loginRow() -> NSButton {
        let live = LiveLoginItemService()
        let button = NSButton(checkboxWithTitle: "Open Gtext at login", target: self, action: #selector(loginToggled(_:)))
        button.state = live.isEnabled ? .on : .off
        button.toolTip = "Registers only when you click this checkbox. Never at startup."
        return button
    }

    @objc private func loginToggled(_ sender: NSButton) {
        let live = LiveLoginItemService()
        let coordinator = LoginItemCoordinator(service: live)
        let actual = coordinator.setEnabled(sender.state == .on)
        sender.state = actual ? .on : .off
        if live.needsApproval {
            let alert = NSAlert()
            alert.messageText = "Allow Gtext in Login Items?"
            alert.informativeText = "macOS needs your approval in System Settings before Gtext can open at login."
            alert.addButton(withTitle: "Open System Settings")
            alert.addButton(withTitle: "Later")
            if alert.runModal() == .alertFirstButtonReturn {
                SMAppService.openSystemSettingsLoginItems()
            }
        }
    }

    private func notificationsRow() -> NSButton {
        let button = NSButton(checkboxWithTitle: "Enable notifications", target: self, action: #selector(notificationsToggled(_:)))
        button.state = store.notificationsEnabled ? .on : .off
        button.toolTip = "The system permission prompt appears only when you turn this on."
        return button
    }

    @objc private func notificationsToggled(_ sender: NSButton) {
        let enabled = sender.state == .on
        store.notificationsEnabled = enabled
        if enabled {
            notifications.requestAuthorization()
        }
    }

    private func downloadFolderRow() -> NSStackView {
        let row = NSStackView()
        row.orientation = .horizontal
        row.spacing = 8
        let choose = NSButton(title: "Choose folder...", target: self, action: #selector(chooseDownloadFolder(_:)))
        let label = NSTextField(labelWithString: Self.downloadFolderName(store: store))
        objc_setAssociatedObject(choose, &folderLabelHandle, label, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        row.addArrangedSubview(choose)
        row.addArrangedSubview(label)
        return row
    }

    static func downloadFolderName(store: PreferencesStore) -> String {
        guard let data = store.downloadFolderBookmark,
              !data.isEmpty else { return "No folder chosen" }
        var stale = false
        guard let url = try? URL(resolvingBookmarkData: data,
                                 options: [.withoutUI],
                                 relativeTo: nil,
                                 bookmarkDataIsStale: &stale) else { return "Saved folder unavailable" }
        return url.lastPathComponent
    }

    @objc private func chooseDownloadFolder(_ sender: NSButton) {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        guard panel.runModal() == .OK, let url = panel.url else { return }
        do {
            let bookmark = try url.bookmarkData(options: [.withSecurityScope],
                                                includingResourceValuesForKeys: nil,
                                                relativeTo: nil)
            var stale = false
            guard (try? URL(resolvingBookmarkData: bookmark,
                            options: [.withoutUI],
                            relativeTo: nil,
                            bookmarkDataIsStale: &stale)) != nil else {
                throw NSError(domain: "GtextSettings", code: 1, userInfo: nil)
            }
            store.downloadFolderBookmark = bookmark
            store.useCustomDownloadFolder = true
            (objc_getAssociatedObject(sender, &folderLabelHandle) as? NSTextField)?.stringValue =
                Self.downloadFolderName(store: store)
        } catch {
            store.downloadFolderBookmark = nil
            let alert = NSAlert()
            alert.messageText = "Could not keep access to that folder"
            alert.informativeText = "Gtext will ask where to save each download instead."
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }

    private func disabledRow(title: String, reason: String) -> NSButton {
        let button = NSButton(checkboxWithTitle: "\(title) (disabled: \(reason))", target: nil, action: nil)
        button.state = .off
        button.isEnabled = false
        button.toolTip = reason
        return button
    }

    private func zoomRow() -> NSStackView {
        let row = NSStackView()
        row.orientation = .horizontal
        row.spacing = 8
        let label = NSTextField(labelWithString: "Zoom:")
        let stepper = NSStepper()
        stepper.minValue = PreferencesStore.zoomMinimum
        stepper.maxValue = PreferencesStore.zoomMaximum
        stepper.increment = PreferencesStore.zoomStep
        stepper.doubleValue = store.zoom
        stepper.target = self
        stepper.action = #selector(zoomStepped(_:))
        let value = NSTextField(labelWithString: "\(Int(store.zoom * 100))%")
        value.identifier = NSUserInterfaceItemIdentifier("zoomValue")
        objc_setAssociatedObject(stepper, &zoomLabelHandle, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        let reset = NSButton(title: "Actual size", target: self, action: #selector(zoomReset(_:)))
        row.addArrangedSubview(label)
        row.addArrangedSubview(stepper)
        row.addArrangedSubview(value)
        row.addArrangedSubview(reset)
        return row
    }

    @objc private func zoomStepped(_ sender: NSStepper) {
        store.setZoom(sender.doubleValue)
        updateZoomLabel(after: sender)
    }

    @objc private func zoomReset(_ sender: NSButton) {
        store.resetZoom()
        if let stepper = rowStepper(from: sender) {
            stepper.doubleValue = store.zoom
            updateZoomLabel(after: stepper)
        }
    }

    private func rowStepper(from button: NSButton) -> NSStepper? {
        guard let row = button.superview as? NSStackView else { return nil }
        return row.arrangedSubviews.compactMap { $0 as? NSStepper }.first
    }

    private func updateZoomLabel(after stepper: NSStepper) {
        guard let label = objc_getAssociatedObject(stepper, &zoomLabelHandle) as? NSTextField else { return }
        label.stringValue = "\(Int(store.zoom * 100))%"
    }

    private func popRow(title: String,
                        items: [String],
                        selected: String,
                        enabled: Bool,
                        reason: String?,
                        onSelect: @escaping (String) -> Void) -> NSStackView {
        let row = NSStackView()
        row.orientation = .horizontal
        row.spacing = 8
        let label = NSTextField(labelWithString: enabled ? "\(title):" : "\(title) (disabled\(reason.map { ": \($0)" } ?? "")):")
        let pop = NSPopUpButton(frame: .zero, pullsDown: false)
        pop.addItems(withTitles: items)
        pop.selectItem(withTitle: selected)
        pop.isEnabled = enabled
        pop.toolTip = reason
        let box = SelectionBox(onSelect: onSelect)
        objc_setAssociatedObject(pop, &popBoxHandle, box, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        pop.target = box
        pop.action = #selector(SelectionBox.selected(_:))
        row.addArrangedSubview(label)
        row.addArrangedSubview(pop)
        return row
    }
}

private var checkKeyHandle: UInt8 = 0
private var zoomLabelHandle: UInt8 = 0
private var popBoxHandle: UInt8 = 0
private var folderLabelHandle: UInt8 = 0

private final class SelectionBox: NSObject {
    private let onSelect: (String) -> Void

    init(onSelect: @escaping (String) -> Void) {
        self.onSelect = onSelect
    }

    @objc func selected(_ sender: NSPopUpButton) {
        guard let title = sender.titleOfSelectedItem else { return }
        onSelect(title)
    }
}
