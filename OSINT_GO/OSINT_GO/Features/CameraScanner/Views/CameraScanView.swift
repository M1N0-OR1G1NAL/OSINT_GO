//
//  CameraScanView.swift
//  OSINT_GO
//
//  Live-camera target recognition for iOS / iPadOS / visionOS.
//  Supports QR & barcode scanning, OCR text extraction, and
//  face detection – all processed locally on the device.
//
//  Frameworks used:
//    • VisionKit  – DataScannerViewController (QR / barcode / text, iOS 16+)
//    • Vision     – VNDetectFaceRectanglesRequest (face bounding boxes)
//    • AVFoundation – camera session for face mode
//


import SwiftUI
import AVFoundation
import Vision
import VisionKit

// MARK: - Scan mode

enum CameraScanMode: String, CaseIterable {
    case qrBarcode = "QR / Čárový kód"
    case text      = "Text / OCR"
    case face      = "Obličej"

    var iconName: String {
        switch self {
        case .qrBarcode: return "qrcode.viewfinder"
        case .text:      return "text.viewfinder"
        case .face:      return "face.dashed"
        }
    }
}

// MARK: - Result model

struct CameraScanResult {
    let type: TargetType
    let value: String
    let label: String
}

// MARK: - Main view

struct CameraScanView: View {
    @Environment(\.dismiss) private var dismiss
    var onResult: (CameraScanResult) -> Void

    @State private var scanMode: CameraScanMode = .qrBarcode
    @State private var detectedValue: String = ""
    @State private var showConfirmation = false
    @State private var pendingResult: CameraScanResult?
    @State private var cameraPermissionDenied = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Mode picker
                Picker("Režim skenování", selection: $scanMode) {
                    ForEach(CameraScanMode.allCases, id: \.self) { mode in
                        Label(mode.rawValue, systemImage: mode.iconName).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                .onChange(of: scanMode) { _, _ in
                    detectedValue = ""
                    pendingResult = nil
                }

                // Camera content
                ZStack(alignment: .bottom) {
                    cameraContent

                    if !detectedValue.isEmpty {
                        detectedBanner
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle("Skenovat kamerou")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Zrušit") { dismiss() }
                }
            }
            // Confirm adding detected item as a target
            .alert("Přidat jako cíl?", isPresented: $showConfirmation, presenting: pendingResult) { result in
                Button("Přidat") {
                    onResult(result)
                    dismiss()
                }
                Button("Skenovat znovu", role: .cancel) {
                    detectedValue = ""
                    pendingResult = nil
                }
            } message: { result in
                Text("Detekováno: \(result.value)\nTyp: \(result.type.rawValue)")
            }
            // Camera permission denied
            .alert("Přístup ke kameře odepřen", isPresented: $cameraPermissionDenied) {
                Button("Nastavení") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Zrušit", role: .cancel) { dismiss() }
            } message: {
                Text("Pro skenování je potřeba povolit přístup ke kameře v Nastavení.")
            }
        }
    }

    // MARK: - Sub-views

