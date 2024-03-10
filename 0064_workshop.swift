/*
FlatMap & SwitchToLatest — Compose dependent async pipelines.
Model requests that complete out of order and switch to the newest.
Compare concurrent flatMap with canceling switchToLatest.
*/

import Foundation
import Combine
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

var cancellables = Set<AnyCancellable>()
let queries = PassthroughSubject<String, Never>()

func request(_ q: String) -> AnyPublisher<String, Never> {
    let delay = Double.random(in: 0.05...0.7)
    return Deferred {
        Future<String, Never> { promise in
            print("start request for \(q) (\(String(format: "%.2f", delay))s)")
            DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
                let text = "result[\(q)]"
                promise(.success(text))
            }
        }
    }
    .receive(on: DispatchQueue.main)
    .eraseToAnyPublisher()
}

queries
    .flatMap(maxPublishers: .max(2)) { q in request(q) }
    .map { "flatMap -> \($0)" }
    .sink(
        receiveCompletion: { c in print("flatMap completed: \(c)") },
        receiveValue: { v in print("\(ISO8601DateFormatter().string(from: Date())) \(v)") }
    )
    .store(in: &cancellables)

queries
    .map { request($0) }
    .switchToLatest()
    .map { "switchToLatest -> \($0)" }
    .sink(
        receiveCompletion: { c in print("switchToLatest completed: \(c)") },
        receiveValue: { v in print("\(ISO8601DateFormatter().string(from: Date())) \(v)") }
    )
    .store(in: &cancellables)

let inputs = [
    ("q1", 0.0),
    ("q2", 0.15),
    ("q3", 0.1),
    ("q4", 0.2),
    ("q5", 0.25)
]

for (q, d) in inputs {
    DispatchQueue.main.asyncAfter(deadline: .now() + d) { queries.send(q) }
}

DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
    queries.send(completion: .finished)
}

DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
    PlaygroundPage.current.needsIndefiniteExecution = false
}
