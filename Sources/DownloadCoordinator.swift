import AppKit
import Foundation
import WebKit

struct DownloadLifecycle {
    private var heldAccess = Set<ObjectIdentifier>()
    private var finishedURLs = [ObjectIdentifier: URL]()
    private(set) var releases = 0

    mutating func acquired(_ id: ObjectIdentifier) {
        heldAccess.insert(id)
    }

    @discardableResult
    mutating func release(_ id: ObjectIdentifier) -> Bool {
        guard heldAccess.remove(id) != nil else { return false }
        releases += 1
        return true
    }

    mutating func noteFinished(_ id: ObjectIdentifier, url: URL) {
        finishedURLs[id] = url
    }

    mutating func clearFinished(_ id: ObjectIdentifier) {
        finishedURLs.removeValue(forKey: id)
    }

    func finishedURL(for id: ObjectIdentifier) -> URL? {
        finishedURLs[id]
    }
}

enum DestinationDecision {
    case save(URL)
    case cancel
}

final class DownloadCoordinator: NSObject, WKDownloadDelegate {
    private struct ActiveDownload {
        var folder: URL?
        var destination: URL?
    }

    private let store: PreferencesStore
    private var active: [ObjectIdentifier: ActiveDownload] = [:]
    private var lifecycle = DownloadLifecycle()

    init(store: PreferencesStore) {
        self.store = store
    }

    // MARK: - Pure helpers (unit tested)

    static func isLoginRedirect(url: URL) -> Bool {
        guard let host = url.host?.lowercased() else { return false }
        return host == "accounts.google.com" || host.hasSuffix(".accounts.google.com")
    }

    static func sanitizedBaseName(_ name: String) -> String {
        let kept = name.unicodeScalars.filter { scalar in
            scalar.value != 0x2F && scalar.value > 0x1F && scalar.value != 0x7F
        }
        let trimmed = String(kept).trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "download" : trimmed
    }

    static func bookmarkUsable(_ data: Data?) -> Bool {
        guard let data, !data.isEmpty else { return false }
        var stale = false
        let url = try? URL(resolvingBookmarkData: data,
                           options: [.withoutUI],
                           relativeTo: nil,
                           bookmarkDataIsStale: &stale)
        return url != nil
    }

    static func isWithin(_ url: URL, folder: URL) -> Bool {
        let base = folder.standardized.path
        let target = url.standardized.path
        return target == base || target.hasPrefix(base + "/")
    }

    static func decideDestination(panelURL: URL?) -> DestinationDecision {
        guard let url = panelURL else { return .cancel }
        return .save(url)
    }
    // MARK: - WKDownloadDelegate

    func download(_ download: WKDownload,
                  decideDestinationUsing response: URLResponse,
                  suggestedFilename: String,
                  completionHandler: @escaping (URL?) -> Void) {
        let id = ObjectIdentifier(download)
        let panel = NSSavePanel()
        panel.nameFieldStringValue = Self.sanitizedBaseName(suggestedFilename)
        panel.canCreateDirectories = true
        var customFolder: URL?
        if store.useCustomDownloadFolder,
           let data = store.downloadFolderBookmark,
           Self.bookmarkUsable(data) {
            var stale = false
            customFolder = try? URL(resolvingBookmarkData: data,
                                    options: [.withoutUI],
                                    relativeTo: nil,
                                    bookmarkDataIsStale: &stale)
        }
        if let customFolder {
            panel.directoryURL = customFolder
        }
        let accepted = panel.runModal() == .OK
        switch Self.decideDestination(panelURL: accepted ? panel.url : nil) {
        case .cancel:
            active.removeValue(forKey: id)
            lifecycle.clearFinished(id)
            completionHandler(nil)
        case .save(let url):
            var held: URL?
            if let customFolder,
               Self.isWithin(url, folder: customFolder),
               customFolder.startAccessingSecurityScopedResource() {
                held = customFolder
                lifecycle.acquired(id)
            }
            active[id] = ActiveDownload(folder: held, destination: url)
            completionHandler(url)
        }
    }

    func downloadDidFinish(_ download: WKDownload) {
        let id = ObjectIdentifier(download)
        guard let record = active.removeValue(forKey: id) else { return }
        if lifecycle.release(id) {
            record.folder?.stopAccessingSecurityScopedResource()
        }
        guard let url = record.destination else { return }
        lifecycle.noteFinished(id, url: url)
        let alert = NSAlert()
        alert.messageText = "Download finished"
        alert.informativeText = url.lastPathComponent
        alert.addButton(withTitle: "Reveal in Finder")
        alert.addButton(withTitle: "OK")
        if alert.runModal() == .alertFirstButtonReturn,
           let finished = lifecycle.finishedURL(for: id) {
            NSWorkspace.shared.activateFileViewerSelecting([finished])
        }
    }

    func download(_ download: WKDownload, didFailWithError error: Error, resumeData: Data?) {
        let id = ObjectIdentifier(download)
        let record = active.removeValue(forKey: id)
        if lifecycle.release(id) {
            record?.folder?.stopAccessingSecurityScopedResource()
        }
        lifecycle.clearFinished(id)
        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled {
            return
        }
        let alert = NSAlert()
        alert.messageText = "Download failed"
        alert.informativeText = error.localizedDescription
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}
