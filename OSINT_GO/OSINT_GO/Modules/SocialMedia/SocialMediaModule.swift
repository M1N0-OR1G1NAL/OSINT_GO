//
//  SocialMediaModule.swift
//  OSINT_GO
//
//  Created by M1N0-H1DDEN on 08.12.2025.
//


import Foundation

struct SocialMediaModule: OsintModule {
    let name = "Social Media OSINT"
    let capabilities: [OsintCapability] = [.socialMediaSearch]
    let supportedTypes: [TargetType] = [.username, .email, .personName, .phone]
    
    func execute(on target: Target, context: OsintContext) async throws -> ModuleResult {
        var details: [String: Any] = [:]
        var riskScore: Double = 0.0
        
        let value = target.value.trimmingCharacters(in: .whitespaces)
        let targetType = TargetType(rawValue: target.type)
        
        // Generate queries based on target type
        switch targetType {
        case .username:
            details["username_queries"] = generateUsernameQueries(value)
        case .email:
            details["email_queries"] = generateEmailQueries(value)
        case .personName:
            details["person_queries"] = generatePersonQueries(value)
        case .phone:
            details["phone_queries"] = generatePhoneQueries(value)
        default:
            details["generic_queries"] = generateGenericQueries(value)
        }
        
        // Platform-specific search strategies
        details["facebook"] = getFacebookSearchStrategies(value)
        details["instagram"] = getInstagramSearchStrategies(value)
        details["tiktok"] = getTikTokSearchStrategies(value)
        details["twitter"] = getTwitterSearchStrategies(value)
        details["linkedin"] = getLinkedInSearchStrategies(value)
        
        // Advanced OSINT techniques
        details["advanced_techniques"] = getAdvancedTechniques(value)
        
        riskScore = 0.2
        
        return ModuleResult(
            moduleName: name,
            targetId: target.id,
            summary: "Social media search strategies generated for: \(value)",
            details: details,
            riskScore: riskScore,
            timestamp: Date()
        )
    }
    
    private func generateUsernameQueries(_ username: String) -> [String: String] {
        let encoded = username.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? username
        return [
            "Cross-platform": "https://namechk.com/\(encoded)",
            "Sherlock": "Manual: Use Sherlock tool for comprehensive username search",
            "WhatsMyName": "https://whatsmyname.app/",
            "Social Searcher": "https://www.social-searcher.com/search-users/?q=\(encoded)"
        ]
    }
    
    private func generateEmailQueries(_ email: String) -> [String: String] {
        let encoded = email.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? email
        return [
            "Gravatar": "https://en.gravatar.com/\(email.split(separator: "@").first ?? "")",
            "Have I Been Pwned": "https://haveibeenpwned.com/",
            "Email Rep": "https://emailrep.io/\(encoded)"
        ]
    }
    
    private func generatePersonQueries(_ name: String) -> [String: String] {
        let encoded = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? name
        return [
            "Pipl": "https://pipl.com/search/?q=\(encoded)",
            "TrueCaller": "https://www.truecaller.com/search/\(encoded)",
            "Social Mention": "https://socialmention.com/search?q=\(encoded)"
        ]
    }
    
