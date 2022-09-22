/*
Inout and Mutating Semantics
Understand value mutation paths and exclusive access rules.
Practice with inout parameters and mutating methods on structs.
See how changes propagate predictably through functions.
*/

import Foundation

struct Vector2D {
    var x: Double
    var y: Double

    var magnitude: Double { (x*x + y*y).squareRoot() }

    mutating func scale(by k: Double) {
        x *= k
        y *= k
    }

    mutating func normalize() {
        let m = magnitude
        if m != 0 {
            x /= m
            y /= m
        }
    }
}

func swapEnds<T>(_ a: inout [T]) {
    guard a.count > 1 else { return }
    a.swapAt(0, a.count - 1)
}

func increment(_ x: inout Int) { x += 1 }

func applyTwice(_ x: inout Int, f: (inout Int) -> Void) {
    f(&x)
    f(&x)
}

func add(_ a: inout Int, to b: inout Int) {
    b += a
}

print("=== Mutating methods ===")
var v = Vector2D(x: 3, y: 4)
print("magnitude:", v.magnitude)
v.scale(by: 2)
print("scaled:", v.x, v.y)
v.normalize()
print("normalized magnitude:", v.magnitude)

print("=== Inout basics ===")
var n = 10
increment(&n)
print("n:", n)
applyTwice(&n, f: increment)
print("n after twice:", n)

print("=== Exclusive access with distinct locations ===")
var a = 3
var b = 5
add(&a, to: &b)
print("a:", a, "b:", b)

print("=== Inout with arrays ===")
var arr = Array(1...5)
swapEnds(&arr)
print("swap ends:", arr)

print("=== Inout returns by manual copy ===")
func withTemporary<T>(_ value: T, _ body: (inout T) -> Void) -> T {
    var v = value
    body(&v)
    return v
}
let v2 = withTemporary(Vector2D(x: 1, y: 1)) { $0.scale(by: 5) }
print("temp result:", v2.x, v2.y)

print("=== Chained transformations ===")
func transform(_ a: inout [Int], with f: (Int) -> Int) {
    for i in a.indices { a[i] = f(a[i]) }
}
var nums = [1,2,3,4]
transform(&nums) { $0 * $0 }
print("squares:", nums)
