//
//  AutomatedAgentService.swift
//  OSINT_GO
//
//  Automated data collection agents for continuous monitoring
//

import Foundation
import Combine

/// Configuration for an automated agent
struct AgentConfiguration: Codable, Identifiable {
    let id: UUID
    let name: String
    let targetId: UUID
    let schedule: AgentSchedule
    let modules: [String] // Module names to run
    let notifyOnNewFindings: Bool
    let enabled: Bool
    let createdAt: Date
    
    enum AgentSchedule: String, Codable {
        case hourly = "Každou hodinu"
        case every6Hours = "Každých 6 hodin"
        case daily = "Denně"
        case weekly = "Týdně"
        case monthly = "Měsíčně"
        
        var interval: TimeInterval {
            switch self {
            case .hourly: return 3600
            case .every6Hours: return 21600
            case .daily: return 86400
            case .weekly: return 604800
            case .monthly: return 2592000
            }
        }
    }
}

/// Result from an automated agent run
struct AgentRunResult: Identifiable {
    let id = UUID()
    let agentId: UUID
    let runDate: Date
    let newFindings: Int
    let moduleResults: [ModuleResult]
    let errors: [String]
    let duration: TimeInterval
}

/// Service managing automated OSINT collection agents
@MainActor
class AutomatedAgentService: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var agents: [AgentConfiguration] = []
    @Published var runHistory: [AgentRunResult] = []
    @Published var isMonitoring: Bool = false
    
    // MARK: - Private Properties
    
    private var timers: [UUID: Timer] = [:]
    private var orchestrator: OsintOrchestrator?
    
    // MARK: - Initialization
    
    init(orchestrator: OsintOrchestrator? = nil) {
        self.orchestrator = orchestrator
        loadAgents()
    }
    
    // MARK: - Agent Management
    
    /// Create a new automated agent
    func createAgent(
        name: String,
        targetId: UUID,
        schedule: AgentConfiguration.AgentSchedule,
        modules: [String],
        notifyOnNewFindings: Bool = true
    ) {
        let agent = AgentConfiguration(
            id: UUID(),
            name: name,
            targetId: targetId,
            schedule: schedule,
            modules: modules,
            notifyOnNewFindings: notifyOnNewFindings,
            enabled: true,
            createdAt: Date()
        )
        
        agents.append(agent)
        saveAgents()
        
        // Start the agent if monitoring is enabled
        if isMonitoring {
            startAgent(agent)
        }
    }
    
    /// Update an existing agent
    func updateAgent(_ agent: AgentConfiguration) {
        if let index = agents.firstIndex(where: { $0.id == agent.id }) {
            agents[index] = agent
            saveAgents()
            
            // Restart the agent with new configuration
            stopAgent(agent.id)
            if agent.enabled && isMonitoring {
                startAgent(agent)
            }
        }
    }
    
    /// Delete an agent
    func deleteAgent(_ agentId: UUID) {
        stopAgent(agentId)
        agents.removeAll { $0.id == agentId }
        runHistory.removeAll { $0.agentId == agentId }
        saveAgents()
    }
    
    /// Enable/disable an agent
    func toggleAgent(_ agentId: UUID) {
        if let index = agents.firstIndex(where: { $0.id == agentId }) {
            var agent = agents[index]
            let newAgent = AgentConfiguration(
                id: agent.id,
                name: agent.name,
                targetId: agent.targetId,
                schedule: agent.schedule,
                modules: agent.modules,
                notifyOnNewFindings: agent.notifyOnNewFindings,
                enabled: !agent.enabled,
                createdAt: agent.createdAt
            )
            agents[index] = newAgent
            saveAgents()
            
            if newAgent.enabled && isMonitoring {
                startAgent(newAgent)
            } else {
                stopAgent(agentId)
            }
        }
    }
    
    // MARK: - Monitoring Control
    
    /// Start all enabled agents
    func startMonitoring() {
        isMonitoring = true
        
        for agent in agents where agent.enabled {
            startAgent(agent)
        }
    }
    
    /// Stop all agents
    func stopMonitoring() {
        isMonitoring = false
        
        for agentId in timers.keys {
            stopAgent(agentId)
        }
    }
    
    /// Manually trigger an agent run
    func runAgentNow(_ agentId: UUID) async {
        guard let agent = agents.first(where: { $0.id == agentId }) else {
            return
        }
        
        await executeAgent(agent)
    }
    
    // MARK: - Private Agent Control
    
    private func startAgent(_ agent: AgentConfiguration) {
        // Stop existing timer if any
        stopAgent(agent.id)
        
        // Create a new timer - capture agent ID only
        let agentId = agent.id
        let timer = Timer.scheduledTimer(
            withTimeInterval: agent.schedule.interval,
            repeats: true
        ) { [weak self] _ in
            Task { @MainActor in
                // Look up current agent configuration
                guard let currentAgent = self?.agents.first(where: { $0.id == agentId }) else {
                    return
                }
                await self?.executeAgent(currentAgent)
            }
        }
        
        timers[agent.id] = timer
        
        // Run immediately on start (optional)
        Task {
            await executeAgent(agent)
        }
    }
    
    private func stopAgent(_ agentId: UUID) {
        timers[agentId]?.invalidate()
        timers.removeValue(forKey: agentId)
    }
    
    // MARK: - Agent Execution
    
    private func executeAgent(_ agent: AgentConfiguration) async {
        let startTime = Date()
        var errors: [String] = []
        var newResults: [ModuleResult] = []
        
        // TODO: Get target from investigation
        // For now, create a mock execution
        
        // Simulate agent execution
        // In real implementation, this would:
        // 1. Get the target by targetId
        // 2. Run specified modules via orchestrator
        // 3. Compare results with previous runs
        // 4. Detect new findings
        // 5. Send notifications if configured
        
        // Mock results for now
        let mockResult = ModuleResult(
            moduleName: "Automated Agent: \(agent.name)",
            targetId: agent.targetId,
            summary: "Agent run completed",
            details: [
                "status": "success",
                "modules_run": agent.modules.count,
                "timestamp": Date()
            ],
            riskScore: 0.3,
            timestamp: Date()
        )
        
        newResults.append(mockResult)
        
        let duration = Date().timeIntervalSince(startTime)
        
        let runResult = AgentRunResult(
            agentId: agent.id,
            runDate: Date(),
            newFindings: newResults.count,
            moduleResults: newResults,
            errors: errors,
            duration: duration
        )
        
        runHistory.append(runResult)
        
        // Keep only last 100 runs per agent
        let agentRuns = runHistory.filter { $0.agentId == agent.id }
        if agentRuns.count > 100 {
            let oldestRuns = agentRuns.sorted { $0.runDate < $1.runDate }.prefix(agentRuns.count - 100)
            runHistory.removeAll { run in
                oldestRuns.contains { $0.id == run.id }
            }
        }
        
        // Send notification if configured and there are new findings
        if agent.notifyOnNewFindings && !newResults.isEmpty {
            sendNotification(for: agent, findings: newResults.count)
        }
    }
    
    // MARK: - Notifications
    
    private func sendNotification(for agent: AgentConfiguration, findings: Int) {
        // TODO: Implement notification system
        // This could send:
        // - Local notifications
        // - Push notifications
        // - Email alerts
        // - Webhook calls
        
        print("📢 Agent '\(agent.name)' found \(findings) new findings")
    }
    
    // MARK: - Persistence
    
    private func loadAgents() {
        // TODO: Load from persistent storage (SwiftData, UserDefaults, etc.)
        // For now, start with empty array
        agents = []
    }
    
    private func saveAgents() {
        // TODO: Save to persistent storage
        // Convert agents to Data and save
        // Also consider saving run history
    }
    
    // MARK: - Statistics
    
    /// Get statistics for an agent
    func getAgentStatistics(_ agentId: UUID) -> AgentStatistics? {
        let runs = runHistory.filter { $0.agentId == agentId }
        
        guard !runs.isEmpty else {
            return nil
        }
        
        let totalRuns = runs.count
        let totalFindings = runs.reduce(0) { $0 + $1.newFindings }
        let avgFindings = Double(totalFindings) / Double(totalRuns)
        let lastRun = runs.max { $0.runDate < $1.runDate }?.runDate
        let avgDuration = runs.reduce(0.0) { $0 + $1.duration } / Double(totalRuns)
        let errorCount = runs.reduce(0) { $0 + $1.errors.count }
        
        return AgentStatistics(
            totalRuns: totalRuns,
            totalFindings: totalFindings,
            averageFindings: avgFindings,
            lastRun: lastRun,
            averageDuration: avgDuration,
            errorCount: errorCount
        )
    }
}

