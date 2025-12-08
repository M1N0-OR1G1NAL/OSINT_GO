//
//  OsintModule.swift
//  OSINT_GO
//
//  Created by M1N0-H1DDEN on 08.12.2025.
//


import Foundation

protocol OsintModule {
    var name: String { get }
    var capabilities: [OsintCapability] { get }
    var supportedTypes: [TargetType] { get }
    
    func execute(on target: Target, context: OsintContext) async throws -> ModuleResult
}
