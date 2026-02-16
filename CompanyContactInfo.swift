// Path: AtlasOSINT/Core/Domain/CompanyContactInfo.swift

import Foundation

struct CompanyContactInfo: Codable, Hashable {
    let ico: String?               // IČO
    let dic: String?               // DIČ (volitelné)
    let registrationCountry: String?
    let registrationAuthority: String?    // např. "Městský soud v Praze"

    let officialName: String?
    let website: String?
    let email: String?
    let phone: String?

    let addressLine1: String?
    let addressLine2: String?
    let city: String?
    let postalCode: String?
    let country: String?

    let socials: [SocialProfile]

    init(
        ico: String? = nil,
        dic: String? = nil,
        registrationCountry: String? = nil,
        registrationAuthority: String? = nil,
        officialName: String? = nil,
        website: String? = nil,
        email: String? = nil,
        phone: String? = nil,
        addressLine1: String? = nil,
        addressLine2: String? = nil,
        city: String? = nil,
        postalCode: String? = nil,
        country: String? = nil,
        socials: [SocialProfile] = []
    ) {
        self.ico = ico
        self.dic = dic
        self.registrationCountry = registrationCountry
        self.registrationAuthority = registrationAuthority
        self.officialName = officialName
        self.website = website
        self.email = email
        self.phone = phone
        self.addressLine1 = addressLine1
        self.addressLine2 = addressLine2
        self.city = city
        self.postalCode = postalCode
        self.country = country
        self.socials = socials
    }
}