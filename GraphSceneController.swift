//
//  GraphSceneController.swift
//  ROOtPaint_Engine
//
//  Created by M1N0-H1DDEN on 12.12.2025.
//


import UIKit
import SceneKit

@MainActor
final class GraphSceneController {
    let scene = SCNScene()

    private let cameraNode = SCNNode()
    private let keyLight = SCNNode()
    private let fillLight = SCNNode()
    private let ambientLight = SCNNode()
    private let groundNode = SCNNode()

    private var nodeNodes: [UUID: SCNNode] = [:]
    private var edgeNodes: [UUID: SCNNode] = [:]
    private var draftEdgeNode: SCNNode?

    var isInteractive: Bool = false

    init() {
        setupScene()
    }

    func resetCamera(animated: Bool = true) {
        let targetPos = SCNVector3(0, 2.0, 4.2)
        let targetLook = SCNVector3(0, 0, 0)

        if animated {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.35
            cameraNode.position = targetPos
            cameraNode.look(at: targetLook)
            SCNTransaction.commit()
        } else {
            cameraNode.position = targetPos
            cameraNode.look(at: targetLook)
        }
    }

    func sync(graph: RootGraph3D, selectedID: UUID?, draft: (from: UUID, toPoint: SCNVector3)?) {
        // Nodes
        var aliveNodeIDs = Set<UUID>()
        for n in graph.nodes {
            aliveNodeIDs.insert(n.id)
            if let existing = nodeNodes[n.id] {
                updateNodeSCN(existing, model: n, selectedID: selectedID)
            } else {
                let created = makeNodeSCN(model: n)
                nodeNodes[n.id] = created
                scene.rootNode.addChildNode(created)
                animateSpawn(created)
                updateNodeSCN(created, model: n, selectedID: selectedID)
            }
        }
        // remove deleted nodes
        for (id, nn) in nodeNodes where !aliveNodeIDs.contains(id) {
            nn.removeFromParentNode()
            nodeNodes.removeValue(forKey: id)
        }

        // Edges
        var aliveEdgeIDs = Set<UUID>()
        for e in graph.edges {
            aliveEdgeIDs.insert(e.id)

            guard let fromN = graph.nodes.first(where: { $0.id == e.fromNodeID }),
                  let toN   = graph.nodes.first(where: { $0.id == e.toNodeID }) else { continue }

            let fromPos = fromN.position.scn
            let toPos = toN.position.scn

            let fromR = fromN.radius
            let toR = toN.radius

            if let en = edgeNodes[e.id] {
                updateEdgeSCN(en, from: fromPos, fromRadius: fromR, to: toPos, toRadius: toR, animated: !isInteractive)
            } else {
                let created = makeEdgeSCN()
                created.name = "edge:\(e.id.uuidString)"
                edgeNodes[e.id] = created
                scene.rootNode.addChildNode(created)
                updateEdgeSCN(created, from: fromPos, fromRadius: fromR, to: toPos, toRadius: toR, animated: false)
                animateFadeIn(created)
            }
        }
        for (id, en) in edgeNodes where !aliveEdgeIDs.contains(id) {
            en.removeFromParentNode()
            edgeNodes.removeValue(forKey: id)
        }

        // Draft edge
        if let d = draft, let fromNode = graph.nodes.first(where: { $0.id == d.from }) {
            let fromPos = fromNode.position.scn
            let fromR = fromNode.radius
            if draftEdgeNode == nil {
                let de = makeEdgeSCN(isDraft: true)
                de.name = "edge:draft"
                draftEdgeNode = de
                scene.rootNode.addChildNode(de)
            }
            updateEdgeSCN(draftEdgeNode!, from: fromPos, fromRadius: fromR, to: d.toPoint, toRadius: 0.0, animated: false)
        } else {
            draftEdgeNode?.removeFromParentNode()
            draftEdgeNode = nil
        }
    }

