/*
TaskGroup Concurrency
Fan-out work and fold results deterministically.
Gather unordered results, then sort by input index.
Demonstrates cancellation propagation on error.
*/

import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

enum WorkError: Error { case badInput }

func pseudoWork(_ input: String) async throws -> String {
    if input == "bad" { throw WorkError.badInput }
    let delay = UInt64((Double(input.count) * 0.03 + 0.02) * 1_000_000_000)
    try await Task.sleep(nanoseconds: delay)
    let reversed = String(input.reversed())
    let merged = zip(input, reversed).map { "\($0)\($1)" }.joined()
    return merged
}

func fanOut(_ inputs: [String]) async throws -> [String] {
    try await withThrowingTaskGroup(of: (Int, String).self) { group in
        for (idx, value) in inputs.enumerated() {
            group.addTask { (idx, try await pseudoWork(value)) }
        }
        var results: [(Int, String)] = []
        do {
            while let pair = try await group.next() {
                results.append(pair)
            }
        } catch {
            group.cancelAll()
            throw error
        }
        return results.sorted { $0.0 < $1.0 }.map { $0.1 }
    }
}

let inputs = ["alpha", "beta", "gamma", "delta", "epsilon"]
Task {
    do {
        let outputs = try await fanOut(inputs)
        for (i, o) in outputs.enumerated() {
            print("\(i):", o)
        }
    } catch {
        print("error:", error)
    }
    PlaygroundPage.current.needsIndefiniteExecution = false
}
