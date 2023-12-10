/*
Structured vs Unstructured Concurrency
Use task groups for scoped lifetime and cancellation.
Contrast with detached tasks that outlive parents.
Observe propagation, ordering, and cancellation.
*/
import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

func work(_ id: Int, delay: UInt64) async -> String {
    try? await Task.sleep(nanoseconds: delay)
    return "work \(id) done on \(Thread.isMainThread ? "main" : "bg")"
}

func structuredDemo() async {
    print("structured begin")
    let start = Date()
    let result = await withTaskGroup(of: String.self) { group in
        for i in 1...5 {
            group.addTask {
                await work(i, delay: UInt64(100_000_000 * i))
            }
        }
        var out = [String]()
        for await s in group {
            out.append(s)
            if out.count == 3 {
                group.cancelAll()
            }
        }
        return out
    }
    let elapsed = Date().timeIntervalSince(start)
    print("structured results", result)
    print("structured elapsed", String(format: "%.2f", elapsed))
}

func unstructuredDemo() async {
    print("unstructured begin")
    var keepRunning = true
    let lock = NSLock()
    var out = [String]()
    let parent = Task {
        try? await Task.sleep(nanoseconds: 150_000_000)
        keepRunning = false
    }
    for i in 1...5 {
        Task.detached(priority: .background) {
            let s = await work(100 + i, delay: UInt64(120_000_000 * i))
            lock.lock(); out.append(s); lock.unlock()
            print("detached finished", i)
        }
    }
    try? await Task.sleep(nanoseconds: 200_000_000)
    parent.cancel()
    var waited = 0
    while waited < 10 {
        try? await Task.sleep(nanoseconds: 50_000_000)
        waited += 1
        if !keepRunning { break }
    }
    print("unstructured still collecting")
    try? await Task.sleep(nanoseconds: 800_000_000)
    print("unstructured collected", out.count)
}

Task {
    await structuredDemo()
    await unstructuredDemo()
    PlaygroundPage.current.finishExecution()
}