    // MARK: - Hit helpers
    func nodeID(from hitNode: SCNNode) -> UUID? {
        var n: SCNNode? = hitNode
        while let cur = n {
            if let name = cur.name, name.hasPrefix("node:") {
                return UUID(uuidString: String(name.dropFirst(5)))
            }
            n = cur.parent
        }
        return nil
    }

    func connectorID(from hitNode: SCNNode) -> UUID? {
        var n: SCNNode? = hitNode
        while let cur = n {
            if let name = cur.name, name.hasPrefix("connector:") {
                return UUID(uuidString: String(name.dropFirst(10)))
            }
            n = cur.parent
        }
        return nil
    }

    // MARK: - World placement
    func makeWorldPointOnGround(from scnView: SCNView, screenPoint: CGPoint) -> SCNVector3? {
        let opts: [SCNHitTestOption: Any] = [
            .categoryBitMask: 1,     // ground
            .searchMode: SCNHitTestSearchMode.all.rawValue
        ]
        let hits = scnView.hitTest(screenPoint, options: opts)
        if let h = hits.first {
            let p = h.worldCoordinates
            return SCNVector3(p.x, 0, p.z)
        }
        return nil
    }

    // MARK: - Setup
    private func setupScene() {
        scene.background.contents = UIColor.systemBackground

        // Environment map pro “glass” odlesky (generované bez assetů)
        scene.lightingEnvironment.contents = makeGradientEnvironmentMap(size: 512)
        scene.lightingEnvironment.intensity = 1.35

        // Camera
        let cam = SCNCamera()
        cam.wantsHDR = true
        cam.bloomIntensity = 0.55
        cam.bloomThreshold = 0.65
        cam.exposureOffset = 0.15
        cam.fieldOfView = 58
        cameraNode.camera = cam
        scene.rootNode.addChildNode(cameraNode)
        resetCamera(animated: false)

        // Lights
        let dir = SCNLight()
        dir.type = .directional
        dir.intensity = 1100
        dir.temperature = 7000
        dir.castsShadow = true
        keyLight.light = dir
        keyLight.eulerAngles = SCNVector3(-0.9, 0.6, 0)
        scene.rootNode.addChildNode(keyLight)

        let fill = SCNLight()
        fill.type = .omni
        fill.intensity = 420
        fill.temperature = 8500
        fillLight.light = fill
        fillLight.position = SCNVector3(-2, 2.2, 1.2)
        scene.rootNode.addChildNode(fillLight)

        let amb = SCNLight()
        amb.type = .ambient
        amb.intensity = 220
        ambientLight.light = amb
        scene.rootNode.addChildNode(ambientLight)

        // Ground (hit-test rovina)
        let plane = SCNPlane(width: 60, height: 60)
        plane.firstMaterial?.diffuse.contents = UIColor.clear
        plane.firstMaterial?.isDoubleSided = true
        plane.firstMaterial?.transparency = 0.01 // skoro neviditelné, ale hit-test funguje
        groundNode.geometry = plane
        groundNode.eulerAngles.x = -.pi / 2
        groundNode.position = SCNVector3(0, 0, 0)
        groundNode.categoryBitMask = 1
        scene.rootNode.addChildNode(groundNode)

        // Jemná mřížka (vizuální orientace)
        scene.rootNode.addChildNode(makeGrid())
    }

    private func makeGrid() -> SCNNode {
        let grid = SCNNode()
        grid.position = SCNVector3(0, 0.001, 0)

        let lines = 18
        let spacing: Float = 0.6

        for i in -lines...lines {
            let z = Float(i) * spacing
            let line = makeLine(from: SCNVector3(-lines, 0, z), to: SCNVector3(lines, 0, z), thickness: 0.002)
            line.opacity = 0.15
            grid.addChildNode(line)
        }
        for i in -lines...lines {
            let x = Float(i) * spacing
            let line = makeLine(from: SCNVector3(x, 0, -lines), to: SCNVector3(x, 0, lines), thickness: 0.002)
            line.opacity = 0.15
            grid.addChildNode(line)
        }
        return grid
    }

