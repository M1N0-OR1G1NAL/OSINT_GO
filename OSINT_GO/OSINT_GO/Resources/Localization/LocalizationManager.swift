//
//  LocalizationManager.swift
//  OSINT_GO
//
//  Created by M1N0-H1DDEN on 12.12.2025.
//


import SwiftUI

@Observable
class LocalizationManager {
    static let shared = LocalizationManager()
    
    var currentLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "appLanguage")
        }
    }
    
    private init() {
        let savedLang = UserDefaults.standard.string(forKey: "appLanguage") ?? AppLanguage.english.rawValue
        self.currentLanguage = AppLanguage(rawValue: savedLang) ?? .english
    }
    
    func localizedString(_ key: String) -> String {
        // In a full implementation, this would load from Localizable.strings
        // For now, we'll use a dictionary-based approach
        return LocalizedStrings.getString(key, language: currentLanguage)
    }
}

// Localized strings dictionary
struct LocalizedStrings {
    static func getString(_ key: String, language: AppLanguage) -> String {
        let strings = getStrings(for: language)
        return strings[key] ?? key
    }
    
    private static func getStrings(for language: AppLanguage) -> [String: String] {
        switch language {
        case .czech:
            return czechStrings
        case .english:
            return englishStrings
        case .slovak:
            return slovakStrings
        case .russian:
            return russianStrings
        case .german:
            return germanStrings
        }
    }
    
    // MARK: - English
    private static let englishStrings: [String: String] = [
        "investigations": "Investigations",
        "modules": "Modules",
        "device": "Device",
        "settings": "Settings",
        "no_investigations": "No Investigations",
        "create_first_case": "Create your first OSINT case and start linking domains, IPs, emails and more.",
        "targets": "Targets",
        "timeline": "Timeline",
        "graph": "Graph",
        "results": "Results",
        "notes": "Notes",
        "device_security": "Device Security",
        "security_checks": "Security Checks",
        "recommendations": "Recommendations",
        "quick_actions": "Quick Actions",
        "language_appearance": "Language & Appearance",
        "language": "Language",
        "appearance": "Appearance",
        "ai_configuration": "AI Configuration",
        "subscription": "Subscription",
        "manage_subscription": "Manage Subscription",
        "legal_info": "Legal & Info",
        "privacy_policy": "Privacy Policy",
        "terms_of_service": "Terms of Service",
        "app_info": "App Info"
    ]
    
    // MARK: - Czech
    private static let czechStrings: [String: String] = [
        "investigations": "Vyšetřování",
        "modules": "Moduly",
        "device": "Zařízení",
        "settings": "Nastavení",
        "no_investigations": "Žádná vyšetřování",
        "create_first_case": "Vytvořte svůj první případ OSINT a začněte propojovat domény, IP adresy, e-maily a další.",
        "targets": "Cíle",
        "timeline": "Časová osa",
        "graph": "Graf",
        "results": "Výsledky",
        "notes": "Poznámky",
        "device_security": "Zabezpečení zařízení",
        "security_checks": "Bezpečnostní kontroly",
        "recommendations": "Doporučení",
        "quick_actions": "Rychlé akce",
        "language_appearance": "Jazyk a vzhled",
        "language": "Jazyk",
        "appearance": "Vzhled",
        "ai_configuration": "Konfigurace AI",
        "subscription": "Předplatné",
        "manage_subscription": "Spravovat předplatné",
        "legal_info": "Právní informace",
        "privacy_policy": "Zásady ochrany osobních údajů",
        "terms_of_service": "Podmínky služby",
        "app_info": "Informace o aplikaci"
    ]
    
    // MARK: - Slovak
    private static let slovakStrings: [String: String] = [
        "investigations": "Vyšetrovania",
        "modules": "Moduly",
        "device": "Zariadenie",
        "settings": "Nastavenia",
        "no_investigations": "Žiadne vyšetrovania",
        "create_first_case": "Vytvorte svoj prvý prípad OSINT a začnite prepájať domény, IP adresy, e-maily a ďalšie.",
        "targets": "Ciele",
        "timeline": "Časová os",
        "graph": "Graf",
        "results": "Výsledky",
        "notes": "Poznámky",
        "device_security": "Zabezpečenie zariadenia",
        "security_checks": "Bezpečnostné kontroly",
        "recommendations": "Odporúčania",
        "quick_actions": "Rýchle akcie",
        "language_appearance": "Jazyk a vzhľad",
        "language": "Jazyk",
        "appearance": "Vzhľad",
        "ai_configuration": "Konfigurácia AI",
        "subscription": "Predplatné",
        "manage_subscription": "Spravovať predplatné",
        "legal_info": "Právne informácie",
        "privacy_policy": "Zásady ochrany osobných údajov",
        "terms_of_service": "Podmienky služby",
        "app_info": "Informácie o aplikácii"
    ]
    
    // MARK: - Russian
    private static let russianStrings: [String: String] = [
        "investigations": "Расследования",
        "modules": "Модули",
        "device": "Устройство",
        "settings": "Настройки",
        "no_investigations": "Нет расследований",
        "create_first_case": "Создайте свой первый случай OSINT и начните связывать домены, IP-адреса, электронные письма и многое другое.",
        "targets": "Цели",
        "timeline": "Хронология",
        "graph": "График",
        "results": "Результаты",
        "notes": "Заметки",
        "device_security": "Безопасность устройства",
        "security_checks": "Проверки безопасности",
        "recommendations": "Рекомендации",
        "quick_actions": "Быстрые действия",
        "language_appearance": "Язык и внешний вид",
        "language": "Язык",
        "appearance": "Внешний вид",
        "ai_configuration": "Конфигурация ИИ",
        "subscription": "Подписка",
        "manage_subscription": "Управление подпиской",
        "legal_info": "Юридическая информация",
        "privacy_policy": "Политика конфиденциальности",
        "terms_of_service": "Условия обслуживания",
        "app_info": "Информация о приложении"
    ]
    
    // MARK: - German
    private static let germanStrings: [String: String] = [
        "investigations": "Untersuchungen",
        "modules": "Module",
        "device": "Gerät",
        "settings": "Einstellungen",
        "no_investigations": "Keine Untersuchungen",
        "create_first_case": "Erstellen Sie Ihren ersten OSINT-Fall und beginnen Sie, Domains, IP-Adressen, E-Mails und mehr zu verknüpfen.",
        "targets": "Ziele",
        "timeline": "Zeitleiste",
        "graph": "Diagramm",
        "results": "Ergebnisse",
        "notes": "Notizen",
        "device_security": "Gerätesicherheit",
        "security_checks": "Sicherheitsprüfungen",
        "recommendations": "Empfehlungen",
        "quick_actions": "Schnellaktionen",
        "language_appearance": "Sprache & Erscheinungsbild",
        "language": "Sprache",
        "appearance": "Erscheinungsbild",
        "ai_configuration": "KI-Konfiguration",
        "subscription": "Abonnement",
        "manage_subscription": "Abonnement verwalten",
        "legal_info": "Rechtliche Informationen",
        "privacy_policy": "Datenschutzrichtlinie",
        "terms_of_service": "Nutzungsbedingungen",
        "app_info": "App-Info"
    ]
}

// Extension for easy access
extension String {
    var localized: String {
        LocalizationManager.shared.localizedString(self)
    }
}
