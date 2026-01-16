//
//  Easing.swift
//  Lerpable
//
//  Created by Jake Bromberg on 01/15/26.
//  Copyright © 2026 WXYC. All rights reserved.
//

import Foundation

/// A container for an easing function that transforms a linear value `t` (typically 0.0 to 1.0)
/// into a eased value.
public struct Easing: Sendable {
    /// The transform function that takes a linear `t` and returns the eased value.
    public let transform: @Sendable (Double) -> Double

    /// Creates a new `Easing` with the given transform function.
    /// - Parameter transform: A closure that takes a Double (typically 0...1) and returns a transformed Double.
    public init(_ transform: @escaping @Sendable (Double) -> Double) {
        self.transform = transform
    }

    // MARK: - Standard Easing Functions

    /// Linear interpolation (no easing).
    public static let linear = Easing { $0 }

    // MARK: Quadratic

    /// Ease-in quadratic (t^2).
    public static let easeInQuad = Easing { $0 * $0 }

    /// Ease-out quadratic (1 - (1-t)^2).
    public static let easeOutQuad = Easing { t in
        1 - (1 - t) * (1 - t)
    }

    /// Ease-in-out quadratic.
    public static let easeInOutQuad = Easing { t in
        t < 0.5 ? 2 * t * t : 1 - pow(-2 * t + 2, 2) / 2
    }
    
    // MARK: Cubic

    /// Ease-in cubic (t^3).
    public static let easeInCubic = Easing { t in t * t * t }

    /// Ease-out cubic (1 - (1-t)^3).
    public static let easeOutCubic = Easing { t in
        1 - pow(1 - t, 3)
    }

    /// Ease-in-out cubic.
    public static let easeInOutCubic = Easing { t in
        t < 0.5 ? 4 * t * t * t : 1 - pow(-2 * t + 2, 3) / 2
    }
    
    // MARK: Sine
    
    /// Ease-in sine.
    public static let easeInSine = Easing { t in
        1 - cos((t * .pi) / 2)
    }
    
    /// Ease-out sine.
    public static let easeOutSine = Easing { t in
        sin((t * .pi) / 2)
    }
    
    /// Ease-in-out sine.
    public static let easeInOutSine = Easing { t in
        -(cos(.pi * t) - 1) / 2
    }
}