    @ViewBuilder
    private var cameraContent: some View {
        if cameraPermissionDenied {
            ContentUnavailableView(
                "Kamera nedostupná",
                systemImage: "camera.fill.badge.ellipsis",
                description: Text("Povolte přístup ke kameře v Nastavení → OSINT GO.")
            )
        } else if scanMode == .face {
            FaceCameraView(
                onFaceDetected: handleFaceDetection,
                onPermissionDenied: { cameraPermissionDenied = true }
            )
        } else {
            if #available(iOS 16.0, *) {
                QRTextScannerView(
                    mode: scanMode,
                    onDetected: handleDetection,
                    onPermissionDenied: { cameraPermissionDenied = true }
                )
            } else {
                ContentUnavailableView(
                    "Vyžaduje iOS 16",
                    systemImage: "exclamationmark.triangle",
                    description: Text("QR a text skenování vyžaduje iOS 16 nebo novější.")
                )
            }
        }
    }

    private var detectedBanner: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Detekováno:")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(detectedValue)
                .font(.headline)
                .lineLimit(2)
            Button("Přidat jako cíl") {
                showConfirmation = true
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .padding()
    }

    // MARK: - Detection handlers

    private func handleDetection(value: String) {
        guard !value.isEmpty, detectedValue.isEmpty else { return }
        detectedValue = value
        let type = inferTargetType(from: value)
        pendingResult = CameraScanResult(
            type: type,
            value: value,
            label: "Kamera – \(scanMode.rawValue)"
        )
        showConfirmation = true
    }

    private func handleFaceDetection() {
        guard detectedValue.isEmpty else { return }
        let timestamp = Date().formatted(.dateTime.hour().minute())
        detectedValue = "Detekovaný obličej"
        pendingResult = CameraScanResult(
            type: .face,
            value: "Detekovaný obličej",
            label: "Kamera – Obličej (\(timestamp))"
        )
        showConfirmation = true
    }

    private func inferTargetType(from value: String) -> TargetType {
        if value.hasPrefix("http://") || value.hasPrefix("https://") { return .url }
        if value.contains("@") && value.contains(".") { return .email }
        let phonePattern = "^[+]?[0-9][\\s\\-\\.0-9]{6,18}$"
        if let regex = try? NSRegularExpression(pattern: phonePattern),
           regex.firstMatch(in: value, range: NSRange(value.startIndex..., in: value)) != nil {
            return .phone
        }
        return scanMode == .text ? .personName : .url
    }
}

// MARK: - QR / Barcode / Text scanner (VisionKit, iOS 16+)

@available(iOS 16.0, *)
private struct QRTextScannerView: UIViewControllerRepresentable {
    let mode: CameraScanMode
    let onDetected: (String) -> Void
    let onPermissionDenied: () -> Void

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let dataTypes: Set<DataScannerViewController.RecognizedDataType>
        switch mode {
        case .qrBarcode:
            dataTypes = [.barcode(symbologies: [.qr, .code128, .ean13, .ean8, .pdf417, .dataMatrix, .aztec])]
        case .text:
            dataTypes = [.text()]
        default:
            dataTypes = [.barcode(symbologies: [.qr])]
        }
        let scanner = DataScannerViewController(
            recognizedDataTypes: dataTypes,
            qualityLevel: .accurate,
            recognizesMultipleItems: false,
            isHighFrameRateTrackingEnabled: false,
            isPinchToZoomEnabled: true,
            isGuidanceEnabled: true,
            isHighlightingEnabled: true
        )
        scanner.delegate = context.coordinator
        return scanner
    }

    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        try? uiViewController.startScanning()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onDetected: onDetected, onPermissionDenied: onPermissionDenied)
    }

    final class Coordinator: NSObject, DataScannerViewControllerDelegate {
        let onDetected: (String) -> Void
        let onPermissionDenied: () -> Void
        private var hasDetected = false

        init(onDetected: @escaping (String) -> Void, onPermissionDenied: @escaping () -> Void) {
            self.onDetected = onDetected
            self.onPermissionDenied = onPermissionDenied
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            guard !hasDetected else { return }
            hasDetected = true
            let value: String
            switch item {
            case .barcode(let barcode): value = barcode.payloadStringValue ?? ""
            case .text(let text):       value = text.transcript
            @unknown default:           value = ""
            }
            DispatchQueue.main.async { self.onDetected(value) }
        }
    }
}

// MARK: - Face detection camera (Vision + AVFoundation)

private struct FaceCameraView: UIViewControllerRepresentable {
    let onFaceDetected: () -> Void
    let onPermissionDenied: () -> Void

    func makeUIViewController(context: Context) -> FaceCameraViewController {
        let vc = FaceCameraViewController()
        vc.onFaceDetected = onFaceDetected
        vc.onPermissionDenied = onPermissionDenied
        return vc
    }

    func updateUIViewController(_ uiViewController: FaceCameraViewController, context: Context) {}
    func makeCoordinator() {}
}

