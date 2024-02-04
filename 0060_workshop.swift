/*
Combine: Hello Publisher
Create publishers, transform values, and sink outputs.
Chain map/filter/scan and manage AnyCancellable lifetimes.
Run a simple pipeline that completes in Playground.
*/
import Foundation
import Combine
import PlaygroundSupport

func pipeline() {
    var cancellables = Set<AnyCancellable>()
    let numbers = (1...7).publisher
    let subject = PassthroughSubject<Int, Never>()
    let merged = numbers.merge(with: subject)
        .map { $0 * 2 }
        .filter { $0 % 3 != 0 }
        .scan([]) { acc, v in
            var x = acc
            x.append(v)
            return x
        }
        .eraseToAnyPublisher()
    merged.sink { completion in
        print("done", completion)
        PlaygroundPage.current.finishExecution()
    } receiveValue: { values in
        print("values", values)
    }.store(in: &cancellables)
    subject.send(100)
    subject.send(101)
    subject.send(completion: .finished)
}

Task {
    PlaygroundPage.current.needsIndefiniteExecution = true
    pipeline()
}