/// Statistics for an agent
struct AgentStatistics {
    let totalRuns: Int
    let totalFindings: Int
    let averageFindings: Double
    let lastRun: Date?
    let averageDuration: TimeInterval
    let errorCount: Int
}

// MARK: - Preset Agent Templates

extension AutomatedAgentService {
    
    /// Predefined agent templates for common use cases
    enum AgentTemplate {
        case socialMediaMonitor
        case breachMonitor
        case reputationTracker
        case domainMonitor
        case comprehensiveMonitor
        
        var name: String {
            switch self {
            case .socialMediaMonitor:
                return "Social Media Monitor"
            case .breachMonitor:
                return "Breach Monitor"
            case .reputationTracker:
                return "Reputation Tracker"
            case .domainMonitor:
                return "Domain Monitor"
            case .comprehensiveMonitor:
                return "Comprehensive Monitor"
            }
        }
        
        var modules: [String] {
            switch self {
            case .socialMediaMonitor:
                return ["Social Media OSINT", "Username OSINT"]
            case .breachMonitor:
                return ["Open Databases OSINT", "Email OSINT"]
            case .reputationTracker:
                return ["Person OSINT", "Company OSINT", "Social Media OSINT"]
            case .domainMonitor:
                return ["Domain/IP OSINT", "DNS Module", "WHOIS Module"]
            case .comprehensiveMonitor:
                return [
                    "Email OSINT",
                    "Phone OSINT",
                    "Username OSINT",
                    "Social Media OSINT",
                    "Open Databases OSINT"
                ]
            }
        }
        
        var recommendedSchedule: AgentConfiguration.AgentSchedule {
            switch self {
            case .socialMediaMonitor:
                return .every6Hours
            case .breachMonitor:
                return .daily
            case .reputationTracker:
                return .weekly
            case .domainMonitor:
                return .daily
            case .comprehensiveMonitor:
                return .daily
            }
        }
    }
    
    /// Create an agent from a template
    func createAgentFromTemplate(
        _ template: AgentTemplate,
        targetId: UUID,
        customName: String? = nil
    ) {
        createAgent(
            name: customName ?? template.name,
            targetId: targetId,
            schedule: template.recommendedSchedule,
            modules: template.modules,
            notifyOnNewFindings: true
        )
    }
}