private final class FaceCameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    var onFaceDetected: (() -> Void)?
    var onPermissionDenied: (() -> Void)?

    private let captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private let videoOutput = AVCaptureVideoDataOutput()
    private let overlayLayer = CAShapeLayer()
    private let captureButton = UIButton(type: .system)
    private var hasDetected = false

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupOverlay()
        setupCaptureButton()
        checkCameraPermission()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession.stopRunning()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
        overlayLayer.frame = view.bounds
    }

    // MARK: Camera permission

    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            configureCaptureSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted { self?.configureCaptureSession() }
                    else { self?.onPermissionDenied?() }
                }
            }
        default:
            DispatchQueue.main.async { [weak self] in self?.onPermissionDenied?() }
        }
    }

    // MARK: Session configuration

    private func configureCaptureSession() {
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .high

        // Prefer front camera for face recognition
        let position: AVCaptureDevice.Position = .front
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position)
                        ?? AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device),
              captureSession.canAddInput(input) else {
            captureSession.commitConfiguration()
            return
        }

        captureSession.addInput(input)

        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "com.osintgo.camera.face", qos: .userInitiated))
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }

        captureSession.commitConfiguration()

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let preview = AVCaptureVideoPreviewLayer(session: self.captureSession)
            preview.videoGravity = .resizeAspectFill
            preview.frame = self.view.bounds
            self.view.layer.insertSublayer(preview, at: 0)
            self.previewLayer = preview
            self.view.layer.addSublayer(self.overlayLayer)
        }
    }

    // MARK: UI setup

    private func setupOverlay() {
        overlayLayer.fillColor = UIColor.clear.cgColor
        overlayLayer.strokeColor = UIColor.systemGreen.cgColor
        overlayLayer.lineWidth = 3
    }

    private func setupCaptureButton() {
        // Guide label
        let guideLabel = UILabel()
        guideLabel.text = "Namiřte kameru na obličej"
        guideLabel.textColor = .white
        guideLabel.textAlignment = .center
        guideLabel.font = .systemFont(ofSize: 15, weight: .medium)
        guideLabel.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        guideLabel.layer.cornerRadius = 8
        guideLabel.clipsToBounds = true
        guideLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(guideLabel)

        // Capture button
        captureButton.setTitle("Zachytit obličej", for: .normal)
        captureButton.backgroundColor = UIColor.systemBlue
        captureButton.setTitleColor(.white, for: .normal)
        captureButton.layer.cornerRadius = 24
        captureButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        captureButton.isEnabled = false
        captureButton.alpha = 0.5
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        captureButton.addTarget(self, action: #selector(captureButtonTapped), for: .touchUpInside)
        view.addSubview(captureButton)

        NSLayoutConstraint.activate([
            guideLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            guideLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            guideLabel.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, constant: -32),
            guideLabel.heightAnchor.constraint(equalToConstant: 40),

            captureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.widthAnchor.constraint(equalToConstant: 200),
            captureButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    @objc private func captureButtonTapped() {
        guard !hasDetected else { return }
        hasDetected = true
        DispatchQueue.main.async { [weak self] in self?.onFaceDetected?() }
    }

    // MARK: Vision face detection

    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let request = VNDetectFaceRectanglesRequest { [weak self] req, _ in
            let faces = req.results as? [VNFaceObservation] ?? []
            self?.updateFaceOverlay(faces)
        }

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .leftMirrored, options: [:])
        try? handler.perform([request])
    }

    private func updateFaceOverlay(_ observations: [VNFaceObservation]) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let path = UIBezierPath()
            for obs in observations {
                path.append(UIBezierPath(roundedRect: self.convertBoundingBox(obs.boundingBox), cornerRadius: 8))
            }
            self.overlayLayer.path = path.cgPath

            let detected = !observations.isEmpty
            self.captureButton.isEnabled = detected
            self.captureButton.alpha = detected ? 1.0 : 0.5
        }
    }

    /// Convert Vision's normalized, bottom-left-origin rect to UIKit coordinates.
    private func convertBoundingBox(_ box: CGRect) -> CGRect {
        let w = view.bounds.width
        let h = view.bounds.height
        return CGRect(
            x: box.minX * w,
            y: (1 - box.maxY) * h,
            width: box.width * w,
            height: box.height * h
        )
    }
}
