// Path: AtlasOSINT/Core/Services/Logger.swift

import Foundation

final class Logger {
    enum Level: String {
        case debug = "DEBUG"
        case info  = "INFO"
        case warn  = "WARN"
        case error = "ERROR"
    }

    func log(_ message: String, level: Level = .info) {
        #if DEBUG
        print("[\(level.rawValue)] \(message)")
        #endif
    }

    func debug(_ message: String) {
        log(message, level: .debug)
    }

    func info(_ message: String) {
        log(message, level: .info)
    }

    func warn(_ message: String) {
        log(message, level: .warn)
    }

    func error(_ message: String) {
        log(message, level: .error)
    }
}