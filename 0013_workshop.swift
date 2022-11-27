/*
Opaque Result Types — Return “some” types to preserve abstraction without existentials.
Build pipelines that produce lazy sequences and protocol-based values.
Compare returning `some P` vs `any P` and show how type identity is preserved.
Finish with a small computation using only opaque returns.
*/

import Foundation

public func makeEvens(upTo n: Int) -> StrideTo<Int> {
    stride(from: 0, to: n, by: 2)
}

public func squared<S: Sequence>(_ s: S) -> AnySequence<Int> where S.Element == Int {
    AnySequence(s.lazy.map { $0 * $0 })
}

public protocol Describable {
    var description: String { get }
}

public struct Capsule: Describable {
    public enum Kind { case a, b }
    public var kind: Kind
    public var payload: Int
    public var description: String { "Capsule(\(kind), \(payload))" }
}

extension String: Describable {}

public func makeCapsule(flag: Bool, seed: Int) -> Capsule {
    let k: Capsule.Kind = flag ? .a : .b
    return Capsule(kind: k, payload: seed * 2)
}

public func makeDescribable(flag: Bool) -> any Describable {
    if flag { return Capsule(kind: .a, payload: 1) } else { return String("other") }
}

public func makeSquares(limit: Int) -> AnySequence<Int> {
    squared(makeEvens(upTo: limit))
}

public func prefix<S: Sequence>(_ n: Int, of s: S) -> AnySequence<S.Element> {
    AnySequence(s.prefix(n))
}

let evens = makeEvens(upTo: 20)
let squares = makeSquares(limit: 20)
print("Evens:", Array(evens))
print("Squares:", Array(squares))

let d1 = makeCapsule(flag: true, seed: 7)
print("Opaque same type always:", d1.description)

let d2 = makeDescribable(flag: Bool.random())
print("Existential may vary:", d2.description)

let top3 = prefix(3, of: squares)
print("Top 3 squares:", Array(top3))
