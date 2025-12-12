//
//  OsintModule.swift
//  OSINT_GO
//
//  Created by M1N0-H1DDEN on 08.12.2025.
//


import Foundation
import SwiftUI

protocol OsintModule {
    var name: String { get }
    var capabilities: [OsintCapability] { get }
    var supportedTypes: [TargetType] { get }
    var iconName: String { get }
    var color: Color { get }
    var description: String { get }
    
    func execute(on target: Target, context: OsintContext) async throws -> ModuleResult
}

extension OsintModule {
    var iconName: String { "magnifyingglass" }
    var color: Color { .blue }
    var description: String { "OSINT module for \(name)" }
}
