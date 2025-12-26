//
//  SecureReconWebView.swift
//  Secure_Recon
//
//  Created by M1N0-H1DDEN on 29.11.2025.
//


import SwiftUI
import WebKit

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// Public SwiftUI view, které používáš v ContentView
struct SecureReconWebView: View {
    var body: some View {
        SecureReconWebViewRepresentable()
    }
}

// Typalias pro multiplatform wrapper
#if os(iOS)
typealias PlatformViewRepresentable = UIViewRepresentable
#elseif os(macOS)
typealias PlatformViewRepresentable = NSViewRepresentable
#endif

struct SecureReconWebViewRepresentable: PlatformViewRepresentable {

    // MARK: - Coordinator (bridge JS <-> Swift)
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    // iOS varianta
    #if os(iOS)
    func makeUIView(context: Context) -> WKWebView {
        createWebView(context: context)
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Není potřeba nic – HTML je statické, JS si žije vlastním životem
    }
    #elseif os(macOS)
    // macOS varianta
    func makeNSView(context: Context) -> WKWebView {
        createWebView(context: context)
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        // Stejně jako výše – update netřeba
    }
    #endif

    // MARK: - Shared factory

    private func createWebView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let contentController = WKUserContentController()

        // Bridge jménem "engine" – z JS voláš window.webkit.messageHandlers.engine.postMessage(...)
        contentController.add(context.coordinator, name: "engine")
        config.userContentController = contentController

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator

        // Načíst tvůj index.html + povolit přístup ke styles.css + script.js
        if let url = Bundle.main.url(forResource: "index", withExtension: "html") {
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        } else {
            let html = """
            <html><body style="background:black;color:#0f0;font-family:monospace">
            <h1>index.html nenalezen v bundle</h1>
            </body></html>
            """
            webView.loadHTMLString(html, baseURL: nil)
        }

        return webView
    }

    // MARK: - Coordinator (JS bridge)

    class Coordinator: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
        private let iCloudStore = NSUbiquitousKeyValueStore.default

        // Zde končí všechny zprávy z tvého script.js
        func userContentController(_ userContentController: WKUserContentController,
                                   didReceive message: WKScriptMessage) {
            guard message.name == "engine" else { return }

            guard
                let dict = message.body as? [String: Any],
                let type = dict["type"] as? String
            else { return }

            switch type {
            case "log":
                if let text = dict["text"] as? String {
                    appendLog(text)
                }

            case "openURL":
                if let urlString = dict["url"] as? String,
                   let url = URL(string: urlString) {
                    openExternal(url)
                }

            case "saveSettings":
                if let settings = dict["settings"] as? [String: Any] {
                    // Např. uložení režimu trackerů / tématu do iCloudu
                    iCloudStore.set(settings, forKey: "ui_settings")
                    iCloudStore.synchronize()
                }

            default:
                break
            }
        }

        // Jednoduchý iCloud log – můžeš to používat jako náhradu za .log soubory
        private func appendLog(_ text: String) {
            let key = "recon_log"
            let previous = iCloudStore.string(forKey: key) ?? ""
            let formatter = ISO8601DateFormatter()
            let line = "[\(formatter.string(from: Date()))] \(text)\n"
            iCloudStore.set(previous + line, forKey: key)
            iCloudStore.synchronize()
        }

        // Otevírání OSINT URL přes nativní API
        private func openExternal(_ url: URL) {
            #if os(iOS)
            UIApplication.shared.open(url)
            #elseif os(macOS)
            NSWorkspace.shared.open(url)
            #endif
        }
    }
}
