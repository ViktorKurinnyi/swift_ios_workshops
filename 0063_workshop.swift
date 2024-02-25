/*
Debounce, Throttle, Buffer — Tame noisy streams with operators.
Simulate typing input and compare operators reacting to bursts.
Observe output timing and dropped elements.
*/

import Foundation
import Combine
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

var cancellables = Set<AnyCancellable>()
let input = PassthroughSubject<String, Never>()

func scheduleTyping(_ pairs: [(String, Double)]) {
    var t: Double = 0
    for (text, gap) in pairs {
        t += gap
        DispatchQueue.main.asyncAfter(deadline: .now() + t) {
            input.send(text)
        }
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + t + 0.1) {
        input.send(completion: .finished)
    }
}

let debounced = input
    .debounce(for: .milliseconds(250), scheduler: DispatchQueue.main)
    .map { "[debounce] \($0)" }
    .eraseToAnyPublisher()

let throttledLatest = input
    .throttle(for: .milliseconds(400), scheduler: DispatchQueue.main, latest: true)
    .map { "[throttle-latest] \($0)" }
    .eraseToAnyPublisher()

let throttledFirst = input
    .throttle(for: .milliseconds(400), scheduler: DispatchQueue.main, latest: false)
    .map { "[throttle-first] \($0)" }
    .eraseToAnyPublisher()

let buffered = input
    .buffer(size: 3, prefetch: .keepFull, whenFull: .dropOldest)
    .map { v in "[buffer 3] \(v)" }
    .eraseToAnyPublisher()

Publishers.MergeMany([debounced, throttledLatest, throttledFirst, buffered])
    .sink(
        receiveCompletion: { c in print("completed: \(c)") },
        receiveValue: { v in print("\(ISO8601DateFormatter().string(from: Date())) \(v)") }
    )
    .store(in: &cancellables)

let script: [(String, Double)] = [
    ("S", 0.0),
    ("Sw", 0.08),
    ("Swi", 0.08),
    ("Swif", 0.08),
    ("Swift", 0.5),
    (" Swift ", 0.15),
    (" Swift P", 0.07),
    (" Swift Pl", 0.07),
    (" Swift Pla", 0.07),
    (" Swift Play", 0.07),
    (" Swift Playg", 0.07),
    (" Swift Playgr", 0.07),
    (" Swift Playgro", 0.07),
    (" Swift Playgrou", 0.07),
    (" Swift Playground", 0.5),
    (" ✓", 0.2)
]

scheduleTyping(script)

DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
    PlaygroundPage.current.needsIndefiniteExecution = false
}
