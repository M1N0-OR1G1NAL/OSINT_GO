//
//  UsernameModule.swift
//  OSINT_GO
//
//  Created by M1N0-H1DDEN on 08.12.2025.
//


import Foundation

struct UsernameModule: OsintModule {
    let name = "Username OSINT"
    let capabilities: [OsintCapability] = [.usernameCheck]
    let supportedTypes: [TargetType] = [.username]
    
    private struct Platform {
        let name: String
        let urlTemplate: String
        let expectedStatusCode: Int
        
        static let platforms: [Platform] = [
            // Top Social Networks
            Platform(name: "GitHub", urlTemplate: "https://github.com/{username}", expectedStatusCode: 200),
            Platform(name: "Twitter/X", urlTemplate: "https://x.com/{username}", expectedStatusCode: 200),
            Platform(name: "Instagram", urlTemplate: "https://www.instagram.com/{username}/", expectedStatusCode: 200),
            Platform(name: "Reddit", urlTemplate: "https://www.reddit.com/user/{username}", expectedStatusCode: 200),
            Platform(name: "Facebook", urlTemplate: "https://www.facebook.com/{username}", expectedStatusCode: 200),
            Platform(name: "TikTok", urlTemplate: "https://www.tiktok.com/@{username}", expectedStatusCode: 200),
            Platform(name: "LinkedIn", urlTemplate: "https://www.linkedin.com/in/{username}", expectedStatusCode: 200),
            Platform(name: "YouTube", urlTemplate: "https://www.youtube.com/@{username}", expectedStatusCode: 200),
            Platform(name: "Twitch", urlTemplate: "https://www.twitch.tv/{username}", expectedStatusCode: 200),
            
            // Gaming & Streaming
            Platform(name: "Steam", urlTemplate: "https://steamcommunity.com/id/{username}", expectedStatusCode: 200),
            Platform(name: "Xbox", urlTemplate: "https://xboxgamertag.com/search/{username}", expectedStatusCode: 200),
            Platform(name: "PlayStation", urlTemplate: "https://psnprofiles.com/{username}", expectedStatusCode: 200),
            Platform(name: "Kick", urlTemplate: "https://kick.com/{username}", expectedStatusCode: 200),
            Platform(name: "Mixer", urlTemplate: "https://mixer.com/{username}", expectedStatusCode: 200),
            
            // Developer Platforms
            Platform(name: "GitLab", urlTemplate: "https://gitlab.com/{username}", expectedStatusCode: 200),
            Platform(name: "Bitbucket", urlTemplate: "https://bitbucket.org/{username}", expectedStatusCode: 200),
            Platform(name: "StackOverflow", urlTemplate: "https://stackoverflow.com/users/{username}", expectedStatusCode: 200),
            Platform(name: "CodePen", urlTemplate: "https://codepen.io/{username}", expectedStatusCode: 200),
            Platform(name: "Dev.to", urlTemplate: "https://dev.to/{username}", expectedStatusCode: 200),
            Platform(name: "HackerRank", urlTemplate: "https://www.hackerrank.com/{username}", expectedStatusCode: 200),
            Platform(name: "Kaggle", urlTemplate: "https://www.kaggle.com/{username}", expectedStatusCode: 200),
            
            // Creative & Media
            Platform(name: "Pinterest", urlTemplate: "https://www.pinterest.com/{username}", expectedStatusCode: 200),
            Platform(name: "Behance", urlTemplate: "https://www.behance.net/{username}", expectedStatusCode: 200),
            Platform(name: "Dribbble", urlTemplate: "https://dribbble.com/{username}", expectedStatusCode: 200),
            Platform(name: "DeviantArt", urlTemplate: "https://www.deviantart.com/{username}", expectedStatusCode: 200),
            Platform(name: "ArtStation", urlTemplate: "https://www.artstation.com/{username}", expectedStatusCode: 200),
            Platform(name: "Flickr", urlTemplate: "https://www.flickr.com/people/{username}", expectedStatusCode: 200),
            Platform(name: "Vimeo", urlTemplate: "https://vimeo.com/{username}", expectedStatusCode: 200),
            Platform(name: "SoundCloud", urlTemplate: "https://soundcloud.com/{username}", expectedStatusCode: 200),
            Platform(name: "Spotify", urlTemplate: "https://open.spotify.com/user/{username}", expectedStatusCode: 200),
            
            // Messaging & Communication
            Platform(name: "Telegram", urlTemplate: "https://t.me/{username}", expectedStatusCode: 200),
            Platform(name: "Discord Server", urlTemplate: "https://discord.gg/{username}", expectedStatusCode: 200),
            Platform(name: "Skype", urlTemplate: "https://skype:{username}?userinfo", expectedStatusCode: 200),
            
            // Social & Dating
            Platform(name: "Snapchat", urlTemplate: "https://www.snapchat.com/add/{username}", expectedStatusCode: 200),
            Platform(name: "OnlyFans", urlTemplate: "https://onlyfans.com/{username}", expectedStatusCode: 200),
            Platform(name: "Patreon", urlTemplate: "https://www.patreon.com/{username}", expectedStatusCode: 200),
            Platform(name: "Ko-fi", urlTemplate: "https://ko-fi.com/{username}", expectedStatusCode: 200),
            Platform(name: "Tumblr", urlTemplate: "https://{username}.tumblr.com", expectedStatusCode: 200),
            
            // Professional & Business
            Platform(name: "Medium", urlTemplate: "https://medium.com/@{username}", expectedStatusCode: 200),
            Platform(name: "Substack", urlTemplate: "https://{username}.substack.com", expectedStatusCode: 200),
            Platform(name: "Crunchbase", urlTemplate: "https://www.crunchbase.com/person/{username}", expectedStatusCode: 200),
            Platform(name: "AngelList", urlTemplate: "https://angel.co/{username}", expectedStatusCode: 200),
            
            // Forums & Communities
            Platform(name: "Quora", urlTemplate: "https://www.quora.com/profile/{username}", expectedStatusCode: 200),
            Platform(name: "HackerNews", urlTemplate: "https://news.ycombinator.com/user?id={username}", expectedStatusCode: 200),
            Platform(name: "ProductHunt", urlTemplate: "https://www.producthunt.com/@{username}", expectedStatusCode: 200),
            Platform(name: "Mastodon", urlTemplate: "https://mastodon.social/@{username}", expectedStatusCode: 200),
            
            // Other Platforms
            Platform(name: "AboutMe", urlTemplate: "https://about.me/{username}", expectedStatusCode: 200),
            Platform(name: "Linktree", urlTemplate: "https://linktr.ee/{username}", expectedStatusCode: 200),
            Platform(name: "Cash App", urlTemplate: "https://cash.app/${username}", expectedStatusCode: 200),
            Platform(name: "Venmo", urlTemplate: "https://venmo.com/{username}", expectedStatusCode: 200),
            Platform(name: "Roblox", urlTemplate: "https://www.roblox.com/users/profile?username={username}", expectedStatusCode: 200)
        ]
    }
    
