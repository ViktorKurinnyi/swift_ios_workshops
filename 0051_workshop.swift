/*
AsyncStream & Continuations
Bridge callback APIs into async sequences and single values.
Use AsyncStream for streams; use continuations for one-shot results.
All runnable in a Playground without extra assets.
*/
import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

final class Ticker {
    private let queue = DispatchQueue(label: "ticker")
    private var timer: DispatchSourceTimer?
    private var count = 0
    var onTick: ((Int) -> Void)?
    func start(every seconds: TimeInterval) {
        let t = DispatchSource.makeTimerSource(queue: queue)
        t.schedule(deadline: .now(), repeating: seconds)
        t.setEventHandler { [weak self] in
            guard let self else { return }
            self.count += 1
            self.onTick?(self.count)
        }
        t.resume()
        timer = t
    }
    func stop() {
        timer?.cancel()
        timer = nil
    }
}

func tickStream(every seconds: TimeInterval) -> AsyncStream<Int> {
    AsyncStream(Int.self) { continuation in
        let ticker = Ticker()
        ticker.onTick = { value in
            continuation.yield(value)
        }
        continuation.onTermination = { @Sendable _ in
            ticker.stop()
        }
        ticker.start(every: seconds)
    }
}

func nextTick() async -> Int {
    await withCheckedContinuation { continuation in
        let ticker = Ticker()
        ticker.onTick = { value in
            continuation.resume(returning: value)
            ticker.stop()
        }
        ticker.start(every: 0.05)
    }
}

Task {
    var got = [Int]()
    let limit = 5
    for await n in tickStream(every: 0.1) {
        got.append(n)
        print("stream tick", n)
        if got.count == limit { break }
    }
    let single = await nextTick()
    print("one-shot", single)
    PlaygroundPage.current.finishExecution()
}
