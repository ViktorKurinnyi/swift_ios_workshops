/*
Detached Tasks
Run work outside structured scopes deliberately.
Understand captured state, priority, and cancellation.
Prefer structured tasks; detach only for fire-and-forget.
*/
import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

@MainActor
final class UIState {
    var messages: [String] = []
    func show(_ s: String) {
        messages.append(s)
        print("ui", s)
    }
}

func hashBytes(_ n: Int) -> String {
    var rng = SystemRandomNumberGenerator()
    var acc: UInt64 = 0
    for _ in 0..<n {
        acc ^= UInt64.random(in: .min...(.max), using: &rng)
    }
    return String(acc, radix: 16)
}

Task { @MainActor in
    let ui = UIState()

    let parent = Task {
        try? await Task.sleep(nanoseconds: 80_000_000)
        ui.show("parent cancel")
        Task.currentPriority
    }

    Task.detached(priority: .background) {
        let h = hashBytes(200_000)
        await ui.show("detached done \(h.prefix(6))")
    }

    Task {
        let h = hashBytes(50_000)
        ui.show("child done \(h.prefix(6))")
    }

    parent.cancel()
    try? await Task.sleep(nanoseconds: 500_000_000)
    PlaygroundPage.current.finishExecution()
}
