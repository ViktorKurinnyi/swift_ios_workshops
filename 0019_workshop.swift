/*
Assertions & Preconditions — Fail fast in debug; protect invariants in release.
Use assert, precondition, and preconditionFailure to enforce contracts.
Design small APIs that validate inputs and guard unsafe operations.
Run with values that satisfy invariants to avoid stopping execution.
*/

import Foundation

public func sqrtChecked(_ x: Double) -> Double {
    precondition(x >= 0, "square root requires nonnegative input")
    return sqrt(x)
}

public struct NonEmpty<T>: RandomAccessCollection {
    public typealias Element = T
    public private(set) var storage: [T]
    public init?(_ xs: [T]) {
        guard !xs.isEmpty else { return nil }
        self.storage = xs
    }
    public var startIndex: Int { storage.startIndex }
    public var endIndex: Int { storage.endIndex }
    public subscript(position: Int) -> T {
        get {
            assert(position >= 0 && position < storage.count, "index out of bounds")
            return storage[position]
        }
        set {
            assert(position >= 0 && position < storage.count, "index out of bounds")
            storage[position] = newValue
        }
    }
    public func index(after i: Int) -> Int { storage.index(after: i) }
    public func index(before i: Int) -> Int { storage.index(before: i) }
}

public func dot(_ a: [Double], _ b: [Double]) -> Double {
    precondition(a.count == b.count, "vectors must have equal length")
    var s = 0.0
    for i in 0..<a.count { s += a[i] * b[i] }
    return s
}

public func requireSorted(_ xs: [Int]) {
    for i in 1..<xs.count {
        assert(xs[i-1] <= xs[i], "array not sorted at index \(i)")
    }
}

if let ne = NonEmpty([1,2,3]) {
    print("NonEmpty first:", ne[0])
}

let v1 = [1.0, 2.0, 3.0]
let v2 = [4.0, 5.0, 6.0]
let s = dot(v1, v2)
print("Dot product:", s)

let sorted = [1,2,2,5,8]
requireSorted(sorted)

let root = sqrtChecked(49)
print("Sqrt:", root)
