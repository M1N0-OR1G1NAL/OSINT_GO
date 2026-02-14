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
            DomainIpModule(),
            DNSModule(),
            WhoisModule(),
            EmailModule(),
            UsernameModule(),
            PhoneModule(),
            CompanyModule(),
            PersonModule(),
            SocialMediaModule(),
            AddressModule(),
            OpenDatabasesModule()
        ]
    }
}
