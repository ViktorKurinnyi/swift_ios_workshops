/*
Combine Error Paths — Model recoveries with catch and retry.
Compose fallbacks for transient failures and terminal errors.
Inspect how retry resubscribes and how catch replaces failures.
*/

import Foundation
import Combine
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

enum DemoError: Error, CustomStringConvertible {
    case flake
    var description: String { "flake" }
}

func flaky() -> AnyPublisher<Int, DemoError> {
    Deferred {
        Future<Int, DemoError> { promise in
            let n = Int.random(in: 1...10)
            print("attempt with n=\(n)")
            if n < 7 {
                promise(.failure(.flake))
            } else {
                promise(.success(n))
            }
        }
    }
    .eraseToAnyPublisher()
}

var cancellables = Set<AnyCancellable>()

flaky()
    .retry(3)
    .map { "ok \($0)" }
    .catch { _ in Just("fallback -1").setFailureType(to: DemoError.self) }
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
