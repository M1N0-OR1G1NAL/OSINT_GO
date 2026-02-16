// Path: AtlasOSINT/Core/Domain/SocialProfile.swift

import Foundation

struct SocialProfile: Codable, Hashable {
    enum Platform: String, Codable {
        case twitter
        case x
        case facebook
        case instagram
        case linkedin
        case github
        case youtube
        case tiktok
        case other
    }

    let platform: Platform
    let handle: String?        // např. "@tron1k" nebo "TRON1K"
    let url: String            // plná URL profilu
}