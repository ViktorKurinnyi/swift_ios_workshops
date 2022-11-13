/*
Existentials & Type Erasure — Hide concrete types behind stable interfaces.
Build a tiny type-erased sink and combine heterogeneous producers.
Contrast generic functions, any Protocol, and type-erased wrappers.
End with a single run that broadcasts into multiple erased sinks.
*/

import Foundation

public protocol Sink {
    associatedtype Input
    mutating func send(_ value: Input)
}

public struct ArraySink<T>: Sink {
    public private(set) var storage: [T] = []
    public init() {}
    public mutating func send(_ value: T) { storage.append(value) }
}

public struct IntStatsSink: Sink {
    public private(set) var count = 0
    public private(set) var sum = 0
    public private(set) var min: Int = .max
    public private(set) var max: Int = .min
    public init() {}
    public mutating func send(_ value: Int) {
        count += 1
        sum += value
        if value < min { min = value }
        if value > max { max = value }
    }
}

private class _AnySinkBase<Input> {
    func send(_ value: Input) { fatalError() }
}

private final class _AnySinkBox<S: Sink>: _AnySinkBase<S.Input> {
    var sink: S
    init(_ sink: S) { self.sink = sink }
    override func send(_ value: S.Input) { sink.send(value) }
}

public struct AnySink<Input>: Sink {
    private var _boxSend: (Input) -> Void
    private var _getter: () -> Any
    public init<S: Sink>(_ sink: S) where S.Input == Input {
        let box = _AnySinkBox(sink)
        self._boxSend = { [box] in box.send($0) }
        self._getter = { box.sink }
    }
    public mutating func send(_ value: Input) { _boxSend(value) }
    public func unwrap<T>(as type: T.Type) -> T? { _getter() as? T }
}

public protocol Producer {
    associatedtype Output
    func make() -> [Output]
}

public struct IntRangeProducer: Producer {
    public let range: ClosedRange<Int>
    public init(_ range: ClosedRange<Int>) { self.range = range }
    public func make() -> [Int] { Array(range) }
}

public struct RandomProducer: Producer {
    public let count: Int
    public init(count: Int) { self.count = count }
    public func make() -> [Int] {
        var rng = SystemRandomNumberGenerator()
        return (0..<count).map { _ in Int.random(in: 0...9, using: &rng) }
    }
}

public func broadcast<T>(_ values: [T], into sinks: inout [AnySink<T>]) {
    for v in values { for i in sinks.indices { sinks[i].send(v) } }
}

public func collect<P: Producer, S: Sink>(_ p: P, into sink: inout S) where P.Output == S.Input {
    for v in p.make() { sink.send(v) }
}

var s1 = ArraySink<Int>()
var s2 = IntStatsSink()
collect(IntRangeProducer(1...5), into: &s1)
collect(RandomProducer(count: 5), into: &s1)
collect(IntRangeProducer(3...7), into: &s2)

var erased: [AnySink<Int>] = [AnySink(s1), AnySink(s2)]
broadcast([42, 7, 3], into: &erased)

let a1 = erased[0].unwrap(as: ArraySink<Int>.self)!
let a2 = erased[1].unwrap(as: IntStatsSink.self)!
print("ArraySink count: \(a1.storage.count) first: \(a1.storage.first ?? -1) last: \(a1.storage.last ?? -1)")
print("Stats count: \(a2.count) sum: \(a2.sum) min: \(a2.min) max: \(a2.max)")

let existentialSinks: [any Sink] = [ArraySink<String>(), ArraySink<Double>()]
print("Existential array holds \(existentialSinks.count) heterogeneous sinks")
