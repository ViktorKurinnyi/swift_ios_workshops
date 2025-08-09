/*
Data Flow Architecture — Unidirectional patterns without heavy frameworks.
Define State, Action, Reducer, Store, and Effects in one file.
Observe state changes and fire simple side effects deterministically.
Use small pure reducers and explicit dependencies.
*/
import Foundation

struct AppState: Equatable {
    var count: Int = 0
    var todos: [String] = []
    var isLoading: Bool = false
}

enum Action {
    case increment
    case addTodo(String)
    case loadData
    case dataLoaded([String])
}

struct Effect {
    let run: (Store) -> Void
    static func none() -> [Effect] { [] }
}

final class Store {
    private(set) var state: AppState
    private let reducer: (inout AppState, Action) -> [Effect]
    private var subscribers: [(AppState) -> Void] = []
    init(initial: AppState, reducer: @escaping (inout AppState, Action) -> [Effect]) {
        self.state = initial
        self.reducer = reducer
    }
    func send(_ action: Action) {
        let effects = reducer(&state, action)
        subscribers.forEach { $0(state) }
        effects.forEach { $0.run(self) }
    }
    func subscribe(_ f: @escaping (AppState) -> Void) {
        subscribers.append(f)
        f(state)
    }
}

func appReducer(state: inout AppState, action: Action) -> [Effect] {
    switch action {
    case .increment:
        state.count += 1
        return Effect.none()
    case .addTodo(let t):
        state.todos.append(t)
        return Effect.none()
    case .loadData:
        state.isLoading = true
        return [Effect { store in
            let data = ["Alpha", "Beta", "Gamma"]
            store.send(.dataLoaded(data))
        }]
    case .dataLoaded(let items):
        state.isLoading = false
        state.todos.append(contentsOf: items)
        return Effect.none()
    }
}

let store = Store(initial: AppState(), reducer: appReducer)
store.subscribe { s in
    print("count=\(s.count), loading=\(s.isLoading), todos=\(s.todos)")
}
store.send(.increment)
store.send(.addTodo("Write unit tests"))
store.send(.loadData)
