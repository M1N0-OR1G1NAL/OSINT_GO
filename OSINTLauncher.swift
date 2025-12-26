import SwiftUI

struct OSINTFormLauncherView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var selected: [SearchType: Bool] = {
        var dict: [SearchType: Bool] = [:]
        for t in SearchType.allCases { dict[t] = false }
        return dict
    }()

    @State private var inputs: [SearchType: String] = [:]
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
                VStack(alignment: .leading) {
                    Text("Select types:")
                        .font(.headline)
                        // simple checkbox list to avoid complex List selection types
                    ForEach(SearchType.allCases, id: \.self) { t in
                        Toggle(isOn: Binding(get: { selected[t] ?? false }, set: { selected[t] = $0 })) {
                            Text(t.displayName)
                        }
                    }
                    .frame(minWidth: 220)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Inputs:")
                        .font(.headline)

                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(SearchType.allCases.filter({ selected[$0] ?? false }), id: \.self) { t in
                                HStack {
                                    Text(t.displayName + ":")
                                        .frame(width: 120, alignment: .trailing)
                                    TextField("Value for \(t.displayName)", text: Binding(
                                        get: { inputs[t] ?? "" },
                                        set: { inputs[t] = $0 }
                                    ))
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
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
                .disabled(!hasAnyInput())

                Button(action: openAndMaybeSave) {
                    if isLaunching { ProgressView() } else { Text("Open in Safari") }
                }
                .keyboardShortcut(.defaultAction)
                .disabled(!hasAnyInput() || isLaunching)
            }
        }
        .padding()
        .frame(minWidth: 720, minHeight: 420)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("OSINT Launcher"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .onAppear {
                // ensure inputs dict contains entries for each type
            for t in SearchType.allCases { if inputs[t] == nil { inputs[t] = "" } }
        }
    }

    private func hasAnyInput() -> Bool {
        for (t, on) in selected {
            if on, let v = inputs[t], !v.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return true }
        }
        return false
    }

    private func gatherInputs() -> [SearchType: String] {
        var out: [SearchType: String] = [:]
        for (t, on) in selected {
            if on, let v = inputs[t], !v.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                out[t] = v
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
            DispatchQueue.main.async {
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
                    alertMessage = "Failed to open browser: \(err.localizedDescription)"
                    showAlert = true
                }
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
