/*
Share, Multicast, Autoconnect — Reuse upstreams without duplicate work.
Share side effects, manually fan out with multicast, and drive timers with autoconnect.
Observe one upstream feeding many subscribers safely.
*/

import Foundation
import Combine
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

var cancellables = Set<AnyCancellable>()

func expensive() -> AnyPublisher<Int, Never> {
    Deferred {
        Future<Int, Never> { promise in
            print("expensive work started")
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.4) {
                let v = Int.random(in: 100...999)
                print("expensive produced \(v)")
                promise(.success(v))
            }
        }
    }
    .eraseToAnyPublisher()
}

let shared = expensive().share()

shared
    .map { "A got \($0)" }
    .sink(receiveValue: { print($0) })
    .store(in: &cancellables)

shared
    .delay(for: .milliseconds(50), scheduler: DispatchQueue.main)
    .map { "B got \($0)" }
    .sink(receiveValue: { print($0) })
    .store(in: &cancellables)

let bus = PassthroughSubject<Int, Never>()
let multi = bus
    .handleEvents(receiveSubscription: { _ in print("multicast subscribed") })
    .multicast(subject: PassthroughSubject<Int, Never>())

multi
    .map { "M1 -> \($0)" }
    .sink(receiveValue: { print($0) })
    .store(in: &cancellables)

multi
    .map { "M2 -> \($0)" }
    .sink(receiveValue: { print($0) })
    .store(in: &cancellables)

let connection = multi.connect()

DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { bus.send(1) }
DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { bus.send(2) }
DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { bus.send(3) }
DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { bus.send(completion: .finished) }
DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) { connection.cancel() }

let tick = Timer.publish(every: 0.25, on: .main, in: .common).autoconnect()
tick
    .scan(0) { acc, _ in acc + 1 }
    .prefix(5)
    .map { "autoconnect tick \($0)" }
    .sink(
        receiveCompletion: { _ in print("autoconnect done") },
        receiveValue: { print($0) }
    )
    .store(in: &cancellables)

DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
    PlaygroundPage.current.needsIndefiniteExecution = false
}
