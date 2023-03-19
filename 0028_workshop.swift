/*
Equatable Gotchas — Implement equality that respects floating-point quirks.
Treat -0.0 and +0.0 the same, collapse NaNs, and support tolerant comparisons.
Build value semantics that remain hashable and predictable.
*/

import Foundation

extension Double {
    var isNegativeZero: Bool { self == 0 && sign == .minus }
    var canonicalHashBits: UInt64 {
        if isNaN { return 0x7ff8000000000000 }
        if isZero { return 0 }
        return bitPattern
    }
}

struct F64: Hashable, CustomStringConvertible {
    let value: Double

    static func == (lhs: F64, rhs: F64) -> Bool {
        if lhs.value.isNaN && rhs.value.isNaN { return true }
        if lhs.value.isZero && rhs.value.isZero { return true }
        return lhs.value == rhs.value
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(value.canonicalHashBits)
    }

    var description: String { String(describing: value) }
}

infix operator ≈: ComparisonPrecedence

func ≈ (_ a: Double, _ b: Double) -> Bool {
    if a.isNaN && b.isNaN { return true }
    if a.isZero && b.isZero { return true }
    let diff = abs(a - b)
    let scale = max(1.0, abs(a), abs(b))
    let epsilon = 1e-12 * scale
    if diff <= epsilon { return true }
    let ulps = 4
    let next = b.nextUp
    let prev = b.nextDown
    return a >= prev.advanced(by: Double(ulps) * (prev - prev.nextDown)) &&
           a <= next.advanced(by: Double(ulps) * (next.nextUp - next))
}

struct Point: Hashable, CustomStringConvertible {
    var x: F64
    var y: F64

    static func == (lhs: Point, rhs: Point) -> Bool {
        lhs.x == rhs.x && lhs.y == rhs.y
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }

    var description: String { "(\(x), \(y))" }
}

func nearlyEqual(_ a: Double, _ b: Double, rel: Double = 1e-9, abs tol: Double = 1e-12) -> Bool {
    if a.isNaN && b.isNaN { return true }
    if a.isZero && b.isZero { return true }
    let d = abs(a - b)
    if d <= tol { return true }
    return d <= rel * max(abs(a), abs(b))
}

func demo() {
    let p1 = Point(x: F64(value: -0.0), y: F64(value: Double.nan))
    let p2 = Point(x: F64(value: +0.0), y: F64(value: Double.nan))
    print("point equality with NaN and signed zero:", p1 == p2)

    let a = 0.1 + 0.2
    let b = 0.3
    print("exact equality:", a == b)
    print("tolerant ≈:", a ≈ b)
    print("nearlyEqual:", nearlyEqual(a, b))

    var set: Set<Point> = []
    set.insert(p1)
    print("set contains p2:", set.contains(p2))

    let r1 = F64(value: 1.0e16)
    let r2 = F64(value: 1.0e16.nextUp)
    print("r1==r2:", r1 == r2)
    print("relative near:", nearlyEqual(r1.value, r2.value, rel: 1e-9))
}

demo()
