import SwiftUI

struct OSINTFormLauncherView: View {
    @Environment(\.dismiss) private var dismiss

        // selection must be a set of IDs (Hashable scalar types) for List selection
    @State private var selectedTypeIDs: Set<String> = []
        // store inputs keyed by SearchType.id
    @State private var inputsByID: [String: String] = [:]
    @State private var openInPrivate: Bool = true
    @State private var saveToLog: Bool = true
    @State private var isLaunching: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("OSINT Form Launcher")
                    .font(.title2)
                    .bold()
                Spacer()
                Button("Close") { dismiss() }
            }

            HStack(alignment: .top) {
                    // Types selection
                VStack(alignment: .leading) {
                    Text("Select types:")
                        .font(.headline)
                    List(SearchType.allCases, id: \.id, selection: $selectedTypeIDs) { t in
                        Text(t.displayName).tag(t.id)
                    }
                    .frame(minWidth: 200, minHeight: 200)
                }

                    // Inputs for selected types
                VStack(alignment: .leading, spacing: 8) {
                    Text("Inputs:")
                        .font(.headline)
                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(Array(selectedTypeIDs), id: \.self) { id in
                                if let t = SearchType.allCases.first(where: { $0.id == id }) {
                                    HStack {
                                        Text(t.displayName + ":")
                                            .frame(width: 120, alignment: .trailing)
                                        TextField("Value for \(t.displayName)", text: Binding(
                                            get: { inputsByID[id] ?? "" },
                                            set: { inputsByID[id] = $0 }
                                        ))
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                    }
                                }
                            }
                        }
                        .padding(4)
                    }
                    .frame(minWidth: 300, minHeight: 200)

                    HStack {
                        Toggle("Open in Private Safari Window", isOn: $openInPrivate)
                        Toggle("Save to Documents log", isOn: $saveToLog)
                    }
                }
            }

            HStack {
                Spacer()
                Button(action: saveOnly) {
                    Text("Save")
                }
                .disabled(selectedTypeIDs.isEmpty)

                Button(action: openAndMaybeSave) {
                    if isLaunching {
                        ProgressView()
                    } else {
                        Text("Open in Safari")
                    }
                }
                .keyboardShortcut(.defaultAction)
                .disabled(selectedTypeIDs.isEmpty || isLaunching)
            }
        }
        .padding()
        .frame(minWidth: 720, minHeight: 420)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("OSINT Launcher"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func gatherInputs() -> [SearchType: String] {
        var out: [SearchType: String] = [:]
        for id in selectedTypeIDs {
            if let t = SearchType.allCases.first(where: { $0.id == id }) {
                if let v = inputsByID[id], !v.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    out[t] = v
                }
            }
        }
        return out
    }

    private func openAndMaybeSave() {
        let collected = gatherInputs()
        if collected.isEmpty {
            alertMessage = "No inputs provided for selected types."
            showAlert = true
            return
        }

        let urls = OSINTURLBuilder.buildUrls(from: collected)
        if urls.isEmpty {
            alertMessage = "Could not build any URLs from inputs."
            showAlert = true
            return
        }

        isLaunching = true
        OSINTLauncher.open(urls: urls, openPrivate: openInPrivate) { result in
            isLaunching = false
            switch result {
            case .success:
                if saveToLog {
                    do {
                        try OSINTLauncher.appendLog(inputs: collected, urls: urls, openPrivate: openInPrivate)
                    } catch {
                        alertMessage = "Opened URLs but failed to write log: \(error)"
                        showAlert = true
                        return
                    }
                }
                dismiss()
            case .failure(let err):
                alertMessage = "Failed to open Safari: \(err.localizedDescription)"
                showAlert = true
            }
        }
    }

    private func saveOnly() {
        let collected = gatherInputs()
        if collected.isEmpty {
            alertMessage = "No inputs provided for selected types.";
            showAlert = true
            return
        }

        let urls = OSINTURLBuilder.buildUrls(from: collected)
        do {
            try OSINTLauncher.appendLog(inputs: collected, urls: urls, openPrivate: openInPrivate)
            dismiss()
        } catch {
            alertMessage = "Failed to write log: \(error)"
            showAlert = true
        }
    }
}

struct OSINTFormLauncherView_Previews: PreviewProvider {
    static var previews: some View {
        OSINTFormLauncherView()
            .frame(width: 800, height: 480)
    }
}
