//
//  ModulesViewModel.swift
//  OSINT_GO
//
//  Created by M1N0-H1DDEN on 08.12.2025.
//


import Foundation
import SwiftData

@MainActor
@Observable
class ModulesViewModel {
    let domainIpModule = DomainIpModule()
    let dnsModule = DNSModule()
    let whoisModule = WhoisModule()
    let emailModule = EmailModule()
    let usernameModule = UsernameModule()
    let companyModule = CompanyModule()
    let phoneModule = PhoneModule()
    
    var selectedModuleForRun: OsintModule?
    
    private let orchestrator = OsintOrchestrator()
    
    func runQuickRecon(on investigation: Investigation) async {
        let playbook = OsintPlaybook.quickRecon
        await orchestrator.runPlaybook(playbook, on: investigation)
    }
}
