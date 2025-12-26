// Path: AtlasOSINT/Networking/NetworkError.swift

import Foundation

enum NetworkError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case httpStatus(Int)
    case decodingFailed(Error)
}