    // MARK: - Nodes (glass + animace)
    private func makeNodeSCN(model: RootNode3D) -> SCNNode {
        let root = SCNNode()
        root.name = "node:\(model.id.uuidString)"
        root.position = model.position.scn

        // Glass sphere
        let sphere = SCNSphere(radius: CGFloat(model.radius))
        sphere.segmentCount = 64
        sphere.firstMaterial = makeGlassMaterial()

        let bubble = SCNNode(geometry: sphere)
        bubble.name = "nodeMesh:\(model.id.uuidString)"
        root.addChildNode(bubble)

        // Selection ring
        let ring = SCNTorus(ringRadius: CGFloat(model.radius * 1.18), pipeRadius: CGFloat(max(0.008, model.radius * 0.06)))
        let ringMat = SCNMaterial()
        ringMat.lightingModel = .physicallyBased
        ringMat.diffuse.contents = UIColor.white.withAlphaComponent(0.05)
        ringMat.emission.contents = UIColor.systemCyan.withAlphaComponent(0.55)
        ringMat.metalness.contents = 0.0
        ringMat.roughness.contents = 0.25
        ring.firstMaterial = ringMat

        let ringNode = SCNNode(geometry: ring)
        ringNode.name = "selectionRing"
        ringNode.opacity = 0.0
        ringNode.eulerAngles.x = .pi / 2
        root.addChildNode(ringNode)

        // Title (billboard)
        let text = SCNText(string: model.title, extrusionDepth: 0.02)
        text.font = UIFont.systemFont(ofSize: 0.22, weight: .semibold)
        text.flatness = 0.25

        let textMat = SCNMaterial()
        textMat.lightingModel = .physicallyBased
        textMat.diffuse.contents = UIColor.label
        textMat.emission.contents = UIColor.white.withAlphaComponent(0.15)
        textMat.isDoubleSided = true
        text.materials = [textMat]

        let textNode = SCNNode(geometry: text)
        textNode.name = "titleText"
        textNode.scale = SCNVector3(0.35, 0.35, 0.35)
        textNode.position = SCNVector3(-model.radius * 0.65, model.radius * 0.35, model.radius * 0.55)
        textNode.constraints = [SCNBillboardConstraint()] // vždy čitelné
        root.addChildNode(textNode)

        // Connector handle (jen při výběru)
        let handleSphere = SCNSphere(radius: 0.06)
        handleSphere.segmentCount = 36
        let hm = SCNMaterial()
        hm.lightingModel = .physicallyBased
        hm.diffuse.contents = UIColor.systemCyan
        hm.emission.contents = UIColor.systemCyan.withAlphaComponent(0.6)
        hm.roughness.contents = 0.25
        hm.metalness.contents = 0.0
        handleSphere.firstMaterial = hm

        let handle = SCNNode(geometry: handleSphere)
        handle.name = "connector:\(model.id.uuidString)"
        handle.position = SCNVector3(model.radius * 1.05, 0, 0)
        handle.opacity = 0.0
        root.addChildNode(handle)

        // “float” animace (jemné vlnění)
        let up = SCNAction.moveBy(x: 0, y: 0.03, z: 0, duration: 1.4)
        up.timingMode = .easeInEaseOut
        let down = SCNAction.moveBy(x: 0, y: -0.03, z: 0, duration: 1.4)
        down.timingMode = .easeInEaseOut
        root.runAction(.repeatForever(.sequence([up, down])))

        return root
    }

