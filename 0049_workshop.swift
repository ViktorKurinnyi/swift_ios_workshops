/*
MainActor Rules
Keep UI work on the main thread rigorously.
Hop to the main actor when mutating UI state.
Verify thread affinity with prints.
*/

import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

@MainActor
final class ViewModel {
    private(set) var title: String = "Loading…"
    private(set) var items: [String] = []
    func setTitle(_ t: String) { title = t }
    func setItems(_ i: [String]) { items = i }
    func render() {
        print("UI title:", title, "main:", Thread.isMainThread)
        print("UI items:", items.joined(separator: ", "), "main:", Thread.isMainThread)
    }
}

func fetchData() async -> [String] {
    try? await Task.sleep(nanoseconds: 150_000_000)
    return ["alpha", "beta", "gamma", "delta"]
}

func uppercaseOffMain(_ strings: [String]) async -> [String] {
    await withTaskGroup(of: String.self) { group in
        for s in strings { group.addTask { s.uppercased() } }
        var out: [String] = []
        for await x in group { out.append(x) }
        return out.sorted()
    }
}

Task.detached {
    let data = await fetchData()
    let processed = await uppercaseOffMain(data)
    await MainActor.run {
        let vm = ViewModel()
        vm.setTitle("Done")
        vm.setItems(processed)
        vm.render()
        PlaygroundPage.current.needsIndefiniteExecution = false
    }
}
