/*
Testing Concurrency
Inject time via protocols for determinism.
Avoid real sleeps; assert sequencing and effects.
Run a tiny spec against async code.
*/
import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

protocol Sleeper {
    func pause(milliseconds: Int) async
}

struct RealSleeper: Sleeper {
    func pause(milliseconds: Int) async {
        try? await Task.sleep(nanoseconds: UInt64(milliseconds) * 1_000_000)
    }
}

final class FakeSleeper: Sleeper {
    var calls: [Int] = []
    func pause(milliseconds: Int) async {
        calls.append(milliseconds)
    }
}

struct Throttler<S: Sleeper> {
    var minGapMs: Int
    var sleeper: S
    private var last: Date? = nil
    init(minGapMs: Int, sleeper: S) { self.minGapMs = minGapMs; self.sleeper = sleeper }
    mutating func run<T>(_ op: @escaping () async -> T) async -> T {
        let now = Date()
        if let last, now.timeIntervalSince(last) * 1000 < Double(minGapMs) {
            await sleeper.pause(milliseconds: minGapMs)
        }
        self.last = Date()
        return await op()
    }
}

Task {
    var fake = FakeSleeper()
    var thr = Throttler(minGapMs: 100, sleeper: fake)
    let a = await thr.run { "A" }
    try? await Task.sleep(nanoseconds: 10_000_000)
    let b = await thr.run { "B" }
    let c = await thr.run { "C" }
    let ok1 = (a, b, c) == ("A", "B", "C")
    let ok2 = fake.calls == [100, 100]
    print("results", ok1, ok2, fake.calls)
    var real = Throttler(minGapMs: 50, sleeper: RealSleeper())
    let t0 = Date()
    _ = await real.run { 1 }
    _ = await real.run { 2 }
    let elapsed = Date().timeIntervalSince(t0)
    print("elapsed >= 0.05", elapsed >= 0.05)
    PlaygroundPage.current.finishExecution()
}
