/*
AsyncSequence Basics
Build and consume typed async streams.
Create a timer-like stream and transform values.
Finish cleanly and collect results.
*/

import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

struct TimerSequence: AsyncSequence {
    typealias Element = Date
    struct Iterator: AsyncIteratorProtocol {
        var remaining: Int
        let interval: TimeInterval
        mutating func next() async -> Date? {
            if remaining <= 0 { return nil }
            remaining -= 1
            try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
            return Date()
        }
    }
    let count: Int
    let interval: TimeInterval
    func makeAsyncIterator() -> Iterator { Iterator(remaining: count, interval: interval) }
}

extension AsyncSequence {
    func mapAsync<T>(_ transform: @escaping (Element) async -> T) -> AsyncStream<T> {
        AsyncStream<T> { continuation in
            Task {
                do {
                    for try await value in self {
                        let mapped = await transform(value)
                        continuation.yield(mapped)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish()
                }
            }
        }
    }
    func collect() async -> [Element] {
        var result: [Element] = []
        do {
            for try await value in self { result.append(value) }
        } catch {
            // Swallow errors to "finish cleanly"
        }
        return result
    }
}

func demo() async {
    let seq = TimerSequence(count: 5, interval: 0.15)
    let stamps = await seq
        .mapAsync { d in d.timeIntervalSince1970 }
        .mapAsync { t in String(format: "%.3f", t) }
        .collect()
    print("stamps:", stamps)
}

Task {
    await demo()
    PlaygroundPage.current.needsIndefiniteExecution = false
}
