//
//  OsintOrchestrator.swift
//  OSINT_GO
//
//  Created by M1N0-H1DDEN on 08.12.2025.
//


import Foundation
import SwiftData

class OsintOrchestrator {
    private let modules: [OsintModule]
    private let context: OsintContext
    private var runningTasks: [UUID: Task<Void, Never>] = [:]
    
    init(modules: [OsintModule] = OsintModule.allModules, context: OsintContext = OsintContext()) {
        self.modules = modules
        self.context = context
    }
    
    func runPlaybook(_ playbook: OsintPlaybook, on investigation: Investigation) async {
        let relevantModules = modules.filter { module in
            playbook.capabilities.contains { capability in
                module.capabilities.contains(capability)
            }
        }
        
        await withTaskGroup(of: ModuleResult?.self) { group in
            for module in relevantModules {
                for target in investigation.targets {
                    if module.supportedTypes.map(\.rawValue).contains(target.type) {
                        group.addTask {
                            do {
                                let result = try await module.execute(on: target, context: self.context)
                                await MainActor.run {
                                    target.results.append(result)
                                    investigation.updatedAt = Date()
                                }
                                return result
                            } catch {
                                print("Module \(module.name) failed: \(error)")
                                return nil
                            }
                        }
                    }
                }
            }
        }
        
        // Calculate overall risk score
        let totalResultCount = investigation.targets.reduce(0) { $0 + $1.results.count }

        if totalResultCount > 0 {
            let totalRisk = investigation.targets.reduce(0) { total, target in
                total + target.results.reduce(0) { $0 + $1.riskScore }
            } / Double(totalResultCount)

            await MainActor.run {
                investigation.riskScore = totalRisk
            }
        } else {
            await MainActor.run {
                investigation.riskScore = 0
            }
        }
    }
}
