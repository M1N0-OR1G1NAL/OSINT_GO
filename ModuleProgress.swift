// filepath: /Library/Developer/X-Code/OSINT/OSINT/Core/OSINT/ModuleProgress.swift

import Foundation

enum ModuleStatus: String, Codable {
    case queued
    case running
    case success
    case failed
}

struct ModuleResultSummary: Codable, Sendable {
    let moduleName: String
    let targetId: UUID
    let summary: String
    let riskScore: Double
    let timestamp: Date
}

struct ModuleProgress: Identifiable, Sendable {
    let id: UUID
    let targetId: UUID
    let targetValue: String
    let moduleName: String
    var status: ModuleStatus
    var progress: Double? // 0.0 .. 1.0 if known
    var resultSummary: ModuleResultSummary?
    var errorMessage: String?

    init(id: UUID = UUID(), targetId: UUID, targetValue: String, moduleName: String, status: ModuleStatus = .queued, progress: Double? = nil) {
        self.id = id
        self.targetId = targetId
        self.targetValue = targetValue
        self.moduleName = moduleName
        self.status = status
        self.progress = progress
    }
}