    private func updateNodeSCN(_ node: SCNNode, model: RootNode3D, selectedID: UUID?) {
        // position (animace při “ne-interactive” update)
        let targetPos = model.position.scn
        if isInteractive {
            node.position = targetPos
        } else {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.14
            SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            node.position = targetPos
            SCNTransaction.commit()
        }

        // update title
        if let textNode = node.childNode(withName: "titleText", recursively: false),
           let text = textNode.geometry as? SCNText {
            if (text.string as? String) != model.title {
                text.string = model.title
            }
        }

        // update radius (pokud změníš radius v modelu)
        if let mesh = node.childNode(withName: "nodeMesh:\(model.id.uuidString)", recursively: false),
           let sph = mesh.geometry as? SCNSphere {
            if abs(Float(sph.radius) - model.radius) > 0.0001 {
                sph.radius = CGFloat(model.radius)
            }
        }

        let isSelected = (selectedID == model.id)

        if let ring = node.childNode(withName: "selectionRing", recursively: false) {
            if isSelected {
                if ring.opacity < 0.99 {
                    SCNTransaction.begin()
                    SCNTransaction.animationDuration = 0.18
                    ring.opacity = 1.0
                    SCNTransaction.commit()

                    let pulseUp = SCNAction.scale(to: 1.05, duration: 0.35)
                    pulseUp.timingMode = .easeInEaseOut
                    let pulseDown = SCNAction.scale(to: 1.0, duration: 0.35)
                    pulseDown.timingMode = .easeInEaseOut
                    ring.runAction(.repeatForever(.sequence([pulseUp, pulseDown])), forKey: "pulse")
                }
            } else {
                ring.removeAction(forKey: "pulse")
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.18
                ring.opacity = 0.0
                SCNTransaction.commit()
            }
        }

        if let handle = node.childNode(withName: "connector:\(model.id.uuidString)", recursively: false) {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.18
            handle.opacity = isSelected ? 1.0 : 0.0
            SCNTransaction.commit()
        }
    }

    private func makeGlassMaterial() -> SCNMaterial {
        let m = SCNMaterial()
        m.lightingModel = .physicallyBased

        m.diffuse.contents = UIColor.white.withAlphaComponent(0.16)
        m.emission.contents = UIColor.systemCyan.withAlphaComponent(0.06)

        m.metalness.contents = 0.0
        m.roughness.contents = 0.05

        m.clearCoat.contents = 1.0
        m.clearCoatRoughness.contents = 0.02

        m.specular.contents = UIColor.white
        m.fresnelExponent = 2.2

        m.transparency = 0.38
        m.transparencyMode = .dualLayer
        m.blendMode = .alpha

        return m
    }

    // MARK: - Edges (3D arrow + animace)
    private func makeEdgeSCN(isDraft: Bool = false) -> SCNNode {
        let root = SCNNode()

        // cylinder (shaft)
        let cyl = SCNCylinder(radius: 0.012, height: 0.2)
        cyl.radialSegmentCount = 18
        let cm = SCNMaterial()
        cm.lightingModel = .physicallyBased
        cm.diffuse.contents = UIColor.secondaryLabel.withAlphaComponent(isDraft ? 0.45 : 0.85)
        cm.emission.contents = UIColor.systemTeal.withAlphaComponent(isDraft ? 0.12 : 0.20)
        cm.metalness.contents = 0.0
        cm.roughness.contents = 0.25
        cyl.firstMaterial = cm

        let shaft = SCNNode(geometry: cyl)
        shaft.name = "edgeShaft"
        root.addChildNode(shaft)

        // cone (head)
        let cone = SCNCone(topRadius: 0.001, bottomRadius: 0.03, height: 0.09)
        cone.radialSegmentCount = 22
        let hm = SCNMaterial()
        hm.lightingModel = .physicallyBased
        hm.diffuse.contents = UIColor.systemTeal.withAlphaComponent(isDraft ? 0.45 : 0.95)
        hm.emission.contents = UIColor.systemTeal.withAlphaComponent(isDraft ? 0.18 : 0.32)
        hm.roughness.contents = 0.22
        hm.metalness.contents = 0.0
        cone.firstMaterial = hm

        let head = SCNNode(geometry: cone)
        head.name = "edgeHead"
        root.addChildNode(head)

        root.opacity = isDraft ? 1.0 : 0.0
        return root
    }

