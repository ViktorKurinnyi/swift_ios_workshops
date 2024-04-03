/*
AnyPublisher & Erasure — Hide pipeline details behind stable types.
Return the same public type from different internal implementations.
Swap strategies without breaking callers.
*/

import Foundation
import Combine
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

var cancellables = Set<Combine.AnyCancellable>()

func strategyA() -> Combine.AnyPublisher<Int, Never> {
    Array(1...5).publisher
        .map { $0 * 2 }
        .eraseToAnyPublisher()
}

func strategyB() -> Combine.AnyPublisher<Int, Never> {
    Timer.publish(every: 0.2, on: .main, in: .common)
        .autoconnect()
        .scan(0) { acc, _ in acc + 1 }
        .prefix(5)
        .eraseToAnyPublisher()
}

func fetchNumbers() -> Combine.AnyPublisher<Int, Never> {
    if Bool.random() {
        return strategyA()
    } else {
        return strategyB()
    }
}

fetchNumbers()
    .map { "value: \($0)" }
    .sink(
        receiveCompletion: { c in
            print("completed: \(c)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                PlaygroundPage.current.needsIndefiniteExecution = false
            }
        },
        receiveValue: { v in print(v) }
    )
    .store(in: &cancellables)
