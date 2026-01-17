//
//  SteppedMacroTests.swift
//  LerpableTests
//
//  Tests for the @Stepped macro, verifying that marked properties use
//  threshold-based discrete switching instead of linear interpolation.
//
//  Created by Jake Bromberg on 01/16/26.
//  Copyright © 2026 WXYC. All rights reserved.
//

import Testing
@testable import Lerpable

@Lerpable
struct TestSteppedStruct {
    var continuous: Float
    @Stepped(threshold: 0.5) var discrete: Int
}

@Lerpable
struct TestCustomThreshold {
    @Stepped(threshold: 0.3) var earlySwitch: Bool
}

@Lerpable
struct TestMixedProperties {
    var linear1: Double
    @Stepped(threshold: 0.5) var stepped1: Int
    var linear2: Float
    @Stepped(threshold: 0.7) var stepped2: Bool
}

@Lerpable
struct TestArrayProperty {
    @Stepped(threshold: 0.5) var items: [Float]
    var mix: Float
}

@Lerpable
struct TestDefaultThreshold {
    @Stepped var useDefault: Bool
}

@Suite("Stepped Macro")
struct SteppedMacroTests {

    @Test("Stepped property switches at threshold")
    func steppedPropertySwitchesAtThreshold() {
        let a = TestSteppedStruct(continuous: 0, discrete: 10)
        let b = TestSteppedStruct(continuous: 100, discrete: 20)

        // Before threshold: should use a's value
        let before = TestSteppedStruct.lerp(a, b, t: 0.49)
        #expect(before.discrete == 10)

        // After threshold: should use b's value
        let after = TestSteppedStruct.lerp(a, b, t: 0.51)
        #expect(after.discrete == 20)

        // Continuous property should still interpolate linearly
        #expect(before.continuous == 49.0)
        #expect(after.continuous == 51.0)
    }

    @Test("Exactly at threshold uses b's value")
    func exactlyAtThreshold() {
        let a = TestSteppedStruct(continuous: 0, discrete: 10)
        let b = TestSteppedStruct(continuous: 100, discrete: 20)

        // At exactly t=0.5, should use b's value (t < threshold is false)
        let atThreshold = TestSteppedStruct.lerp(a, b, t: 0.5)
        #expect(atThreshold.discrete == 20)
    }

    @Test("Custom threshold is respected")
    func customThresholdRespected() {
        let a = TestCustomThreshold(earlySwitch: false)
        let b = TestCustomThreshold(earlySwitch: true)

        // Before custom threshold (0.3)
        let before = TestCustomThreshold.lerp(a, b, t: 0.29)
        #expect(before.earlySwitch == false)

        // After custom threshold (0.3)
        let after = TestCustomThreshold.lerp(a, b, t: 0.31)
        #expect(after.earlySwitch == true)
    }

    @Test("Mixed linear and stepped properties")
    func mixedProperties() {
        let a = TestMixedProperties(linear1: 0, stepped1: 10, linear2: 0, stepped2: false)
        let b = TestMixedProperties(linear1: 100, stepped1: 20, linear2: 100, stepped2: true)

        // At t=0.5, linear properties interpolate, stepped1 switches, stepped2 hasn't yet
        let mid = TestMixedProperties.lerp(a, b, t: 0.5)
        #expect(mid.linear1 == 50)
        #expect(mid.linear2 == 50)
        #expect(mid.stepped1 == 20)  // threshold 0.5, so switches
        #expect(mid.stepped2 == false)  // threshold 0.7, not yet

        // At t=0.75, stepped2 should now have b's value
        let later = TestMixedProperties.lerp(a, b, t: 0.75)
        #expect(later.stepped2 == true)
    }

    @Test("Array property with stepped works correctly")
    func arrayPropertyStepped() {
        let a = TestArrayProperty(items: [1.0, 2.0, 3.0], mix: 0)
        let b = TestArrayProperty(items: [10.0, 20.0, 30.0], mix: 100)

        // Before threshold
        let before = TestArrayProperty.lerp(a, b, t: 0.4)
        #expect(before.items == [1.0, 2.0, 3.0])
        #expect(abs(before.mix - 40.0) < 0.001)

        // After threshold
        let after = TestArrayProperty.lerp(a, b, t: 0.6)
        #expect(after.items == [10.0, 20.0, 30.0])
        #expect(abs(after.mix - 60.0) < 0.001)
    }

    @Test("Default threshold is 0.5")
    func defaultThreshold() {
        let a = TestDefaultThreshold(useDefault: false)
        let b = TestDefaultThreshold(useDefault: true)

        // Before default threshold (0.5)
        let before = TestDefaultThreshold.lerp(a, b, t: 0.49)
        #expect(before.useDefault == false)

        // After default threshold (0.5)
        let after = TestDefaultThreshold.lerp(a, b, t: 0.51)
        #expect(after.useDefault == true)
    }

    @Test("Edge cases: t=0 and t=1")
    func edgeCases() {
        let a = TestSteppedStruct(continuous: 0, discrete: 10)
        let b = TestSteppedStruct(continuous: 100, discrete: 20)

        // t=0: should use a's values
        let atZero = TestSteppedStruct.lerp(a, b, t: 0)
        #expect(atZero.continuous == 0)
        #expect(atZero.discrete == 10)

        // t=1: should use b's values
        let atOne = TestSteppedStruct.lerp(a, b, t: 1)
        #expect(atOne.continuous == 100)
        #expect(atOne.discrete == 20)
    }
}

// MARK: - Bool and Array Conformance Tests

@Suite("Discrete Type Conformances")
struct DiscreteTypeTests {

    @Test("Bool lerps using stepped interpolation")
    func boolLerp() {
        #expect(Bool.lerp(false, true, t: 0.0) == false)
        #expect(Bool.lerp(false, true, t: 0.49) == false)
        #expect(Bool.lerp(false, true, t: 0.5) == true)
        #expect(Bool.lerp(false, true, t: 1.0) == true)
    }

    @Test("Array lerps using stepped interpolation")
    func arrayLerp() {
        let a = [1, 2, 3]
        let b = [4, 5, 6]

        #expect([Int].lerp(a, b, t: 0.0) == [1, 2, 3])
        #expect([Int].lerp(a, b, t: 0.49) == [1, 2, 3])
        #expect([Int].lerp(a, b, t: 0.5) == [4, 5, 6])
        #expect([Int].lerp(a, b, t: 1.0) == [4, 5, 6])
    }

    @Test("Array with different lengths uses stepped correctly")
    func arrayDifferentLengths() {
        let a = [1, 2]
        let b = [10, 20, 30]

        // Before threshold: returns a (shorter array)
        #expect([Int].lerp(a, b, t: 0.3) == [1, 2])

        // After threshold: returns b (longer array)
        #expect([Int].lerp(a, b, t: 0.7) == [10, 20, 30])
    }
}
