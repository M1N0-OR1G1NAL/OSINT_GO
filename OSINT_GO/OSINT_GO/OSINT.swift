//
//  OSINT.swift
//  OSINT_GO
//
//  Created by M1N0-H1DDEN on 09.12.2025.
//


import SwiftUI
import SwiftData

@main
struct OSINT_GOApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: OSINTSearch.self) // Encrypted persistence
    }
}

// MARK: - Core Models
@Model
final class OSINTSearch {
    @Attribute(.unique) var id: UUID
    var query: String
    var results: [OSINTResult]
    var timestamp: Date
    var status: SearchStatus
    
    init(query: String) {
        self.id = UUID()
        self.query = query
        self.results = []
        self.timestamp = Date()
        self.status = .pending
    }
}

enum SearchStatus: String, Codable {
    case pending, running, completed, failed
}

struct OSINTResult: Codable, Identifiable {
    let id = UUID()
    let source: String
    let  String
    let confidence: Double
}

// MARK: - MVVM ViewModel
@Observable
class SearchViewModel {
    var searches: [OSINTSearch] = []
    var isSearching = false
    private let osintService: OSIINTServiceProtocol
    
    init(osintService: OSIINTServiceProtocol = OSINTService()) {
        self.osintService = osintService
    }
    
    func performSearch(_ query: String, modelContext: ModelContext) async {
        let search = OSINTSearch(query: query)
        modelContext.insert(search)
        try? modelContext.save()
        
        await osintService.execute(search: query) { results in
            search.results = results
            search.status = .completed
            try? modelContext.save()
        }
    }
}

// MARK: - Protocols pro modularitu
protocol OSIINTServiceProtocol {
    func execute(search: String, completion: @escaping ([OSINTResult]) -> Void)
}

class OSINTService: OSIINTServiceProtocol {
    func execute(search: String, completion: @escaping ([OSINTResult]) -> Void) {
        // Paralelní OSINT enginy (mock pro demo)
        Task {
            let results = [
                OSINTResult(source: "Shodan",  "IP: 1.2.3.4", confidence: 0.95),
                OSINTResult(source: "VirusTotal",  "Hash: abc123", confidence: 0.87)
            ]
            completion(results)
        }
    }
}

// MARK: - Adaptivní SwiftUI UI (iPhone/iPad/Mac)
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var searchText = ""
    @State private var viewModel = SearchViewModel()
    @Query private var searches: [OSINTSearch]
    
    var body: some View {
        NavigationSplitView {
            // Sidebar (iPad/Mac)
            List(searches) { search in
                NavigationLink(value: search) {
                    VStack(alignment: .leading) {
                        Text(search.query)
                            .font(.headline)
                        Text(search.status.rawValue.capitalized)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("OSINT Searches")
        } label: {
            // iPhone compact
            Image(systemName: "magnifyingglass")
        } detail: {
            // Detail view
            Group {
                if searches.isEmpty {
                    WelcomeView()
                } else {
                    ResultsDetailView()
                }
            }
            .navigationSplitViewColumnWidth(min: 300, ideal: 400)
        }
        .searchable(text: $searchText, prompt: "Zadejte cíl (email, IP, domain)")
        .onSubmit(of: .search) {
            Task {
                await viewModel.performSearch(searchText, modelContext: modelContext)
                searchText = ""
            }
        }
        .task {
            await viewModel.performSearch("demo@example.com", modelContext: modelContext)
        }
        .animation(.easeInOut(duration: 0.3), value: searches)
    }
}

struct WelcomeView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "scope")
                .font(.system(size: 80))
                .foregroundStyle(.accent)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Vítejte v OSINT_GO")
                    .font(.largeTitle.bold())
                Text("Multiplatformní OSINT toolkit pro iOS/iPadOS/Mac")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
            
            Text("Podpora paralelního sběru dat, šifrované persistence a modulárních enginů.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

struct ResultsDetailView: View {
    @Query private var searches: [OSINTSearch]
    
    var body: some View {
        Group {
            if let latest = searches.first {
                List(latest.results) { result in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(result.source)
                                .font(.headline)
                            Text(result.data)
                                .font(.subheadline)
                        }
                        Spacer()
                        Text("\(Int(result.confidence * 100))%")
                            .font(.caption.monospaced())
                            .foregroundStyle(.secondary)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle(searches.first?.query ?? "Výsledky")
    }
}

// MARK: - UX tipy
#Preview {
    ContentView()
        .modelContainer(for: OSINTSearch.self, inMemory: true)
}
