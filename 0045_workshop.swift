/*
Tasks & Cancellation
Respect cooperative cancellation and timeouts.
Build a withTimeout helper and cancel work cleanly.
Observe Task cancellation state during loops.
*/

import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

enum TimeoutError: Error, CustomStringConvertible {
    case timedOut(Double)
    var description: String { "timed out after \(seconds)s" }
    var seconds: Double {
        switch self { case .timedOut(let s): return s }
    }
}

func withTimeout<T>(_ seconds: Double, operation: @escaping @Sendable () async throws -> T) async throws -> T {
    try await withThrowingTaskGroup(of: T.self) { group in
        group.addTask { try await operation() }
        group.addTask {
            try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            throw TimeoutError.timedOut(seconds)
        }
        do {
            let result = try await group.next()!
            group.cancelAll()
            return result
        } catch {
            group.cancelAll()
            throw error
        }
    }
}

struct Cancelled: Error {}

func slowSum(_ n: Int) async throws -> Int {
    var total = 0
    for i in 1...n {
        try Task.checkCancellation()
        total += i
        try await Task.sleep(nanoseconds: 40_000_000)
    }
    return total
}

func demoCancellation() async {
    let t = Task { () -> Int in
        do {
            return try await slowSum(200)
        } catch {
            // Treat cancellation (or any error) as -1 so the Task doesn't throw.
            return -1
        }
    }
    Task {
        try? await Task.sleep(nanoseconds: 300_000_000)
        t.cancel()
    }
    let result = await t.value
    print("cancelled sum:", result)
}

func demoTimeout() async {
    do {
        let value = try await withTimeout(0.25) {
            try await slowSum(20)
        }
        print("value:", value)
    } catch {
        print("timeout:", error)
    }
}

Task {
    await demoCancellation()
    await demoTimeout()
    PlaygroundPage.current.needsIndefiniteExecution = false
}
