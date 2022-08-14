/*
Pattern Matching Power
Use if case, guard case, and switch with tuples, ranges, and where.
Compose precise conditions that read like rules instead of branches.
See how pattern matching simplifies parsing and classification.
*/

import Foundation

enum Token {
    case number(Int)
    case identifier(String)
    case symbol(Character)
}

let stream: [Token] = [
    .number(3), .identifier("foo"), .number(12), .symbol("+"),
    .identifier("bar"), .number(0), .symbol("("), .number(7)
]

print("=== if case with extra conditions ===")
for t in stream {
    if case .number(let n) = t, (0...10).contains(n) {
        print("small number:", n)
    }
}

func headIdentifier(_ tokens: [Token]) -> String? {
    guard case .identifier(let s)? = tokens.first else { return nil }
    return s
}
print("Head identifier:", headIdentifier(stream) ?? "nil")

print("=== switch over tuples and ranges ===")
let points: [(Int, Int)] = [ (0,0), (5,0), (0,7), (3,3), (12,-1), (-2,4) ]

for p in points {
    switch p {
    case (0, 0):
        print("origin")
    case (let x, 0):
        print("x-axis at", x)
    case (0, let y):
        print("y-axis at", y)
    case (-10...10, -10...10) where p.0 != 0 && p.1 != 0:
        print("near center", p)
    case (let x, let y) where x == y:
        print("diagonal", p)
    default:
        print("far", p)
    }
}

print("=== switch binding with enums ===")
for t in stream {
    switch t {
    case .number(let n) where n.isMultiple(of: 2):
        print("even:", n)
    case .number(let n):
        print("odd:", n)
    case .identifier(let s) where s.count > 2:
        print("long id:", s)
    case .identifier(let s):
        print("id:", s)
    case .symbol(let c):
        print("symbol:", c)
    }
}

print("=== parse a tiny expression: id (+ number)? ===")
func parseTiny(_ tokens: ArraySlice<Token>) -> String {
    var it = tokens.makeIterator()
    guard case .identifier(let name)? = it.next() else { return "no id" }
    guard case .symbol("+")? = it.next() else { return "id only: \(name)" }
    guard case .number(let n)? = it.next() else { return "broken op" }
    return "sum \(name) + \(n)"
}
print(parseTiny(stream[0...3]))
print(parseTiny(stream[1...2]))
print(parseTiny(stream[4...6]))

print("=== Destructure optionals with case ===")
let maybe: Int? = Int("42")
if case let .some(v) = maybe {
    print("value:", v)
}
if case .none = Int("nope") {
    print("none")
}
