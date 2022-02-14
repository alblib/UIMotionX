//
//  Math.swift
//  
//
//  Created by Albertus Liberius on 2022/02/14.
//

import Foundation
import CoreMotion

public extension CMRotationMatrix{
    var determinant: Double{
        m11 * (m22 * m33 - m23 * m32)
        + m12 * (m23 * m31 - m21 * m33)
        + m13 * (m21 * m32 - m22 * m31)
    }
    var inverseMatrix: CMRotationMatrix{
        let det = determinant
        return CMRotationMatrix(
            m11: (m22 * m33 - m23 * m32) / det,
            m12: (m13 * m32 - m12 * m33) / det,
            m13: (m12 * m23 - m13 * m22) / det,
            m21: (m23 * m31 - m21 * m33) / det,
            m22: (m11 * m33 - m13 * m31) / det,
            m23: (m13 * m21 - m11 * m23) / det,
            m31: (m21 * m32 - m22 * m31) / det,
            m32: (m12 * m31 - m11 * m32) / det,
            m33: (m11 * m22 - m12 * m21) / det)
    }
    
}
