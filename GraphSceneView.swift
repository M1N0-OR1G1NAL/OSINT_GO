//
//  GraphSceneView.swift
//  ROOtPaint_Engine
//
//  Created by M1N0-H1DDEN on 12.12.2025.
//


import SwiftUI
import SceneKit

struct GraphSceneView: UIViewRepresentable {
    @ObservedObject var vm: GraphViewModel
    let controller: GraphSceneController

    func makeUIView(context: Context) -> SCNView {
        let v = SCNView()
        v.scene = controller.scene
        v.preferredFramesPerSecond = 60
        v.rendersContinuously = true
        v.antialiasingMode = .multisampling4X
        v.backgroundColor = .clear

        // Kamera ovládání (orbit/zoom) – vypínáme při interakci s uzlem/hranou
        v.allowsCameraControl = true

        // Gestures
        context.coordinator.installGestures(on: v)

        return v
    }

    func updateUIView(_ scnView: SCNView, context: Context) {
        // umožni camera control jen když zrovna netaháš uzel/šipku
        scnView.allowsCameraControl = !context.coordinator.isEditing

        let draft: (from: UUID, toPoint: SCNVector3)?
        if let d = vm.draftEdge {
            draft = (d.fromID, d.currentWorldPoint)
        } else {
            draft = nil
        }

        controller.isInteractive = context.coordinator.isEditing
        controller.sync(graph: vm.graph, selectedID: vm.selectedNodeID, draft: draft)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(vm: vm, controller: controller)
    }

    @MainActor
    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        let vm: GraphViewModel
        let controller: GraphSceneController

        weak var scnView: SCNView?
        var isEditing: Bool = false

        private var movingNodeID: UUID?
        private var edgeFromID: UUID?

        init(vm: GraphViewModel, controller: GraphSceneController) {
            self.vm = vm
            self.controller = controller
        }

        func installGestures(on view: SCNView) {
            self.scnView = view

            // Single tap select
            let tap = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
            tap.numberOfTapsRequired = 1

            // Double tap add node
            let doubleTap = UITapGestureRecognizer(target: self, action: #selector(onDoubleTap(_:)))
            doubleTap.numberOfTapsRequired = 2
            tap.require(toFail: doubleTap)

            // Long press move node
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress(_:)))
            longPress.minimumPressDuration = 0.22

            // Pan for edge drafting (drag from connector)
            let pan = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
            pan.maximumNumberOfTouches = 1

            [tap, doubleTap, longPress, pan].forEach {
                $0.delegate = self
                view.addGestureRecognizer($0)
            }
        }

        // MARK: - Gesture delegate
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            // dovol simultánně s camera control; editing flag to stejně vypne camera control v update
            return true
        }

        // MARK: - Actions
        @objc private func onTap(_ gr: UITapGestureRecognizer) {
            guard let v = scnView else { return }
            let p = gr.location(in: v)

            let hits = v.hitTest(p, options: nil)
            if let h = hits.first {
                if let id = controller.nodeID(from: h.node) {
                    vm.selectedNodeID = id
                    return
                }
            }

            vm.selectedNodeID = nil
        }

        @objc private func onDoubleTap(_ gr: UITapGestureRecognizer) {
            guard let v = scnView else { return }
            let p = gr.location(in: v)

            // pokud double tap na node -> jen vyber
            let hits = v.hitTest(p, options: nil)
            if let h = hits.first, let id = controller.nodeID(from: h.node) {
                vm.selectedNodeID = id
                return
            }

            // jinak vytvoř node na ground
            if let wp = controller.makeWorldPointOnGround(from: v, screenPoint: p) {
                vm.addNode(at: wp)
            } else {
                // fallback: před kameru
                let cam = v.pointOfView?.presentation.worldPosition ?? SCNVector3(0, 2, 4)
                vm.addNode(at: SCNVector3(cam.x, 0, cam.z - 1))
            }
        }

        @objc private func onLongPress(_ gr: UILongPressGestureRecognizer) {
            guard let v = scnView else { return }
            let p = gr.location(in: v)

            switch gr.state {
            case .began:
                let hits = v.hitTest(p, options: nil)
                if let h = hits.first, let id = controller.nodeID(from: h.node) {
                    movingNodeID = id
                    vm.selectedNodeID = id
                    isEditing = true
                }
            case .changed:
                guard let id = movingNodeID else { return }
                if let wp = controller.makeWorldPointOnGround(from: v, screenPoint: p) {
                    vm.moveNode(id, to: wp)
                }
            default:
                movingNodeID = nil
                isEditing = false
            }
        }

        @objc private func onPan(_ gr: UIPanGestureRecognizer) {
            guard let v = scnView else { return }
            let p = gr.location(in: v)

            switch gr.state {
            case .began:
                let hits = v.hitTest(p, options: nil)
                if let h = hits.first, let fromID = controller.connectorID(from: h.node) {
                    edgeFromID = fromID
                    vm.selectedNodeID = fromID
                    isEditing = true

                    let wp = controller.makeWorldPointOnGround(from: v, screenPoint: p) ?? SCNVector3Zero
                    vm.draftEdge = .init(fromID: fromID, currentWorldPoint: wp)
                }
            case .changed:
                guard let fromID = edgeFromID else { return }
                let wp = controller.makeWorldPointOnGround(from: v, screenPoint: p) ?? SCNVector3Zero
                vm.draftEdge = .init(fromID: fromID, currentWorldPoint: wp)
            default:
                guard let fromID = edgeFromID else {
                    isEditing = false
                    vm.draftEdge = nil
                    return
                }

                // drop -> pokud spadne na node, vytvoř edge
                let hits = v.hitTest(p, options: nil)
                if let h = hits.first, let toID = controller.nodeID(from: h.node), toID != fromID {
                    vm.addEdge(from: fromID, to: toID)
                }

                edgeFromID = nil
                vm.draftEdge = nil
                isEditing = false
            }
        }
    }
}
