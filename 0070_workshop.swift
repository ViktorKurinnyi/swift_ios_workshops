/*
Timers & RunLoops — Drive time-based pipelines in playgrounds.
Use Timer.publish and .autoconnect to tick without manual connect.
Coordinate with RunLoop to keep work alive and finish deterministically.
*/

import Foundation
import Combine
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

var cancellables = Set<AnyCancellable>()

let formatter: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "HH:mm:ss.SSS"
    return f
}()

let ticker = Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()

ticker
    .map { _ in formatter.string(from: Date()) }
    .map { "tick \($0)" }
    .prefix(8)
    .sink(
        receiveCompletion: { _ in print("ticks done") },
        receiveValue: { print($0) }
    )
    .store(in: &cancellables)

let fire = Timer.scheduledTimer(withTimeInterval: 0.33, repeats: true) { _ in
    print("runloop pulse \(formatter.string(from: Date()))")
}
DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) {
    fire.invalidate()
    print("runloop timer stopped")
}

DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
    PlaygroundPage.current.needsIndefiniteExecution = false
}
