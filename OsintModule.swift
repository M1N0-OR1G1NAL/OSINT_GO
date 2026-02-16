// Path: AtlasOSINT/Core/OSINT/OsintModule.swift

import Foundation

protocol OsintModule {
    var id: String { get }
    var displayName: String { get }
    var description: String { get }
    var supportedTargets: [TargetType] { get }

    func capabilities() -> [OsintCapability]

    /// Hlavní exekuce modulu – vrací seznam výsledků pro daný target
    func execute(on target: Target, context: OsintContext) async throws -> [ModuleResult]
}