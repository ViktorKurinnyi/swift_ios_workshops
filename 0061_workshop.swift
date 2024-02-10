/*
Combine Schedulers — Control where work runs and hops threads.
Learn subscribe(on:) vs receive(on:) and mixing queues with RunLoop.
Watch thread hops in a live stream in a Playground.
*/

import Foundation
import Combine
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

var cancellables = Set<AnyCancellable>()

let bg = DispatchQueue(label: "workshop.bg", qos: .userInitiated)
let hop1 = DispatchQueue(label: "workshop.hop1", qos: .utility)
let upstream = PassthroughSubject<Int, Never>()

func tag(_ message: String) -> String {
    let tid = pthread_mach_thread_np(pthread_self())
    let name = Thread.isMainThread ? "main" : "off"
    let time = ISO8601DateFormatter().string(from: Date())
    return "[\(time)][\(name)#\(tid)] \(message)"
}

DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
    (1...5).forEach { i in
        bg.asyncAfter(deadline: .now() + .milliseconds(150 * i)) {
            upstream.send(i)
            if i == 5 { upstream.send(completion: .finished) }
        }
    }
}

upstream
    .handleEvents(receiveSubscription: { _ in print(tag("subscribed to upstream")) })
    .map { $0 * $0 }
    .subscribe(on: bg)
    .map { "square=\($0)" }
    .receive(on: DispatchQueue.main)
    .map { tag("receive(on: main) \($0)") }
    .receive(on: RunLoop.main)
    .map { $0 + "" }
    .receive(on: hop1)
    .map { tag("hop1 -> \($0)") }
    .receive(on: DispatchQueue.main)
    .sink(
        receiveCompletion: { c in
            print(tag("pipeline completed: \(c)"))
        },
        receiveValue: { v in
            print(v)
        }
    )
    .store(in: &cancellables)

let arrayPub = Array(1...5).publisher
    .handleEvents(receiveSubscription: { _ in print(tag("array subscribed")) })

arrayPub
    .subscribe(on: bg)
    .map { $0 * 10 }
    .receive(on: DispatchQueue.main)
    .sink(
        receiveCompletion: { c in
            print(tag("array pipeline completed: \(c)"))
        },
        receiveValue: { v in
            print(tag("array value \(v)"))
        }
    )
    .store(in: &cancellables)

DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
    print(tag("done"))
    PlaygroundPage.current.needsIndefiniteExecution = false
}
