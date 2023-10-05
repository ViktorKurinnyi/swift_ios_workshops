/*
Actors in Practice
Protect shared mutable state with isolation.
Run many concurrent mutations safely.
Model a simple counter and ledger.
*/

import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

actor Counter {
    private var value: Int = 0
    func increment() { value += 1 }
    func add(_ n: Int) { value += n }
    func get() -> Int { value }
}

actor Ledger {
    private var entries: [String: Int] = [:]
    func record(_ key: String, _ amount: Int) {
        entries[key, default: 0] += amount
    }
    func snapshot() -> [String: Int] { entries }
    func total() -> Int { entries.values.reduce(0, +) }
}

func runActors() async {
    let counter = Counter()
    let ledger = Ledger()
    await withTaskGroup(of: Void.self) { group in
        for i in 1...100 {
            group.addTask {
                await counter.increment()
                await ledger.record("t\(i % 5)", i)
            }
        }
    }
    let v = await counter.get()
    let s = await ledger.snapshot()
    let t = await ledger.total()
    print("counter:", v)
    print("buckets:", s.sorted { $0.key < $1.key })
    print("total:", t)
}

Task {
    await runActors()
    PlaygroundPage.current.needsIndefiniteExecution = false
}
