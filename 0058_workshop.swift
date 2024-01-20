/*
Global vs Local Actors
Model shared domains with global actors.
Use local actors for fine-grained isolation.
Hop between them explicitly with awaits.
*/
import Foundation
import PlaygroundSupport

@globalActor
struct AppDataActor {
    static let shared = DataCenter()
}

actor DataCenter {
    private var store: [String: Int] = [:]
    func set(_ key: String, _ value: Int) { store[key] = value }
    func get(_ key: String) -> Int? { store[key] }
}

@AppDataActor
struct Repository {
    static func increment(_ key: String) async {
        await AppDataActor.shared.set(key, (await AppDataActor.shared.get(key) ?? 0) + 1)
    }
    static func value(_ key: String) async -> Int {
        await AppDataActor.shared.get(key) ?? 0
    }
}

actor ViewModel {
    private(set) var last: Int = 0
    func tap() async {
        await Repository.increment("taps")
        last = await Repository.value("taps")
    }
    func read() -> Int { last }
}

PlaygroundPage.current.needsIndefiniteExecution = true

let vm = ViewModel()
Task {
    await withTaskGroup(of: Void.self) { g in
        for _ in 0..<5 { g.addTask { await vm.tap() } }
    }
    let visible = await vm.read()
    print("local view", visible)
    let shared = await AppDataActor.shared.get("taps") ?? -1
    print("global store", shared)
    PlaygroundPage.current.finishExecution()
}
