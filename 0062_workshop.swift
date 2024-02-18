/*
Subjects & Passthrough — Broadcast events and manage completion.
Build a simple bus with multiple subscribers listening to the same stream.
See how values stop after a terminal completion.
*/

import Foundation
import Combine
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

var cancellables = Set<AnyCancellable>()

let bus = PassthroughSubject<String, Never>()

func now() -> String {
    ISO8601DateFormatter().string(from: Date())
}

func emitSequence() {
    let items = [
        ("hello", 0.0),
        ("world", 0.15),
        ("from", 0.3),
        ("subjects", 0.45),
        ("!", 0.6)
    ]
    for (text, delay) in items {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { bus.send(text) }
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
        bus.send(completion: .finished)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { bus.send("late") }
    }
}

bus
    .map { "[A @\(now())] \($0.uppercased())" }
    .sink(
        receiveCompletion: { c in print("A completed: \(c)") },
        receiveValue: { v in print(v) }
    )
    .store(in: &cancellables)

bus
    .scan([]) { acc, next in acc + [next] }
    .map { arr in "[B @\(now())] \(arr.joined(separator: " "))" }
    .sink(
        receiveCompletion: { c in print("B completed: \(c)") },
        receiveValue: { v in print(v) }
    )
    .store(in: &cancellables)

bus
    .map { "[C len=\($0.count)] \($0)" }
    .sink(
        receiveCompletion: { c in print("C completed: \(c)") },
        receiveValue: { v in print(v) }
    )
    .store(in: &cancellables)

emitSequence()

DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
    let lateSink = bus
        .sink(
            receiveCompletion: { c in print("Late completed: \(c)") },
            receiveValue: { v in print("Late saw: \(v)") }
        )
    lateSink.store(in: &cancellables)
}

DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
    PlaygroundPage.current.needsIndefiniteExecution = false
}
