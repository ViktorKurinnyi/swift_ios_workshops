/*
Combine ↔ async/await — Bridge with AsyncPublisher and values.
Consume publishers with for-await and wrap async work as publishers.
Move data between worlds cleanly.
*/

import Foundation
import Combine
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

var cancellables = Set<AnyCancellable>()

func asyncWork(_ x: Int) async -> String {
    try? await Task.sleep(nanoseconds: UInt64(150_000_000 + (x % 3) * 80_000_000))
    return "async(\(x))"
}

func publisherFromAsync(_ x: Int) -> AnyPublisher<String, Never> {
    Deferred {
        Future<String, Never> { promise in
            Task.detached {
                let v = await asyncWork(x)
                promise(.success(v))
            }
        }
    }
    .eraseToAnyPublisher()
}

Array(1...6).publisher
    .flatMap { i in publisherFromAsync(i) }
    .map { "pub<-async: \($0)" }
    .sink(
        receiveCompletion: { c in print("bridge A completed: \(c)") },
        receiveValue: { v in print(v) }
    )
    .store(in: &cancellables)

let ticker = Timer.publish(every: 0.18, on: .main, in: .common).autoconnect()
let task = Task {
    var count = 0
    for await _ in ticker.values {
        count += 1
        print("async<-pub tick \(count)")
        if count == 5 { break }
    }
    print("async<-pub done")
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
        PlaygroundPage.current.needsIndefiniteExecution = false
    }
}
_ = task
