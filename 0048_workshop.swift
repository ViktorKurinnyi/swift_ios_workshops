/*
Sendable & Isolation
Make types concurrency-safe and audit crossings.
Use @unchecked Sendable for a locked class.
Pass data safely between tasks and actors.
*/

import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

struct Settings: Sendable, Hashable {
    var theme: String
    var notificationsEnabled: Bool
    var refreshInterval: TimeInterval
}

final class SafeLogger: @unchecked Sendable {
    private let lock = NSLock()
    private var lines: [String] = []
    func log(_ s: String) {
        lock.lock(); lines.append(s); lock.unlock()
    }
    func dump() -> [String] {
        lock.lock(); defer { lock.unlock() }
        return lines
    }
}

actor SettingsStore {
    private var current: Settings
    init(_ initial: Settings) { self.current = initial }
    func update(_ transform: (Settings) -> Settings) {
        current = transform(current)
    }
    func get() -> Settings { current }
}

func simulate(store: SettingsStore, logger: SafeLogger) async {
    await withTaskGroup(of: Void.self) { group in
        for i in 0..<8 {
            group.addTask {
                let tag = "t\(i)"
                let s = await store.get()
                logger.log("\(tag): read \(s.theme)")
                await store.update { old in
                    var next = old
                    next.refreshInterval += 0.1
                    next.theme = ["Light", "Dark", "System"][i % 3]
                    return next
                }
                let after = await store.get()
                logger.log("\(tag): wrote \(after.theme) \(after.refreshInterval)")
            }
        }
    }
}

let store = SettingsStore(.init(theme: "Light", notificationsEnabled: true, refreshInterval: 0.5))
let logger = SafeLogger()

Task {
    await simulate(store: store, logger: logger)
    let final = await store.get()
    print("final:", final)
    for line in logger.dump() { print(line) }
    PlaygroundPage.current.needsIndefiniteExecution = false
}
