/*
Hashable & Identifiable — Ensure stable identities for diffing and sets.
Model identity separate from value so changes don’t break lookups.
Build a tiny diff over arrays keyed by stable ids.
*/

import Foundation

struct User: Identifiable, Hashable {
    let id: UUID
    var name: String
    var score: Int

    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension User {
    func contentEquals(_ other: User) -> Bool {
        name == other.name && score == other.score
    }
}

enum Change: CustomStringConvertible {
    case inserted(User)
    case removed(User)
    case updated(id: UUID, old: User, new: User)

    var description: String {
        switch self {
        case .inserted(let u):
            return "➕ inserted \(u.name) \(u.score)"
        case .removed(let u):
            return "➖ removed \(u.name) \(u.score)"
        case .updated(_, let old, let new):
            return "✏️ updated \(old.name)→\(new.name) \(old.score)→\(new.score)"
        }
    }
}

func diff(old: [User], new: [User]) -> [Change] {
    let oldByID = Dictionary(uniqueKeysWithValues: old.map { ($0.id, $0) })
    let newByID = Dictionary(uniqueKeysWithValues: new.map { ($0.id, $0) })
    let oldIDs = Set(oldByID.keys)
    let newIDs = Set(newByID.keys)

    var changes: [Change] = []
    let removed = oldIDs.subtracting(newIDs)
    let inserted = newIDs.subtracting(oldIDs)
    let shared = oldIDs.intersection(newIDs)

    for id in removed {
        if let u = oldByID[id] { changes.append(.removed(u)) }
    }
    for id in inserted {
        if let u = newByID[id] { changes.append(.inserted(u)) }
    }
    for id in shared {
        if let o = oldByID[id], let n = newByID[id], !o.contentEquals(n) {
            changes.append(.updated(id: id, old: o, new: n))
        }
    }
    return changes
}

struct StableSet<Element: Identifiable & Hashable> {
    private var storage: [Element.ID: Element] = [:]

    var count: Int { storage.count }
    var ids: Set<Element.ID> { Set(storage.keys) }
    var elements: [Element] { Array(storage.values) }

    mutating func insert(_ element: Element) {
        storage[element.id] = element
    }

    mutating func update(_ element: Element) {
        storage[element.id] = element
    }

    mutating func remove(id: Element.ID) {
        storage.removeValue(forKey: id)
    }

    func contains(id: Element.ID) -> Bool {
        storage[id] != nil
    }

    subscript(id id: Element.ID) -> Element? {
        storage[id]
    }
}

func demo() {
    let a = User(id: UUID(), name: "Ada", score: 90)
    let b = User(id: UUID(), name: "Byron", score: 40)
    let c = User(id: UUID(), name: "Curie", score: 75)

    var before = [a, b, c]

    var after = before
    if let idx = after.firstIndex(where: { $0.id == b.id }) {
        after[idx].name = "Lord Byron"
        after[idx].score = 55
    }
    after.removeAll { $0.id == c.id }
    after.append(User(id: UUID(), name: "Dijkstra", score: 99))

    let changes = diff(old: before, new: after)
    print("diff count:", changes.count)
    changes.forEach { print($0) }

    var set = StableSet<User>()
    before.forEach { set.insert($0) }
    print("contains Ada id:", set.contains(id: a.id))

    var updatedAda = a
    updatedAda.score = 97
    set.update(updatedAda)
    print("ada score before:", before.first(where: { $0.id == a.id })!.score)
    print("ada score in set:", set[id: a.id]!.score)

    let uniqueIDs = Set(before.map(\.id) + after.map(\.id))
    print("unique ids across snapshots:", uniqueIDs.count)
}

demo()
