/*
Protocols with Associated Types
Model generic containers that scale with constraints.
Build Stack and Queue, then write algorithms with where-clauses.
Demonstrate interop between different conforming types.
*/

import Foundation

protocol Container {
    associatedtype Element
    mutating func append(_ newElement: Element)
    var count: Int { get }
    subscript(_ index: Int) -> Element { get }
}

struct Stack<T>: Container {
    private var items: [T] = []
    mutating func append(_ newElement: T) { push(newElement) }
    mutating func push(_ x: T) { items.append(x) }
    mutating func pop() -> T { items.removeLast() }
    var count: Int { items.count }
    subscript(_ i: Int) -> T { items[i] }
}

struct Queue<T>: Container {
    private var items: [T] = []
    mutating func append(_ newElement: T) { items.append(newElement) }
    mutating func pop() -> T? { items.isEmpty ? nil : items.removeFirst() }
    var count: Int { items.count }
    subscript(_ i: Int) -> T { items[i] }
}

extension Container where Element: CustomStringConvertible {
    func dump() {
        for i in 0..<count { print(self[i].description) }
    }
}

func samePrefix<C1: Container, C2: Container>(_ a: C1, _ b: C2, length: Int) -> Bool
where C1.Element == C2.Element, C1.Element: Equatable {
    guard a.count >= length, b.count >= length else { return false }
    for i in 0..<length {
        if a[i] != b[i] { return false }
    }
    return true
}

func allEqual<C: Container>(_ c: C) -> Bool where C.Element: Equatable {
    guard c.count > 0 else { return true }
    for i in 1..<c.count {
        if c[i] != c[0] { return false }
    }
    return true
}

print("=== Stack and Queue ===")
var s = Stack<Int>()
s.append(1)
s.append(2)
s.append(3)
var q = Queue<Int>()
q.append(1)
q.append(2)
q.append(4)

print("same prefix len 2:", samePrefix(s, q, length: 2))
print("same prefix len 3:", samePrefix(s, q, length: 3))

print("=== Dump containers ===")
s.dump()
q.dump()

print("=== allEqual over generic containers ===")
var ones = Queue<Int>()
for _ in 0..<4 { ones.append(1) }
print("all equal ones:", allEqual(ones))

print("=== Mix types that share Element ===")
var s2 = Stack<String>()
s2.append("a")
s2.append("b")
var q2 = Queue<String>()
q2.append("a")
q2.append("b")
print("prefix strings:", samePrefix(s2, q2, length: 2))
