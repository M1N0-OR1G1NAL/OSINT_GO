//
//  InvestigationDetailViewModel.swift
//  OSINT_GO
//
//  Created by M1N0-H1DDEN on 08.12.2025.
//


import Foundation
import SwiftData

@MainActor
@Observable
class InvestigationDetailViewModel {
    private let orchestrator = OsintOrchestrator()
    
    func runQuickRecon(on investigation: Investigation) async {
        let playbook = OsintPlaybook.quickRecon
        await orchestrator.runPlaybook(playbook, on: investigation)
    }
}
