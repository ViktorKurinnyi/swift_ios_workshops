/*
Async/Await Fundamentals
Convert callback-based APIs into async functions.
Use continuations safely and propagate errors.
Run a tiny pipeline that reads cleanly.
*/

import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

enum LegacyError: Error { case boom }

func legacyFetchNumber(_ input: Int, completion: @escaping (Result<Int, Error>) -> Void) {
    DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
        if input < 0 { completion(.failure(LegacyError.boom)); return }
        completion(.success(input * 2))
    }
}

func legacyFetchString(_ number: Int, completion: @escaping (Result<String, Error>) -> Void) {
    DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
        completion(.success("value=\(number)"))
    }
}

func fetchNumber(_ input: Int) async throws -> Int {
    try await withCheckedThrowingContinuation { cont in
        legacyFetchNumber(input) { result in
            switch result {
            case .success(let value): cont.resume(returning: value)
            case .failure(let error): cont.resume(throwing: error)
            }
        }
    }
}

func fetchString(_ number: Int) async throws -> String {
    try await withCheckedThrowingContinuation { cont in
        legacyFetchString(number) { result in
            switch result {
            case .success(let value): cont.resume(returning: value)
            case .failure(let error): cont.resume(throwing: error)
            }
        }
    }
}

func pipeline(_ input: Int) async throws -> String {
    let doubled = try await fetchNumber(input)
    let text = try await fetchString(doubled)
    return text.uppercased()
}

Task {
    do {
        let ok = try await pipeline(21)
        print("OK:", ok)
        _ = try await pipeline(-1)
    } catch {
        print("Error:", error)
    }
    PlaygroundPage.current.needsIndefiniteExecution = false
}
