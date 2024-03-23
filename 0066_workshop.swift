/*
Backpressure & Demand — Implement a custom Subscriber to observe demand.
Control how many values flow and adjust demand dynamically.
See synchronous publishers honor requested demand.
*/

import Foundation
import Combine
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

final class DemandProbe: Subscriber {
    typealias Input = Int
    typealias Failure = Never

    private var subscription: Subscription?
    private var processed = 0

    func receive(subscription: Subscription) {
        self.subscription = subscription
        print("receive(subscription)")
        subscription.request(.max(3))
    }

    func receive(_ input: Int) -> Subscribers.Demand {
        processed += 1
        print("receive value \(input) [processed=\(processed)]")
        if processed % 2 == 0 {
            print("requesting +2")
            return .max(2)
        } else {
            return .none
        }
    }

    func receive(completion: Subscribers.Completion<Never>) {
        print("receive(completion: \(completion))")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            PlaygroundPage.current.needsIndefiniteExecution = false
        }
    }
}

let probe = DemandProbe()

let numbers = (1...20).publisher
    .handleEvents(receiveSubscription: { _ in print("sequence subscribed") },
                  receiveOutput: nil,
                  receiveCompletion: nil,
                  receiveCancel: { print("publisher canceled") },
                  receiveRequest: { d in print("publisher saw request: \(d)") })

numbers.subscribe(probe)
