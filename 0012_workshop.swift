/*
Generics by Example — Reusable algorithms with constraints, where clauses, and inference.
Implement chunked, unique, and a RingBuffer that is a Sequence.
Show conditional conformances and generic utility functions.
Run end-to-end with Int and String data.
*/

import Foundation

public extension Sequence where Element: Hashable {
    func unique() -> [Element] {
        var seen: Set<Element> = []
        var out: [Element] = []
        out.reserveCapacity(underestimatedCount)
        for x in self where seen.insert(x).inserted { out.append(x) }
        return out
    }
}

public extension Collection {
    func chunked(size: Int) -> [[Element]] {
        precondition(size > 0)
        var i = startIndex
        var result: [[Element]] = []
        while i != endIndex {
            let j = index(i, offsetBy: size, limitedBy: endIndex) ?? endIndex
            result.append(Array(self[i..<j]))
            i = j
        }
        return result
    }
}

public struct RingBuffer<Element>: Sequence {
    private var storage: [Element?]
    private var head = 0
    private var tail = 0
    private var filled = false
    public init(capacity: Int) {
        precondition(capacity > 0)
        storage = Array(repeating: nil, count: capacity)
    }
    public var capacity: Int { storage.count }
    public var isEmpty: Bool { !filled && head == tail }
    public var isFull: Bool { filled && head == tail }
    public mutating func push(_ element: Element) {
        storage[tail] = element
        tail = (tail + 1) % capacity
        if filled { head = (head + 1) % capacity } else if tail == head { filled = true }
    }
    public mutating func pop() -> Element? {
        guard !isEmpty else { return nil }
        defer {
            storage[head] = nil
            head = (head + 1) % capacity
            if filled && head == tail { filled = false }
        }
        return storage[head]
    }
    public func makeIterator() -> AnyIterator<Element> {
        var idx = head
        var count = isFull ? capacity : (tail - head + capacity) % capacity
        return AnyIterator {
            guard count > 0 else { return nil }
            defer { idx = (idx + 1) % capacity; count -= 1 }
            return storage[idx]
        }
    }
}

public extension RingBuffer where Element: Numeric {
    func sum() -> Element {
        reduce(into: .zero) { $0 += $1 }
    }
}

public func applyTwice<T>(_ x: T, _ f: (T) -> T) -> T { f(f(x)) }

public func maybeTransform<S: Sequence>(_ s: S, by f: (S.Element) -> S.Element) -> [S.Element] where S.Element: Comparable {
    let t = s.sorted()
    return t.map(f)
}

var nums = [5, 3, 3, 9, 1, 5, 2, 9]
let uniq = nums.unique().sorted()
let chunks = uniq.chunked(size: 3)
print("Unique sorted:", uniq)
print("Chunks:", chunks)

var rb = RingBuffer<Int>(capacity: 5)
for i in 1...8 { rb.push(i) }
print("RingBuffer elements:", Array(rb))
print("RingBuffer sum:", rb.sum())

let doubled = maybeTransform(nums) { $0 * 2 }
print("Doubled sorted:", doubled)

let greet = applyTwice("Hi") { $0 + "!" }
print("Apply twice:", greet)

var rbs = RingBuffer<String>(capacity: 3)
["a","b","c","d"].forEach { rbs.push($0) }
print("String RingBuffer:", Array(rbs))
