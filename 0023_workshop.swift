/*
Collections Algorithms — Master map, flatMap, compactMap, reduce, and friends.
Transform, filter, flatten, and fold real data into insights.
Use reduce(into:) for performance, Dictionary(grouping:) for buckets, and chaining.
Everything prints so you can see each step in a Playground.
*/
import Foundation

func section(_ title: String) { print("\n=== \(title) ===") }

struct Tx {
    let id: Int
    let user: String
    let amount: Double
    let tags: [String]?
}
let txs: [Tx] = [
    .init(id: 1, user: "ana", amount: 19.99, tags: ["food", "market"]),
    .init(id: 2, user: "luis", amount: 120.00, tags: ["electronics"]),
    .init(id: 3, user: "marta", amount: 7.50, tags: nil),
    .init(id: 4, user: "ana", amount: 4.20, tags: ["coffee"]),
    .init(id: 5, user: "luis", amount: 12.00, tags: ["food", "lunch"]),
    .init(id: 6, user: "ana", amount: 48.00, tags: ["books"]),
]

section("map / compactMap / flatMap")
let userUpper = txs.map(\.user).map { $0.uppercased() }
print("users upper:", userUpper)
let maybeCoupons: [String?] = ["CODE10", nil, "VIP", "", nil, "SAVE5"]
let coupons = maybeCoupons.compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
print("valid coupons:", coupons)
let allTags = txs.compactMap(\.tags).flatMap { $0 }
print("tags:", allTags)

section("reduce: sums and products")
let total = txs.map(\.amount).reduce(0, +)
print("total amount:", total)
let product = [2,3,4].reduce(1, *)
print("product 2*3*4:", product)

section("reduce(into:) for grouping and counts")
let byUser = txs.reduce(into: [String: Double]()) { acc, tx in
    acc[tx.user, default: 0] += tx.amount
}
print("total by user:", byUser)
let tagCounts = allTags.reduce(into: [String: Int]()) { acc, tag in
    acc[tag, default: 0] += 1
}
print("tag counts:", tagCounts)

section("Dictionary(grouping:by:) buckets")
let byFirstLetter = Dictionary(grouping: txs.map(\.user)) { $0.first! }
print("grouped users:", byFirstLetter)

section("chaining and sorting")
let topSpenders = byUser
    .map { (user: $0.key, total: $0.value) }
    .sorted { $0.total > $1.total }
    .prefix(2)
print("top spenders:", Array(topSpenders))

section("zip and enumerated")
let names = txs.map(\.user)
let amounts = txs.map(\.amount)
for (n, a) in zip(names, amounts) {
    print("pair:", n, a)
}
for (idx, tx) in txs.enumerated() {
    print("row", idx, "→", tx.id, tx.user, tx.amount)
}

section("flatMap vs. map returning optionals")
let maybeNumbers = ["1","x","2","y","3"]
let parsedWithMap = maybeNumbers.map(Int.init)
let parsedWithCompactMap = maybeNumbers.compactMap(Int.init)
print("map(Int.init):", parsedWithMap)
print("compactMap(Int.init):", parsedWithCompactMap)

section("windows and chunks with stride")
let numbers = Array(1...12)
let chunkSize = 4
let chunks = stride(from: 0, to: numbers.count, by: chunkSize).map { i in
    Array(numbers[i..<min(i+chunkSize, numbers.count)])
}
print("chunks of 4:", chunks)

section("reduce into index and lookup tables")
struct Indexes {
    var byID: [Int: Tx] = [:]
    var byUser: [String: [Tx]] = [:]
}
let indexes = txs.reduce(into: Indexes()) { idx, tx in
    idx.byID[tx.id] = tx
    idx.byUser[tx.user, default: []].append(tx)
}
print("lookup #4:", indexes.byID[4]?.amount ?? 0)
print("ana count:", indexes.byUser["ana"]?.count ?? 0)

section("compose transformations")
let avgByUser: [(String, Double)] = byUser.map { (user, total) in
    let count = txs.filter { $0.user == user }.count
    return (user, total / Double(count))
}
let pretty = avgByUser
    .sorted { $0.1 > $1.1 }
    .map { (user, avg) in "\(user): \(String(format: "%.2f", avg))" }
print("avg by user:", pretty)

section("lazy where it helps")
let bigRange = 1...1_000
let lazySum = bigRange.lazy.map { $0 * 2 }.filter { $0 % 3 == 0 }.prefix(10).reduce(0, +)
print("lazy sum first 10 multiples:", lazySum)
