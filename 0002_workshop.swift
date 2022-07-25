/*
Optionals Deep Dive
Model absence, unwrap safely, and chain transformations elegantly.
Use if let, guard let, optional chaining, map/flatMap, and nil-coalescing.
See how optional pipelines produce clean data flows.
*/

import Foundation

struct User {
    let id: Int
    let name: String
    let email: String?
    let referrerID: Int?
}

let allUsers: [Int: User] = {
    let alice = User(id: 1, name: "Alice", email: "alice@example.com", referrerID: nil)
    let bob = User(id: 2, name: "Bob", email: nil, referrerID: 1)
    let charlie = User(id: 3, name: "Charlie", email: "charlie@swift.org", referrerID: 2)
    return [alice.id: alice, bob.id: bob, charlie.id: charlie]
}()

func findUser(id: Int) -> User? {
    allUsers[id]
}

func domain(from email: String) -> String? {
    let pieces = email.split(separator: "@")
    guard pieces.count == 2 else { return nil }
    return String(pieces[1])
}

print("=== Basic safe unwrapping ===")
if let u = findUser(id: 2) {
    print("Found:", u.name)
} else {
    print("User missing")
}

print("=== guard let in a small workflow ===")
func sendWelcome(to id: Int) {
    guard let user = findUser(id: id) else {
        print("No user for id", id); return
    }
    guard let email = user.email else {
        print("No email for", user.name); return
    }
    print("Welcome email to", email)
}
sendWelcome(to: 1)
sendWelcome(to: 2)

print("=== Optional chaining across relationships ===")
let referrerEmailUpper = findUser(id: 3)?.referrerID.flatMap(findUser)?.email?.uppercased()
print("Referrer email upper:", referrerEmailUpper ?? "nil")

print("=== Transform with map / flatMap ===")
let cDomain = findUser(id: 3)
    .flatMap { $0.email }
    .flatMap(domain)
    .map { $0.lowercased() }
print("Charlie's domain:", cDomain ?? "nil")

print("=== Nil-coalescing for defaults ===")
let guestName = findUser(id: 999)?.name ?? "Guest"
print("Guest:", guestName)

print("=== Optional pipelines on arrays ===")
let domains = allUsers.values
    .compactMap { $0.email }
    .compactMap(domain)
    .sorted()
print("Domains:", domains)

print("=== map vs flatMap with nested optionals ===")
func firstLetter(_ s: String?) -> String? {
    s.map { String($0.prefix(1)) }
}
let first = firstLetter(findUser(id: 2)?.email)
print("Bob first letter:", first ?? "nil")

print("=== try? integrates with optionals ===")
enum ParseError: Error { case bad }
func parseInt(_ s: String) throws -> Int {
    if let v = Int(s) { return v }
    throw ParseError.bad
}
let numbers = ["1", "x", "3", "5"].compactMap { try? parseInt($0) }
print("Parsed numbers:", numbers)

print("=== Flat chains that stop on nil ===")
let chain = findUser(id: 2)?.email?.split(separator: "@").last.map(String.init)
print("Bob domain:", chain ?? "nil")

print("=== Final check ===")
let reachable = allUsers.values.filter { $0.email != nil }.map { $0.name }
print("Reachable users:", reachable)
