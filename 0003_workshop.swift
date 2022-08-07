/*
Enums With Associated Values
Encode a small request state machine with data-rich cases.
Drive transitions via exhaustive switches for clarity and safety.
Observe how the reducer evolves state deterministically.
*/

import Foundation

enum RequestState {
    case idle
    case loading(id: UUID, started: Date)
    case success(body: String, code: Int)
    case failure(message: String)
}

enum Event {
    case start
    case response(body: String, code: Int)
    case error(message: String)
    case reset
}

func reduce(_ state: RequestState, _ event: Event) -> RequestState {
    switch (state, event) {
    case (.idle, .start):
        return .loading(id: UUID(), started: Date())

    case (.loading, .response(let body, let code)):
        return .success(body: body, code: code)
    case (.loading, .error(let message)):
        return .failure(message: message)
    case (.loading, .reset):
        return .idle

    case (.success, .reset), (.failure, .reset), (.idle, .reset):
        return .idle

    case (.success, .start), (.failure, .start):
        return state

    case (.success, .response), (.success, .error),
         (.failure, .response), (.failure, .error),
         (.idle, .response), (.idle, .error),
         (.loading, .start):
        return state
    }
}

func render(_ state: RequestState) {
    switch state {
    case .idle:
        print("Idle")
    case .loading(let id, let started):
        print("Loading id:", id, "started:", started.timeIntervalSince1970)
    case .success(let body, let code):
        print("Success code:", code, "len:", body.count)
    case .failure(let message):
        print("Failure:", message)
    }
}

print("=== Run ===")
var state: RequestState = .idle
render(state)

let script: [Event] = [
    .start,
    .response(body: "{\"ok\":true}", code: 200),
    .reset,
    .start,
    .error(message: "Timeout"),
    .reset
]

for e in script {
    state = reduce(state, e)
    render(state)
}

print("=== Pattern matching payloads ===")
state = .success(body: "Hello, world!", code: 201)
switch state {
case .success(let body, 200...299):
    print("2xx:", body)
case .success(_, let code):
    print("Non-2xx:", code)
default:
    print("Not success")
}

print("=== Ensure exhaustiveness ===")
let terminal: Bool = {
    switch state {
    case .idle: return false
    case .loading: return false
    case .success: return true
    case .failure: return true
    }
}()
print("Terminal:", terminal)
