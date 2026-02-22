//
//  CameraRecognitionModule.swift
//  OSINT_GO
//
//  OSINT module for targets detected via the device camera:
//  faces, QR codes, barcodes, and OCR-extracted text.
//  All processing is local – no data leaves the device.
//


import Foundation
import SwiftUI

struct CameraRecognitionModule: OsintModule {
    let name = "Camera Recognition"
    let capabilities: [OsintCapability] = [.cameraRecognition, .faceDetection, .reverseImageSearch]
    let supportedTypes: [TargetType] = [.face, .url, .email, .phone, .personName, .username]

    let iconName = "camera.viewfinder"
    let color: Color = .purple
    let description = "OSINT zdroje pro cíle detekované kamerou (obličeje, QR kódy, text). Vše zpracováno lokálně."

    func execute(on target: Target, context: OsintContext) async throws -> ModuleResult {
        var details: [String: String] = [:]
        var riskScore: Double = 0.0

        let value = target.value.trimmingCharacters(in: .whitespaces)
        let targetType = TargetType(rawValue: target.type)

        switch targetType {
        case .face:
            details = faceRecognitionResources(for: value)
            riskScore = 0.7
        default:
            details = genericCameraResources(for: value)
            riskScore = 0.3
        }

        details["zdroj"] = "Detekováno kamerou zařízení"
        details["bezpečnostní_upozornění"] = """
        Tato funkce slouží výhradně pro osobní OSINT a sebebezpečnost uživatele.
        Rozpoznávání obličejů bez souhlasu osoby může být v rozporu se zákonem.
        Veškeré zpracování probíhá lokálně – žádná data nejsou odesílána na servery.
        """

        return ModuleResult(
            moduleName: name,
            targetId: target.id,
            summary: summaryFor(targetType: targetType, value: value),
            details: details,
            riskScore: riskScore,
            timestamp: Date()
        )
    }

    private func summaryFor(targetType: TargetType?, value: String) -> String {
        switch targetType {
        case .face:
            return "Obličej detekován – zdroje pro zpětné vyhledávání obrázků"
        default:
            return "Kamerou naskenovaný cíl: \(value)"
        }
    }

    // MARK: - Face OSINT resources

    private func faceRecognitionResources(for value: String) -> [String: String] {
        var details: [String: String] = [:]
        let encoded = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? value

        details["zpětné_vyhledávání_obličeje"] = """
        PimEyes: https://pimeyes.com/en
        FaceCheck.ID: https://facecheck.id/
        Google Lens: https://lens.google.com/
        Bing Visual Search: https://www.bing.com/visualsearch
        TinEye: https://tineye.com/
        Yandex Images: https://yandex.com/images/
        """

        details["open_source_nástroje"] = """
        DeepFace (Python): https://github.com/serengil/deepface
        face_recognition (Python): https://github.com/ageitgey/face_recognition
        InsightFace: https://github.com/deepinsight/insightface
        Facenet-PyTorch: https://github.com/timesler/facenet-pytorch
        OpenCV: https://opencv.org/
        """

        details["sociální_sítě_vyhledávání"] = """
        Facebook: https://www.facebook.com/search/
        LinkedIn: https://www.linkedin.com/search/
        Instagram: https://www.instagram.com/explore/
        Twitter/X: https://twitter.com/search
        VKontakte: https://vk.com/
        """

        if !value.isEmpty && value != "Detekovaný obličej" {
            details["vyhledávání_jména"] = """
            Google: https://www.google.com/search?q=\(encoded)
            Pipl: https://pipl.com/
            Spokeo: https://www.spokeo.com/search?q=\(encoded)
            """
        }

        return details
    }

    // MARK: - Generic camera target resources

    private func genericCameraResources(for value: String) -> [String: String] {
        var details: [String: String] = [:]
        let encoded = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? value

        details["extrahovaná_hodnota"] = value
        details["vyhledávání"] = """
        Google: https://www.google.com/search?q=\(encoded)
        Bing: https://www.bing.com/search?q=\(encoded)
        DuckDuckGo: https://duckduckgo.com/?q=\(encoded)
        """

        return details
    }
}
