/*
KeyPaths in Practice — Compose property access, dynamic lookups, and sorting.
Build helpers for sorting by KeyPath and reading/writing via WritableKeyPath.
Show nested paths and grouping by a selected property.
Run with a tiny dataset to transform and summarize.
*/

import Foundation

public struct Address: Hashable {
    public var city: String
    public var zip: Int
}

public struct User: Hashable, CustomStringConvertible {
    public var id: Int
    public var name: String
    public var score: Int
    public var address: Address
    public var description: String { "User(\(id), \(name), \(score), \(address.city))" }
}

public extension Array {
    mutating func sort<T: Comparable>(by keyPath: KeyPath<Element, T>, ascending: Bool = true) {
        sort {
            let lhs = $0[keyPath: keyPath]
            let rhs = $1[keyPath: keyPath]
            return ascending ? lhs < rhs : lhs > rhs
        }
    }
    func map<T>(_ keyPath: KeyPath<Element, T>) -> [T] { map { $0[keyPath: keyPath] } }
}

public extension MutableCollection {
    mutating func write<T>(_ keyPath: WritableKeyPath<Element, T>, transform: (T) -> T) {
        for i in indices { self[i][keyPath: keyPath] = transform(self[i][keyPath: keyPath]) }
    }
}

public func groupBy<T, K: Hashable>(_ items: [T], key: KeyPath<T, K>) -> [K: [T]] {
    var dict: [K: [T]] = [:]
    for i in items { dict[i[keyPath: key]] = (dict[i[keyPath: key]] ?? []) + [i] }
    return dict
}

var people: [User] = [
    .init(id: 1, name: "Ava", score: 88, address: .init(city: "Madrid", zip: 28001)),
    .init(id: 2, name: "Leo", score: 92, address: .init(city: "Valencia", zip: 46001)),
    .init(id: 3, name: "Noah", score: 70, address: .init(city: "Madrid", zip: 28021)),
    .init(id: 4, name: "Mia", score: 92, address: .init(city: "Sevilla", zip: 41001)),
    .init(id: 5, name: "Zoe", score: 77, address: .init(city: "Valencia", zip: 46011))
]

let names = people.map(\User.name)
print("Names:", names)

people.sort(by: \User.score, ascending: false)
print("Top by score:", people.prefix(3))

people.write(\User.score) { min($0 + 5, 100) }
print("Curved scores:", people.map(\User.score))

let cityGroups = groupBy(people, key: \User.address.city)
for (city, users) in cityGroups {
    print("City:", city, "count:", users.count)
}

let nested: KeyPath<User, Int> = \User.address.zip
let zips = people.map(nested)
print("Zips:", zips.sorted())
