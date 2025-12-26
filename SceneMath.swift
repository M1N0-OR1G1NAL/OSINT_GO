//
//  SceneMath.swift
//  ROOtPaint_Engine
//
//  Created by M1N0-H1DDEN on 12.12.2025.
//

import SceneKit

extension SCNVector3 {
    static let zero = SCNVector3(0, 0, 0)

    static func + (l: SCNVector3, r: SCNVector3) -> SCNVector3 { .init(l.x + r.x, l.y + r.y, l.z + r.z) }
    static func - (l: SCNVector3, r: SCNVector3) -> SCNVector3 { .init(l.x - r.x, l.y - r.y, l.z - r.z) }
    static func * (v: SCNVector3, s: Float) -> SCNVector3 { .init(v.x * s, v.y * s, v.z * s) }

    var length: Float { sqrt(x*x + y*y + z*z) }
    var lengthXZ: Float { sqrt(x*x + z*z) }

    var normalized: SCNVector3 {
        let len = max(length, 0.00001)
        return self * (1.0 / len)
    }

    var normalizedXZ: SCNVector3 {
        let len = max(lengthXZ, 0.00001)
        return SCNVector3(x / len, 0, z / len)
    }

    static func dot(_ a: SCNVector3, _ b: SCNVector3) -> Float {
        a.x*b.x + a.y*b.y + a.z*b.z
    }

    static func cross(_ a: SCNVector3, _ b: SCNVector3) -> SCNVector3 {
        SCNVector3(
            a.y*b.z - a.z*b.y,
            a.z*b.x - a.x*b.z,
            a.x*b.y - a.y*b.x
        )
    }
}

enum SceneRot {
        /// Rotace, která mapuje +Y osu na směr `dir` (dir musí být normalizovaný).
    static func rotationFromYAxis(to dir: SCNVector3) -> SCNVector4 {
        let yAxis = SCNVector3(0, 1, 0)
        let d = dir.normalized

        let dot = max(-1.0 as Float, min(1.0 as Float, SCNVector3.dot(yAxis, d)))
        let angle = acos(dot)

            // pokud je vektor skoro stejný/opak
        let axis = SCNVector3.cross(yAxis, d)
        if axis.length < 0.0001 {
                // 0 nebo 180 stupňů kolem X osy (stačí)
            return SCNVector4(1, 0, 0, angle)
        }

        let n = axis.normalized
        return SCNVector4(n.x, n.y, n.z, angle)
    }
}
