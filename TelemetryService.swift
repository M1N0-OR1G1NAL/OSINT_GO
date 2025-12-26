// Path: AtlasOSINT/Core/Services/TelemetryService.swift

import Foundation

final class TelemetryService {
    private let logger: Logger
    private let isEnabled: Bool

    init(logger: Logger = Logger(), isEnabled: Bool) {
        self.logger = logger
        self.isEnabled = isEnabled
    }

    struct Event {
        let name: String
        let properties: [String: String]
    }

    func track(_ event: Event) {
        guard isEnabled else { return }
        // Tady můžeš napojit skutečný telemetry backend
        logger.debug("Telemetry: \(event.name) \(event.properties)")
    }

    func trackScreen(_ name: String) {
        track(Event(name: "screen_view", properties: ["screen": name]))
    }

    func trackInvestigationRun(source: String) {
        track(Event(name: "investigation_run", properties: ["source": source]))
    }
}