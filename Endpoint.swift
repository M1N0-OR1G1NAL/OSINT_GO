// Path: AtlasOSINT/Networking/Endpoint.swift

import Foundation

struct Endpoint {
    let url: URL
    let method: String
    let headers: [String: String]

    init?(string: String,
          method: String = "GET",
          headers: [String: String] = [:]) {
        guard let url = URL(string: string) else { return nil }
        self.url = url
        self.method = method
        self.headers = headers
    }
}