/*
Custom Operators — Create readable DSLs with precedence and associativity.
Define pipeline, dot, and power operators and a tiny vector math DSL.
Demonstrate precedence groups and how custom operators compose.
Drive a small numerical pipeline to produce final values.
*/

import Foundation
import CoreGraphics

precedencegroup PipelinePrecedence {
    associativity: left
    lowerThan: MultiplicationPrecedence
}

infix operator |> : PipelinePrecedence
public func |> <A, B>(x: A, f: (A) -> B) -> B { f(x) }

precedencegroup DotPrecedence {
    associativity: left
    higherThan: MultiplicationPrecedence
}

infix operator • : DotPrecedence
infix operator ** : MultiplicationPrecedence
prefix operator √

public struct Vec2: Equatable, CustomStringConvertible {
    public var x: Double
    public var y: Double
    public var description: String { "(\(x), \(y))" }
    public init(_ x: Double, _ y: Double) { self.x = x; self.y = y }
    public static func + (lhs: Vec2, rhs: Vec2) -> Vec2 { .init(lhs.x + rhs.x, lhs.y + rhs.y) }
    public static func - (lhs: Vec2, rhs: Vec2) -> Vec2 { .init(lhs.x - rhs.x, lhs.y - rhs.y) }
    public static func * (lhs: Vec2, rhs: Double) -> Vec2 { .init(lhs.x * rhs, lhs.y * rhs) }
    public static func * (lhs: Double, rhs: Vec2) -> Vec2 { rhs * lhs }
    public static func • (lhs: Vec2, rhs: Vec2) -> Double { lhs.x * rhs.x + lhs.y * rhs.y }
}

public func ** (lhs: Double, rhs: Double) -> Double { pow(lhs, rhs) }
public prefix func √ (_ x: Double) -> Double { sqrt(x) }

public func length(_ v: Vec2) -> Double { √(v • v) }
public func normalize(_ v: Vec2) -> Vec2 {
    let l = max(length(v), .leastNonzeroMagnitude)
    return v * (1.0 / l)
}

public func rotate(_ v: Vec2, by radians: Double) -> Vec2 {
    let c = cos(radians), s = sin(radians)
    return Vec2(v.x * c - v.y * s, v.x * s + v.y * c)
}

public func polygonArea(_ points: [Vec2]) -> Double {
    guard points.count >= 3 else { return 0 }
    var sum = 0.0
    for i in 0..<points.count {
        let a = points[i]
        let b = points[(i + 1) % points.count]
        sum += a.x * b.y - a.y * b.x
    }
    return abs(sum) * 0.5
}

let a = Vec2(3, 4)
let b = Vec2(-2, 5)
let c = a + b
let l = length(c)
let n = normalize(c)
let r = rotate(n, by: .pi / 6)

let pipeline = 5.0
    |> { $0 ** 2 }
    |> { $0 + l }
    |> { $0 * (n • r) }
print("Vec c:", c, "length:", l)
print("Normalized:", n, "rotated:", r)
print("Pipeline result:", pipeline)

let tri = [Vec2(0,0), Vec2(4,0), Vec2(0,3)]
print("Triangle area:", polygonArea(tri))
