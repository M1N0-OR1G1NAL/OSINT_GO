//
//  OsintModule+Extensions.swift
//  OSINT_GO
//
//  Created by M1N0-H1DDEN on 08.12.2025.
//


import Foundation

extension OsintModule {
    static var allModules: [OsintModule] {
        return [
            // Existing modules
            DomainIpModule(),
            DNSModule(),
            WhoisModule(),
            EmailModule(),
            UsernameModule(),
            PhoneModule(),
            CompanyModule(),
            PersonModule(),
            SocialMediaModule(),
            
            // New OSINT Framework modules
            BreachModule(),
            SubdomainModule(),
            MetadataModule(),
            CertificateModule(),
            RepositoryModule(),
            GeolocationModule(),
            SocialAnalyticsModule(),
            DarkWebModule(),
            CameraRecognitionModule()
        ]
    }
}
