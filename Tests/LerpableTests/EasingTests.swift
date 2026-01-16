//
//  EasingTests.swift
//  LerpableTests
//
//  Created by Jake Bromberg on 01/15/26.
//

import XCTest
@testable import Lerpable

final class EasingTests: XCTestCase {
    
    func testLinear() {
        // Linear: f(t) = t
        XCTAssertEqual(Easing.linear.transform(0.0), 0.0)
        XCTAssertEqual(Easing.linear.transform(0.5), 0.5)
        XCTAssertEqual(Easing.linear.transform(1.0), 1.0)
        
        let val = 10.0.lerp(to: 20.0, t: 0.5, using: .linear)
        XCTAssertEqual(val, 15.0)
    }
    
    func testEaseInQuad() {
        // EaseInQuad: f(t) = t^2
        XCTAssertEqual(Easing.easeInQuad.transform(0.0), 0.0)
        XCTAssertEqual(Easing.easeInQuad.transform(0.5), 0.25)
        XCTAssertEqual(Easing.easeInQuad.transform(1.0), 1.0)
        
        // 10 + (20-10) * 0.25 = 12.5
        let val = 10.0.lerp(to: 20.0, t: 0.5, using: .easeInQuad)
        XCTAssertEqual(val, 12.5)
    }
    
    func testEaseOutQuad() {
        // EaseOutQuad: f(t) = 1 - (1-t)^2
        // t=0.5 -> 1 - (0.5)^2 = 1 - 0.25 = 0.75
        XCTAssertEqual(Easing.easeOutQuad.transform(0.5), 0.75)
        
        // 10 + 10 * 0.75 = 17.5
        let val = 10.0.lerp(to: 20.0, t: 0.5, using: .easeOutQuad)
        XCTAssertEqual(val, 17.5)
    }
    
    func testFluentSyntax() {
        struct Point: Lerpable, Equatable {
            var x, y: Double
            static func lerp(_ a: Point, _ b: Point, t: Double) -> Point {
                Point(x: Double.lerp(a.x, b.x, t: t),
                      y: Double.lerp(a.y, b.y, t: t))
            }
        }
        
        let p1 = Point(x: 0, y: 0)
        let p2 = Point(x: 100, y: 100)
        
        // Linear: t=0.5 -> 0.5
        let mid = p1.lerp(to: p2, t: 0.5, using: .linear)
        XCTAssertEqual(mid, Point(x: 50, y: 50))
        
        // EaseInQuad: t=0.5 -> 0.25
        let eased = p1.lerp(to: p2, t: 0.5, using: .easeInQuad)
        XCTAssertEqual(eased, Point(x: 25, y: 25))
    }
    
    func testSendable() {
        // Compile-time check that Easing is Sendable
        let easing: Easing = .linear
        func useSendable(_ s: Sendable) {}
        useSendable(easing)
    }
}
