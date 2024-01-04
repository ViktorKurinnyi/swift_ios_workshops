/*
Reentrancy & Actors
See how awaits inside actor methods allow interleaving.
Trigger out-of-order effects, then fix with internal queueing.
Maintain ordering without blocking threads.
*/
import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

actor Mailbox {
    private var items: [String] = []
    private var processing = false
    func enqueueReentrant(_ msg: String) async {
        items.append(msg)
        try? await Task.sleep(nanoseconds: 60_000_000)
        print("reentrant processed", msg)
    }
    func enqueueOrdered(_ msg: String) async {
        items.append(msg)
        if processing { return }
        processing = true
        while !items.isEmpty {
            let next = items.removeFirst()
            await process(next)
        }
        processing = false
    }
    private func process(_ msg: String) async {
        await Task.yield()
        try? await Task.sleep(nanoseconds: 40_000_000)
        print("ordered processed", msg)
    }
}

let box = Mailbox()

Task {
    await withTaskGroup(of: Void.self) { g in
        g.addTask { await box.enqueueReentrant("A") }
        g.addTask { await box.enqueueReentrant("B") }
    }
    try? await Task.sleep(nanoseconds: 200_000_000)
    await withTaskGroup(of: Void.self) { g in
        g.addTask { await box.enqueueOrdered("1") }
        g.addTask { await box.enqueueOrdered("2") }
        g.addTask { await box.enqueueOrdered("3") }
    }
    try? await Task.sleep(nanoseconds: 300_000_000)
    PlaygroundPage.current.finishExecution()
}