    private func generatePhoneQueries(_ phone: String) -> [String: String] {
        let cleaned = phone.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "+", with: "")
        return [
            "TrueCaller": "https://www.truecaller.com/",
            "Social Media Search": "https://www.google.com/search?q=\"\(cleaned)\"+site:facebook.com+OR+site:instagram.com"
        ]
    }
    
    private func generateGenericQueries(_ value: String) -> [String: String] {
        let encoded = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? value
        return [
            "Google": "https://www.google.com/search?q=\"\(encoded)\"",
            "Social Searcher": "https://www.social-searcher.com/search-users/?q=\(encoded)"
        ]
    }
    
    private func getFacebookSearchStrategies(_ value: String) -> [String: String] {
        let encoded = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? value
        return [
            "People": "https://www.facebook.com/search/people?q=\(encoded)",
            "Posts": "https://www.facebook.com/search/posts?q=\(encoded)",
            "Photos": "https://www.facebook.com/search/photos?q=\(encoded)",
            "Videos": "https://www.facebook.com/search/videos?q=\(encoded)",
            "Groups": "https://www.facebook.com/search/groups?q=\(encoded)",
            "Pages": "https://www.facebook.com/search/pages?q=\(encoded)",
            "Places": "https://www.facebook.com/search/places?q=\(encoded)",
            "Events": "https://www.facebook.com/search/events?q=\(encoded)",
            "Advanced": "Use Facebook's Graph Search syntax for detailed queries"
        ]
    }
    
    private func getInstagramSearchStrategies(_ value: String) -> [String: String] {
        let encoded = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? value
        let hashtag = value.replacingOccurrences(of: " ", with: "").lowercased()
        return [
            "Search": "https://www.instagram.com/explore/search/keyword/?q=\(encoded)",
            "Hashtag": "https://www.instagram.com/explore/tags/\(hashtag)/",
            "Location": "https://www.instagram.com/explore/locations/",
            "Picuki (viewer)": "https://www.picuki.com/search/\(encoded)",
            "Gramhir (viewer)": "https://gramhir.com/",
            "Tips": "Use location tags, hashtags, and tagged photos for better results"
        ]
    }
    
    private func getTikTokSearchStrategies(_ value: String) -> [String: String] {
        let encoded = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? value
        return [
            "Users": "https://www.tiktok.com/search/user?q=\(encoded)",
            "Videos": "https://www.tiktok.com/search/video?q=\(encoded)",
            "Hashtag": "https://www.tiktok.com/tag/\(value.replacingOccurrences(of: " ", with: "").lowercased())",
            "Sound": "https://www.tiktok.com/music/\(encoded)",
            "External viewer": "https://urlebird.com/",
            "Tips": "Check trending sounds, challenges, and duets"
        ]
    }
    
    private func getTwitterSearchStrategies(_ value: String) -> [String: String] {
        let encoded = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? value
        return [
            "Users": "https://twitter.com/search?q=\"\(encoded)\"&f=user",
            "Latest": "https://twitter.com/search?q=\"\(encoded)\"&f=live",
            "Photos": "https://twitter.com/search?q=\"\(encoded)\"&f=image",
            "Videos": "https://twitter.com/search?q=\"\(encoded)\"&f=video",
            "Advanced search": "https://twitter.com/search-advanced",
            "Tips": "Use advanced operators: from:, to:, filter:, lang:, since:, until:"
        ]
    }
    
    private func getLinkedInSearchStrategies(_ value: String) -> [String: String] {
        let encoded = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? value
        return [
            "People": "https://www.linkedin.com/search/results/people/?keywords=\(encoded)",
            "Companies": "https://www.linkedin.com/search/results/companies/?keywords=\(encoded)",
            "Jobs": "https://www.linkedin.com/search/results/jobs/?keywords=\(encoded)",
            "Posts": "https://www.linkedin.com/search/results/content/?keywords=\(encoded)",
            "Groups": "https://www.linkedin.com/search/results/groups/?keywords=\(encoded)",
            "Schools": "https://www.linkedin.com/search/results/schools/?keywords=\(encoded)",
            "Tips": "Use Boolean operators and filters for better results"
        ]
    }
    
    private func getAdvancedTechniques(_ value: String) -> [String: Any] {
        return [
            "OSINT Tools": [
                "Maltego": "Graph-based OSINT tool for relationship mapping",
                "Spiderfoot": "Automated OSINT collection",
                "Recon-ng": "Web reconnaissance framework",
                "theHarvester": "Email, subdomain, and name harvester",
                "Social Analyzer": "API-based social media analyzer"
            ],
            "Google Dorks": [
                "site:facebook.com \"\(value)\"",
                "site:instagram.com \"\(value)\"",
                "site:twitter.com \"\(value)\"",
                "site:linkedin.com \"\(value)\"",
                "inurl:profile \"\(value)\""
            ],
            "Cached Content": [
                "Google Cache": "cache:\(value)",
                "Wayback Machine": "https://web.archive.org/",
                "Archive.today": "https://archive.today/"
            ],
            "Metadata Analysis": "Check photos for EXIF data (location, camera, date)",
            "Reverse Image Search": "Google Images, TinEye, Yandex Images",
            "Legal Note": "Always follow platform ToS and local privacy laws"
        ]
    }
}
