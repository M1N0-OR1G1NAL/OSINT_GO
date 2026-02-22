//
//  TargetType.swift
//  OSINT_GO
//
//  Created by M1N0-H1DDEN on 08.12.2025.
//


import Foundation

enum TargetType: String, CaseIterable, Identifiable, Codable {
    case domain = "Doména"
    case ipAddress = "IP adresa"
    case username = "Uživatelské jméno"
    case email = "E-mail"
    case phone = "Telefonní číslo"
    case ico = "IČO"
    case address = "Adresa"
    case uvid = "UVID / jiné ID"
    case company = "Firma"
    case personName = "Jméno a příjmení"
    case url = "URL"
    case document = "Dokument"
    case device = "Zařízení"
    case face = "Obličej (kamera)"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .domain: return "globe"
        case .ipAddress: return "network"
        case .username: return "person"
        case .email: return "envelope"
        case .phone: return "phone"
        case .ico, .company: return "building.2"
        case .address: return "location"
        case .uvid: return "number"
        case .personName: return "person.circle"
        case .url: return "link"
        case .document: return "doc"
        case .device: return "iphone"
        case .face: return "face.dashed"
        }
    }
}
