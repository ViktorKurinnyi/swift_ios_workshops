/*
App Intents Primer — Expose actions to Shortcuts with simple models.
Model inputs and outputs, register intents, and invoke them by name.
Store lightweight data in memory to keep examples portable.
Demonstrates JSON-friendly results for automation tooling.
*/
import Foundation

struct Todo: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var done: Bool
}

final class TodoStore {
    private var items: [UUID: Todo] = [:]
    func add(_ title: String) -> Todo {
        let t = Todo(id: UUID(), title: title, done: false)
        items[t.id] = t
        return t
    }
    func complete(_ id: UUID) -> Todo? {
        guard var t = items[id] else { return nil }
        t.done = true
        items[id] = t
        return t
    }
    func all() -> [Todo] {
        items.values.sorted { $0.title < $1.title }
    }
}

protocol Intent {
    associatedtype Output: Encodable
    var name: String { get }
    func run() throws -> Output
}

struct AddTodoIntent: Intent {
    var store: TodoStore
    let title: String
    var name: String { "AddTodo" }
    func run() throws -> Todo { store.add(title) }
}

struct CompleteTodoIntent: Intent {
    var store: TodoStore
    let id: UUID
    var name: String { "CompleteTodo" }
    func run() throws -> Todo { 
        guard let t = store.complete(id) else { throw NSError(domain: "Intent", code: 404) }
        return t
    }
}

struct ListTodosIntent: Intent {
    var store: TodoStore
    var name: String { "ListTodos" }
    func run() throws -> [Todo] { store.all() }
}

final class IntentRegistry {
    typealias Handler = ([String: String]) throws -> Encodable
    private var handlers: [String: Handler] = [:]
    func register<T: Intent>(_ intent: T, factory: @escaping ([String: String]) throws -> T) {
        handlers[intent.name] = { args in
            let built = try factory(args)
            return try built.run()
        }
    }
    func run(_ name: String, args: [String: String] = [:]) throws -> String {
        guard let h = handlers[name] else { throw NSError(domain: "Intent", code: 400) }
        let enc = JSONEncoder()
        enc.outputFormatting = [.prettyPrinted, .sortedKeys]
        let value = try h(args)
        let data = try enc.encode(AnyEncodable(value))
        return String(data: data, encoding: .utf8)!
    }
}

struct AnyEncodable: Encodable {
    let value: Encodable
    init(_ value: Encodable) { self.value = value }
    func encode(to encoder: Encoder) throws {
        try value.encode(to: encoder)
    }
}

let store = TodoStore()
let registry = IntentRegistry()
registry.register(AddTodoIntent(store: store, title: "")) { args in
    AddTodoIntent(store: store, title: args["title"] ?? "Untitled")
}
registry.register(CompleteTodoIntent(store: store, id: UUID())) { args in
    let id = UUID(uuidString: args["id"] ?? "") ?? UUID()
    return CompleteTodoIntent(store: store, id: id)
}
registry.register(ListTodosIntent(store: store)) { _ in
    ListTodosIntent(store: store)
}

let r1 = try registry.run("AddTodo", args: ["title": "Buy milk"])
let r2 = try registry.run("AddTodo", args: ["title": "Read book"])
let list = try registry.run("ListTodos")
let firstId = store.all().first!.id
let done = try registry.run("CompleteTodo", args: ["id": firstId.uuidString])
let list2 = try registry.run("ListTodos")
print(r1); print(r2); print(list); print(done); print(list2)
