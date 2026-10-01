import Foundation
import ServiceManagement

protocol LoginItemService {
    var isEnabled: Bool { get }
    func setEnabled(_ enabled: Bool) throws
}

final class LiveLoginItemService: LoginItemService {
    var isEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    var needsApproval: Bool {
        SMAppService.mainApp.status == .requiresApproval
    }

    func setEnabled(_ enabled: Bool) throws {
        if enabled {
            try SMAppService.mainApp.register()
        } else {
            try SMAppService.mainApp.unregister()
        }
    }
}

final class LoginItemCoordinator {
    private let service: LoginItemService

    init(service: LoginItemService) {
        self.service = service
    }

    var isEnabled: Bool {
        service.isEnabled
    }

    @discardableResult
    func setEnabled(_ enabled: Bool) -> Bool {
        do {
            try service.setEnabled(enabled)
        } catch {
            // Denied or failed: fall through and report actual status.
        }
        return service.isEnabled
    }
}
