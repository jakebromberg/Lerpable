# Lerpable

A Swift library and macro for seamless linear interpolation.

`Lerpable` provides a protocol and a macro to easily enable linear interpolation for your custom types. It comes with built-in support for standard Swift types like `Double`, `Float`, `CGFloat`, `Int`, `SIMD` vectors, `Bool`, and `Array`.

## Installation

Add `Lerpable` as a dependency in your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/Lerpable.git", from: "1.0.0")
]
```

## Usage

### Using the `@Lerpable` Macro

The easiest way to make your types interpolatable is using the `@Lerpable` macro. It automatically generates the `Lerpable` conformance for structs where all stored properties also conform to `Lerpable`.

```swift
import Lerpable

@Lerpable
struct Point {
    var x: Double
    var y: Double
}

let start = Point(x: 0, y: 0)
let end = Point(x: 10, y: 20)

// Interpolate halfway
let mid = Point.lerp(start, end, t: 0.5) 
// Result: Point(x: 5.0, y: 10.0)
```

### Stepped Interpolation with `@Stepped`

For properties that shouldn't interpolate smoothly—like booleans, enums, or discrete values—use the `@Stepped` macro. These properties switch from `a` to `b` at a configurable threshold instead of blending.

```swift
@Lerpable
struct RFNoiseParams {
    var whiteMix: Float                            // Linear: 0.0 → 1.0 smoothly
    @Stepped(threshold: 0.5) var pinkOctaves: Int  // Stepped: switches at t=0.5
    @Stepped(threshold: 0.3) var stereoEnabled: Bool // Switches earlier at t=0.3
}

let a = RFNoiseParams(whiteMix: 0, pinkOctaves: 8, stereoEnabled: false)
let b = RFNoiseParams(whiteMix: 1, pinkOctaves: 12, stereoEnabled: true)

let mid = RFNoiseParams.lerp(a, b, t: 0.4)
// mid.whiteMix == 0.4 (interpolated)
// mid.pinkOctaves == 8 (not yet at 0.5 threshold)
// mid.stereoEnabled == true (past 0.3 threshold)
```

The default threshold is `0.5` if not specified:

```swift
@Stepped var discrete: Int  // Switches at t=0.5
```

### Recursive Conformance

Types that contain other `Lerpable` types can also easily conform using the macro. This allows for deep, recursive interpolation.

```swift
@Lerpable
struct Size {
    var width: Double
    var height: Double
}

@Lerpable
struct Frame {
    var origin: Point
    var size: Size
}

// Interpolating Frame will automatically interpolate its origin and size, 
// which in turn interpolate their x/y and width/height respectively.
```

### Manual Conformance

You can also conform to the `Lerpable` protocol manually:

```swift
extension MyType: Lerpable {
    static func lerp(_ a: MyType, _ b: MyType, t: Double) -> MyType {
        // Your custom interpolation logic
    }
}
```

#### Why Manual Conformance?

Manual conformance is useful when you need custom interpolation logic, such as interpolating angles (shortest path) or colors (hue interpolation).

```swift
struct Angle: Lerpable {
    var radians: Double

    static func lerp(_ a: Angle, _ b: Angle, t: Double) -> Angle {
        let twoPi = 2 * Double.pi
        let delta = (b.radians - a.radians).truncatingRemainder(dividingBy: twoPi)
        let shortestDelta = (2 * delta).truncatingRemainder(dividingBy: twoPi) - delta
        return Angle(radians: a.radians + shortestDelta * t)
    }
}
```

### Supported Types

`Lerpable` includes out-of-the-box support for:

- **Floating Point**: `Double`, `Float`, `CGFloat`, `Float80` (x86_64)
- **Integers**: `Int`, `Int8`...`Int64`, `UInt`...`UInt64`
- **SIMD**: `SIMD2`, `SIMD3`, `SIMD4` (where Scalar is BinaryFloatingPoint)
- **Discrete**: `Bool`, `Array` (use stepped interpolation, switching at t=0.5)

