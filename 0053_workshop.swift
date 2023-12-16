/*
Clock & Sleep
Use Swift Clock APIs for precise, testable timing.
Avoid DispatchQueue; prefer ContinuousClock and Duration.
Measure intervals and schedule wakes deterministically.
*/
import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

func pretty(_ d: Duration) -> String {
    let comps = d.components
    let seconds = Double(comps.seconds)
    let attoseconds = Double(comps.attoseconds)
    let ms = (seconds + attoseconds / 1e18) * 1000.0
    return String(format: "%.1fms", ms)
}

func demoSleep() async {
    let clock = ContinuousClock()
    let start = clock.now
    try? await clock.sleep(for: .milliseconds(180))
    let mid = clock.now
    try? await clock.sleep(until: mid.advanced(by: .milliseconds(70)))
    let end = clock.now
    print("first", pretty(mid - start))
    print("second", pretty(end - mid))
    print("total", pretty(end - start))
}

func demoTimeoutAtInstant() async {
    let clock = ContinuousClock()
    let target = clock.now.advanced(by: .milliseconds(120))
    try? await clock.sleep(until: target)
    let now = clock.now
    print("woke at", pretty(now - target))
}

Task {
    await demoSleep()
    await demoTimeoutAtInstant()
    PlaygroundPage.current.finishExecution()
}
