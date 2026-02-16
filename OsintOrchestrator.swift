// Path: AtlasOSINT/Core/OSINT/OsintOrchestrator.swift

import Foundation

/// Orchestruje spuštění více modulů nad jedním nebo více targety.
final class OsintOrchestrator {
    private let modules: [OsintModule]
    private let context: OsintContext

    init(modules: [OsintModule], context: OsintContext) {
        self.modules = modules
        self.context = context
    }

    /// Spustí všechny kompatibilní moduly nad daným targetem.
    func runAll(for target: Target) async -> [ModuleResult] {
        let applicable = modules.filter { $0.supportedTargets.contains(target.type) }
        guard !applicable.isEmpty else { return [] }

        var collected: [ModuleResult] = []
        await withTaskGroup(of: [ModuleResult].self) { group in
            for module in applicable {
                group.addTask { [context] in
                    do {
                        let results = try await module.execute(on: target, context: context)
                        return results
                    } catch {
                        context.logger.error("Module \(module.id) failed: \(error)")
                        return []
                    }
                }
            }

            for await results in group {
                collected.append(contentsOf: results)
            }
        }

        return collected
    }

    /// Spustí všechny moduly pro každý target v investigaci a vrátí mapu výsledků.
    func runForInvestigation(_ investigation: Investigation) async -> [UUID: [ModuleResult]] {
        var map: [UUID: [ModuleResult]] = [:]

        for target in investigation.targets {
            let results = await runAll(for: target)
            map[target.id] = results
        }

        return map
    }
}