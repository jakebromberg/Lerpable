//
//  Stepped.swift
//  Lerpable
//
//  Macro for marking properties that should use stepped (discrete) interpolation
//  rather than linear interpolation. The property switches from `a` to `b` when
//  the interpolation factor `t` reaches the specified threshold.
//
//  Created by Jake Bromberg on 01/16/26.
//  Copyright © 2026 WXYC. All rights reserved.
//

/// Marks a property for stepped (discrete) interpolation.
///
/// Properties marked with `@Stepped` will switch from value `a` to value `b`
/// when the interpolation factor `t >= threshold`, rather than interpolating
/// linearly between them.
///
/// This is useful for:
/// - Boolean flags that should toggle at a specific point
/// - Discrete values like integers that represent distinct states
/// - Array properties where blending doesn't make sense
///
/// ```swift
/// @Lerpable
/// struct RFNoiseParams {
///     var whiteMix: Float                           // Linear: 0.0 → 1.0 smoothly
///     @Stepped(threshold: 0.5) var pinkOctaves: Int // Stepped: switches at t=0.5
///     @Stepped(threshold: 0.3) var stereoEnabled: Bool // Switches earlier
/// }
/// ```
///
/// - Parameter threshold: The interpolation point at which to switch (default: 0.5)
@attached(peer)
public macro Stepped(threshold: Double = 0.5) = #externalMacro(
    module: "LerpableMacros",
    type: "SteppedMacro"
)
