/*
Teaches generic math over BinaryInteger and FloatingPoint.
Builds reusable algorithms: clamp, gcd/lcm, power, mean/variance, dot, polynomial.
Demonstrates type constraints and overloads that pick the right numeric semantics.
Runs entirely in a Playground with printed results.
*/
import Foundation

func clamp<T: Comparable>(_ x: T, _ lower: T, _ upper: T) -> T {
    precondition(lower <= upper)
    return min(max(x, lower), upper)
}

func gcd<T: BinaryInteger>(_ a0: T, _ b0: T) -> T {
    var a = a0.magnitude
    var b = b0.magnitude
    while b != 0 {
        let r = a % b
        a = b
        b = r
    }
    return T(a)
}

func lcm<T: BinaryInteger>(_ a: T, _ b: T) -> T {
    if a == 0 || b == 0 { return 0 }
    return (a / gcd(a, b)) * b
}

func ipow<T: BinaryInteger>(_ base: T, _ exp: Int) -> T {
    precondition(exp >= 0)
    var result: T = 1
    var b = base
    var e = exp
    while e > 0 {
        if e & 1 == 1 { result *= b }
        e >>= 1
        if e > 0 { b *= b }
    }
    return result
}

func mean<T: BinaryInteger>(_ xs: [T]) -> Double {
    let total = xs.reduce(0.0) { $0 + Double($1) }
    return xs.isEmpty ? .nan : total / Double(xs.count)
}

func mean<T: FloatingPoint>(_ xs: [T]) -> T {
    let total = xs.reduce(0) { $0 + $1 }
    return xs.isEmpty ? .nan : total / T(xs.count)
}

func variance<T: FloatingPoint>(_ xs: [T]) -> T {
    var m: T = 0
    var s: T = 0
    var n: T = 0
    for x in xs {
        n += 1
        let d = x - m
        m += d / n
        s += d * (x - m)
    }
    return n > 1 ? s / (n - 1) : .nan
}

func dot<T: Numeric>(_ a: [T], _ b: [T]) -> T {
    precondition(a.count == b.count)
    return zip(a, b).reduce(0) { $0 + $1.0 * $1.1 }
}

func poly<T: FloatingPoint>(_ coeffs: [T], at x: T) -> T {
    var acc: T = 0
    for c in coeffs.reversed() {
        acc = acc * x + c
    }
    return acc
}

struct RunningStats<T: FloatingPoint> {
    private(set) var count: Int = 0
    private(set) var mean: T = 0
    private(set) var m2: T = 0
    mutating func push(_ x: T) {
        count += 1
        let n = T(count)
        let delta = x - mean
        mean += delta / n
        m2 += delta * (x - mean)
    }
    var variance: T {
        count > 1 ? m2 / T(count - 1) : .nan
    }
}

let ints: [Int] = [3, 5, 7, 9, 11, 13]
let moreInts: [Int] = [14, 21, 28, 35, 42, 49]
let doubles: [Double] = [1.25, 3.5, 5.75, 7.0, 9.25, 11.5]

print("clamp Int:", clamp(12, 0, 10))
print("clamp Double:", clamp(1.618, 0.0, 1.0))

print("gcd:", gcd(84, 126))
print("lcm:", lcm(21, 6))

print("ipow(3, 13):", ipow(3, 13))

print("mean ints:", mean(ints))
print("mean doubles:", mean(doubles))
print("variance doubles:", variance(doubles))

print("dot Int:", dot(ints, moreInts))
print("dot Double:", dot(doubles, doubles))

let coeffs: [Double] = [1, -2, 0, 3]
print("poly 3x^3 - 2x + 1 at x=1.5:", poly(coeffs, at: 1.5))

var rs = RunningStats<Double>()
for x in doubles { rs.push(x) }
print("running mean:", rs.mean, "running variance:", rs.variance)

let bigA: UInt64 = 12_345_678_901_234_567
let bigB: UInt64 = 9_876_543_210_987_654
print("gcd big:", gcd(bigA, bigB))

let largeInts = Array(1...1000)
print("mean 1...1000:", mean(largeInts))
print("variance 1..10 doubles:", variance((1...10).map(Double.init)))