    private func updateEdgeSCN(_ edgeRoot: SCNNode,
                               from: SCNVector3, fromRadius: Float,
                               to: SCNVector3, toRadius: Float,
                               animated: Bool) {
        let dir = (to - from)
        let dirN = dir.normalized
        let start = from + dirN * (fromRadius * 1.08)
        let end = to - dirN * (toRadius * 1.08)

        let v = end - start
        let totalLen = max(v.length, 0.06)

        let headLen: Float = 0.09
        let shaftLen = max(0.02, totalLen - headLen)

        // root at start, rotate Y-axis to direction
        let rot = SceneRot.rotationFromYAxis(to: v.normalized)

        if animated {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.12
            SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            edgeRoot.position = start
            edgeRoot.rotation = rot
            SCNTransaction.commit()
        } else {
            edgeRoot.position = start
            edgeRoot.rotation = rot
        }

        if let shaft = edgeRoot.childNode(withName: "edgeShaft", recursively: false),
           let cyl = shaft.geometry as? SCNCylinder {
            cyl.height = CGFloat(shaftLen)
            shaft.position = SCNVector3(0, shaftLen / 2, 0)
        }

        if let head = edgeRoot.childNode(withName: "edgeHead", recursively: false),
           let cone = head.geometry as? SCNCone {
            cone.height = CGFloat(headLen)
            head.position = SCNVector3(0, shaftLen + headLen / 2, 0)
        }
    }

    private func makeLine(from a: SCNVector3, to b: SCNVector3, thickness: CGFloat) -> SCNNode {
        let v = b - a
        let len = max(v.length, 0.0001)

        let cyl = SCNCylinder(radius: thickness, height: CGFloat(len))
        let m = SCNMaterial()
        m.lightingModel = .physicallyBased
        m.diffuse.contents = UIColor.secondaryLabel
        m.metalness.contents = 0.0
        m.roughness.contents = 0.9
        cyl.firstMaterial = m

        let node = SCNNode(geometry: cyl)
        node.position = a + (v * 0.5)
        node.rotation = SceneRot.rotationFromYAxis(to: v.normalized)
        return node
    }

    // MARK: - Animations
    private func animateSpawn(_ node: SCNNode) {
        node.scale = SCNVector3(0.001, 0.001, 0.001)
        let a = SCNAction.scale(to: 1.0, duration: 0.22)
        a.timingMode = .easeInEaseOut
        node.runAction(a)
    }

    private func animateFadeIn(_ node: SCNNode) {
        let a = SCNAction.fadeIn(duration: 0.18)
        a.timingMode = .easeInEaseOut
        node.runAction(a)
    }

    // MARK: - Environment map (procedurální)
    private func makeGradientEnvironmentMap(size: Int) -> UIImage {
        let r = CGSize(width: size, height: size)
        UIGraphicsBeginImageContextWithOptions(r, true, 1)
        defer { UIGraphicsEndImageContext() }

        let ctx = UIGraphicsGetCurrentContext()!
        let colors = [
            UIColor.systemTeal.withAlphaComponent(0.55).cgColor,
            UIColor.systemBlue.withAlphaComponent(0.30).cgColor,
            UIColor.systemBackground.cgColor
        ] as CFArray

        let space = CGColorSpaceCreateDeviceRGB()
        let grad = CGGradient(colorsSpace: space, colors: colors, locations: [0.0, 0.55, 1.0])!

        let center = CGPoint(x: r.width * 0.35, y: r.height * 0.25)
        ctx.drawRadialGradient(grad, startCenter: center, startRadius: 0,
                              endCenter: center, endRadius: r.width * 0.9,
                              options: [.drawsAfterEndLocation])

        return UIGraphicsGetImageFromCurrentImageContext()!
    }
}
