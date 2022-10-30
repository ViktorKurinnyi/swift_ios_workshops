/*
Protocols 101
Design behavior contracts and adopt them with extensions.
Use default implementations and retroactive modeling on existing types.
Compose protocols and write generic functions over them.
*/

import Foundation

protocol Summarizable {
    var summary: String { get }
    func present()
}

extension Summarizable {
    func present() { print(summary) }
}

struct Note: Summarizable {
    let title: String
    let body: String
    var summary: String { "\(title): \(body.prefix(20))..." }
}

struct Todo {
    let id: Int
    var text: String
    var done: Bool
}

extension Todo: Summarizable {
    var summary: String { "\(done ? "✔︎" : "◻︎") \(text)" }
}

extension Int: Summarizable {
    var summary: String { "Int(\(self))" }
}

protocol Identified {
    var id: String { get }
}

struct User: Identified, Summarizable {
    let id: String
    let name: String
    var summary: String { "User[\(id)] \(name)" }
}

extension Array where Element: Summarizable {
    func joinedSummaries() -> String {
        map { $0.summary }.joined(separator: " | ")
    }
}

func showAll<T: Summarizable>(_ items: [T]) {
    items.forEach { $0.present() }
}

func showAll(_ items: [any Summarizable]) {
    items.forEach { $0.present() }
}

print("=== Build a few models ===")
let n = Note(title: "Swift", body: "Protocols let you describe capabilities.")
let t = Todo(id: 1, text: "Ship the feature", done: false)
let u = User(id: "abc", name: "Ava")
let ints: [Int] = [1, 2, 3]

print("=== Present summaries ===")
showAll([n, t, u])
showAll(ints)

print("=== Extensions on collections ===")
let bag: [any Summarizable] = [n, t, u]
print(bag.map { $0.summary }.joined(separator: ", "))

print("=== Protocol composition ===")
func tag(_ x: any Summarizable & CustomStringConvertible) {
    print(x.summary, "-", String(describing: x))
}

extension Note: CustomStringConvertible {
    var description: String { "Note<\(title)>" }
}
tag(n)

print("=== Conditional logic over protocols ===")
func firstSummary<T: Collection>(_ c: T) -> String where T.Element: Summarizable {
    c.first?.summary ?? "empty"
}
print(firstSummary([t, t]))
