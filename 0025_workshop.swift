/*
Custom Iterators
Build Sequence & IteratorProtocol by hand.
Make a bounded Fibonacci and an infinite Cycle to demonstrate iterator independence.
Use standard operators on custom sequences.
*/
import Foundation

struct Fibonacci: Sequence {
    let limit: Int
    func makeIterator() -> Iterator {
        Iterator(limit: limit)
    }
    struct Iterator: IteratorProtocol {
        var a = 0
        var b = 1
        var index = 0
        let limit: Int
        mutating func next() -> Int? {
            guard index < limit else { return nil }
            defer {
                let next = a + b
                a = b
                b = next
                index += 1
            }
            return a
        }
    }
}

struct Cycle<Base: Collection>: Sequence {
    let base: Base
    init(_ base: Base) { self.base = base }
    func makeIterator() -> Iterator {
        Iterator(base: base, index: base.startIndex)
    }
    struct Iterator: IteratorProtocol {
        let base: Base
        var index: Base.Index
        mutating func next() -> Base.Element? {
            guard !base.isEmpty else { return nil }
            if index == base.endIndex { index = base.startIndex }
            defer { base.formIndex(after: &index) }
            return base[index]
        }
    }
}

let fib = Fibonacci(limit: 12)
print("fibonacci 12:", Array(fib))

var itA = fib.makeIterator()
var itB = fib.makeIterator()
print("iterator A first 5:", (0..<5).compactMap { _ in itA.next() })
print("iterator B first 3:", (0..<3).compactMap { _ in itB.next() })
print("iterator A next 4:", (0..<4).compactMap { _ in itA.next() })

let colors = ["red","green","blue"]
let cycled = Cycle(colors).prefix(8)
print("cycle 8:", Array(cycled))

let zipped = zip(Cycle(colors), fib).prefix(6).map { "\($0.0):\($0.1)" }
print("zip cycle+fib:", zipped)

let evenFibSum = Fibonacci(limit: 20).filter { $0 % 2 == 0 }.reduce(0, +)
print("sum of even fib(20):", evenFibSum)

let windowSource = Array(1...10)
struct Windows: Sequence {
    let data: [Int]
    let size: Int
    let step: Int
    func makeIterator() -> Iterator {
        Iterator(data: data, size: size, step: step, start: 0)
    }
    struct Iterator: IteratorProtocol {
        let data: [Int]
        let size: Int
        let step: Int
        var start: Int
        mutating func next() -> ArraySlice<Int>? {
            guard start < data.count else { return nil }
            let end = Swift.min(start + size, data.count)
            let slice = data[start..<end]
            start += step
            if slice.count < size { return nil }
            return slice
        }
    }
}

let win = Windows(data: windowSource, size: 3, step: 2)
print("windows 3/step2:", win.map { Array($0) })