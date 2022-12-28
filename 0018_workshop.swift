/*
Defer and Resource Safety — Guarantee cleanup on every code path.
Simulate resources that must be closed, and use defer to order teardown.
Show multiple defers, early returns, and lifetimes with prints.
End with a safe transaction that always leaves the system consistent.
*/

import Foundation

public final class Resource {
    public let name: String
    public private(set) var isOpen = false
    public init(_ name: String) { self.name = name }
    public func open() { isOpen = true; print("open:", name) }
    public func close() { if isOpen { isOpen = false; print("close:", name) } }
    deinit { close() }
}

public struct Transaction {
    public var log: [String] = []
    public mutating func record(_ s: String) { log.append(s) }
}

public func processFiles(names: [String]) -> Int {
    var processed = 0
    let session = Resource("session")
    session.open()
    defer { session.close() }
    for n in names {
        let r = Resource(n)
        r.open()
        defer { r.close() }
        if n.hasSuffix(".skip") { continue }
        if n.hasSuffix(".bad") { return processed }
        processed += 1
    }
    return processed
}

public func safeTransfer(_ amount: Int, from: inout Int, to: inout Int) -> Bool {
    var tx = Transaction()
    tx.record("begin")
    defer { tx.record("end"); print("tx:", tx.log.joined(separator: " -> ")) }
    guard amount > 0 else { tx.record("reject amount"); return false }
    guard from >= amount else { tx.record("insufficient"); return false }
    from -= amount
    defer {
        if from < 0 { from += amount; tx.record("rollback debit") }
    }
    to += amount
    tx.record("commit")
    return true
}

let count = processFiles(names: ["a.txt", "b.skip", "c.bad", "d.txt"])
print("Processed:", count)

var a = 100
var b = 40
let ok1 = safeTransfer(30, from: &a, to: &b)
let ok2 = safeTransfer(500, from: &a, to: &b)
print("Balances:", a, b, "successes:", ok1, ok2)
