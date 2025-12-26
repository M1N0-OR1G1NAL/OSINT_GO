// Path: AtlasOSINT/Core/Domain/TargetType.swift

import Foundation

enum TargetType: String, Codable, Hashable {
    case domain
    case ipAddress
    case email
    case username
    case company
    case url
    case document
    case device
    case phoneNumber        // 🔥 nové – telefonní číslo
}