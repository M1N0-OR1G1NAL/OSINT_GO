// Path: AtlasOSINT/Core/OSINT/OsintContext.swift

import Foundation

struct OsintContext {
    let httpClient: HTTPClient
    let logger: Logger
    let telemetry: TelemetryService?

    // sem můžeš přidat další věci (API klíče, konfiguraci modulů, atd.)
    init(
        httpClient: HTTPClient = HTTPClient(),
        logger: Logger = Logger(),
        telemetry: TelemetryService? = nil
    ) {
        self.httpClient = httpClient
        self.logger = logger
        self.telemetry = telemetry
    }
}