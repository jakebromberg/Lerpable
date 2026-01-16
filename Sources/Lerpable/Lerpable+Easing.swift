//
//  Lerpable+Easing.swift
//  Lerpable
//
//  Created by Jake Bromberg on 01/15/26.
//  Copyright © 2026 WXYC. All rights reserved.
//

import Foundation

extension Lerpable {
    /// Linearly interpolates to a target value using an easing function.
    ///
    /// - Parameters:
    ///   - target: The value to interpolate towards.
    ///   - t: The interpolation factor, typically in [0, 1].
    ///   - easing: The easing function to apply to `t` before interpolation. Defaults to `.linear`.
    /// - Returns: The interpolated value.
    @inlinable
    public func lerp(to target: Self, t: Double, using easing: Easing = .linear) -> Self {
        let transformedT = easing.transform(t)
        return Self.lerp(self, target, t: transformedT)
    }
}

extension Lerpable {
    /// Linearly interpolates between two values using an easing function (static variant).
    ///
    /// - Parameters:
    ///   - a: The start value.
    ///   - b: The end value.
    ///   - t: The interpolation factor.
    ///   - easing: The easing function.
    /// - Returns: The interpolated value.
    @inlinable
    public static func lerp(_ a: Self, _ b: Self, t: Double, using easing: Easing) -> Self {
        a.lerp(to: b, t: t, using: easing)
    }
}
