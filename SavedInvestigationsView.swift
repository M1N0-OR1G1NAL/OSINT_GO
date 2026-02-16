// Path: AtlasOSINT/Features/Ulozene/SavedInvestigationsView.swift

import SwiftUI

struct SavedInvestigationsView: View {
    // Zatím placeholder – napojíš na InvestigationStore
    let saved: [String] = [
        "Investigace #1 – example.com",
        "Investigace #2 – 203.0.113.10",
        "Investigace #3 – Firma XYZ"
    ]

    var body: some View {
        List {
            ForEach(saved, id: \.self) { item in
                Text(item)
            }
        }
        .navigationTitle("Uložené")
    }
}

struct SavedInvestigationsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SavedInvestigationsView()
        }
    }
}