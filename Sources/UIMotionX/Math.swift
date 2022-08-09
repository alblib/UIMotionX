//
//  Math.swift
//  
//
//  Created by Albertus Liberius on 2022/02/14.
//

import Foundation
import CoreMotion
import simd

public extension CMRotationMatrix{
    init(_ simdMatrix: simd_double3x3){
        let cols = simdMatrix.columns
        self.init(
            m11: cols.0.x, m12: cols.1.x, m13: cols.2.x,
            m21: cols.0.y, m22: cols.1.y, m23: cols.2.y,
            m31: cols.0.z, m32: cols.1.z, m33: cols.2.z)
    }
    var simd_rows: (simd_double3, simd_double3, simd_double3){
        (
            simd_make_double3(m11, m12, m13),
            simd_make_double3(m21, m22, m23),
            simd_make_double3(m31, m32, m33)
        )
    }
    var simd_columns: (simd_double3, simd_double3, simd_double3){
        (
            simd_make_double3(m11, m21, m31),
            simd_make_double3(m12, m22, m32),
            simd_make_double3(m13, m23, m33)
        )
    }
    var simd_matrix: simd_double3x3{
        .init(columns: simd_columns)
    }
    var determinant: Double{
        /*
        m11 * (m22 * m33 - m23 * m32)
        + m12 * (m23 * m31 - m21 * m33)
        + m13 * (m21 * m32 - m22 * m31)
         */
        simd_matrix.determinant
    }
    var inverseMatrix: CMRotationMatrix{
        /*
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
         */
        Self(simd_matrix.inverse)
    }
    func multiplying(by aMatrix: CMRotationMatrix) -> CMRotationMatrix{
        let myrows = simd_rows
        let yourcolumns = aMatrix.simd_columns
        return CMRotationMatrix(
            m11: simd_dot(myrows.0, yourcolumns.0),
            m12: simd_dot(myrows.0, yourcolumns.1),
            m13: simd_dot(myrows.0, yourcolumns.2),
            m21: simd_dot(myrows.1, yourcolumns.0),
            m22: simd_dot(myrows.1, yourcolumns.1),
            m23: simd_dot(myrows.1, yourcolumns.2),
            m31: simd_dot(myrows.2, yourcolumns.0),
            m32: simd_dot(myrows.2, yourcolumns.1),
            m33: simd_dot(myrows.2, yourcolumns.2))
    }
}