    func execute(on target: Target, context: OsintContext) async throws -> ModuleResult {
        var details: [String: Any] = [:]
        var platformResults: [String: [String: Any]] = [:]
        var foundCount = 0
        var riskScore: Double = 0.0
        
        let username = target.value.trimmingCharacters(in: .whitespaces)
        
        // Check each platform
        await withTaskGroup(of: (String, Bool, String)?.self) { group in
            for platform in Platform.platforms {
                group.addTask {
                    let url = platform.urlTemplate.replacingOccurrences(of: "{username}", with: username)
                    let exists = await checkUsernameExists(url: url)
                    return (platform.name, exists, url)
                }
            }
            
            for await result in group {
                if let (platformName, exists, url) = result {
                    platformResults[platformName] = [
                        "nalezeno": exists,
                        "url": url
                    ]
                    if exists {
                        foundCount += 1
                    }
                }
            }
        }
        
        details["platformy"] = platformResults
        details["nalezeno_celkem"] = foundCount
        details["zkontrolováno_platforem"] = Platform.platforms.count
        
        // Generate additional search queries
        let queries = generateSearchQueries(username)
        details["další_vyhledávání"] = queries
        
        // Calculate risk score based on how many platforms the username is found on
        riskScore = foundCount > 0 ? Double(foundCount) / Double(Platform.platforms.count) : 0.5
        
        return ModuleResult(
            moduleName: name,
            targetId: target.id,
            summary: "Username found on \(foundCount) of \(Platform.platforms.count) platforms",
            details: details,
            riskScore: riskScore,
            timestamp: Date()
        )
    }
    
    private func checkUsernameExists(url: String) async -> Bool {
        guard let targetURL = URL(string: url) else {
            return false
        }
        
        do {
            var request = URLRequest(url: targetURL)
            request.httpMethod = "HEAD"
            request.timeoutInterval = 10
            request.setValue("Atlas-OSINT/1.0", forHTTPHeaderField: "User-Agent")
            
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                // 200 = found, 404 = not found, other codes = uncertain
                return httpResponse.statusCode == 200
            }
            
            return false
        } catch {
            // If we can't check, assume not found
            return false
        }
    }
    
    private func generateSearchQueries(_ username: String) -> [String: String] {
        let encoded = username.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? username
        
        return [
            "Google": "https://www.google.com/search?q=\"\(encoded)\"",
            "Google (sociální sítě)": "https://www.google.com/search?q=site:facebook.com+OR+site:twitter.com+OR+site:instagram.com+\"\(encoded)\"",
            "Google (fóra)": "https://www.google.com/search?q=site:reddit.com+OR+site:*.forum.*+\"\(encoded)\"",
            "Namechk": "https://namechk.com/\(encoded)",
            "Sherlock Project": "Manual check recommended for comprehensive search"
        ]
    }
}
