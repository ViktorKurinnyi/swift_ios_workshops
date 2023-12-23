/*
WithTimeout & Timeouts
Race work against a clock to fail fast.
Cancel losing tasks to avoid wasted work.
Build a reusable withTimeout utility.
*/
import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

enum TimeoutError: Error, CustomStringConvertible {
    case timedOut
    var description: String { "timed out" }
}

func withTimeout<T>(_ timeout: Duration, clock: ContinuousClock = .init(), operation: @escaping @Sendable () async throws -> T) async throws -> T {
    let deadline = clock.now.advanced(by: timeout)
    return try await withThrowingTaskGroup(of: T.self) { group in
        group.addTask {
            try Task.checkCancellation()
            return try await operation()
        }
        group.addTask {
            try await clock.sleep(until: deadline)
            throw TimeoutError.timedOut
        }
        for try await value in group {
            group.cancelAll()
            return value
        }
        throw TimeoutError.timedOut
    }
}

func slow(_ ms: Int) async throws -> String {
    try await Task.sleep(nanoseconds: UInt64(ms) * 1_000_000)
    return "ok in \(ms)ms"
}

Task {
    do {
        let fast = try await withTimeout(.milliseconds(150)) {
            try await slow(80)
        }
        print("fast", fast)
    } catch {
        print("fast error", error.localizedDescription)
    }
    do {
        let _ = try await withTimeout(.milliseconds(120)) {
            try await slow(300)
        }
        print("slow should not print")
    } catch {
        print("slow error", error.localizedDescription)
    }
    PlaygroundPage.current.finishExecution()
}
