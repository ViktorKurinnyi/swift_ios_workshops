/**
 Polymorphic Codable — Encode/Decode enums and heterogenous collections safely.
 Model a type-discriminated enum that boxes multiple concrete types.
 Round-trip arrays and compute derived values across mixed elements.
*/

import Foundation

struct Circle: Codable, Hashable {
    let id: UUID
    let radius: Double
    var area: Double { .pi * radius * radius }
}

struct Rect: Codable, Hashable {
    let id: UUID
    let width: Double
    let height: Double
    var area: Double { width * height }
}

struct Label: Codable, Hashable {
    let id: UUID
    let text: String
    var area: Double { 0 }
}

enum AnyGraphic: Codable, Hashable, CustomStringConvertible {
    case circle(Circle)
    case rect(Rect)
    case label(Label)
    
    enum Kind: String, Codable { case circle, rect, label }
    enum CodingKeys: String, CodingKey { case type, value }
    
    var description: String {
        switch self {
        case .circle(let c): return "circle(\(c.radius))"
        case .rect(let r): return "rect(\(r.width)x\(r.height))"
        case .label(let t): return "label(\(t.text))"
        }
    }
    
    var kind: Kind {
        switch self {
        case .circle: return .circle
        case .rect: return .rect
        case .label: return .label
        }
    }
    
    var area: Double {
        switch self {
        case .circle(let c): return c.area
        case .rect(let r): return r.area
        case .label: return 0
        }
    }
    
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let type = try c.decode(Kind.self, forKey: .type)
        switch type {
        case .circle:
            let v = try c.decode(Circle.self, forKey: .value)
            self = .circle(v)
        case .rect:
            let v = try c.decode(Rect.self, forKey: .value)
            self = .rect(v)
        case .label:
            let v = try c.decode(Label.self, forKey: .value)
            self = .label(v)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(kind, forKey: .type)
        switch self {
        case .circle(let v): try c.encode(v, forKey: .value)
        case .rect(let v): try c.encode(v, forKey: .value)
        case .label(let v): try c.encode(v, forKey: .value)
        }
    }
}

struct Scene: Codable, Hashable {
    var name: String
    var items: [AnyGraphic]
}

let scene = Scene(
    name: "Mixed",
    items: [
        .circle(.init(id: .init(), radius: 20)),
        .rect(.init(id: .init(), width: 30, height: 10)),
        .label(.init(id: .init(), text: "Hello")),
        .circle(.init(id: .init(), radius: 5)),
        .rect(.init(id: .init(), width: 7.5, height: 9.5))
    ]
)

let encoder = JSONEncoder()
encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
let data = try encoder.encode(scene)
print("Encoded Scene:")
print(String(data: data, encoding: .utf8)!)

let decoder = JSONDecoder()
let decoded = try decoder.decode(Scene.self, from: data)
let totalArea = decoded.items.reduce(0.0) { $0 + $1.area }
let counts = Dictionary(grouping: decoded.items, by: { $0.kind }).mapValues(\.count)

print("\nDecoded:", decoded.name)
print("Counts:", counts.map { "\($0.key)=\($0.value)" }.sorted().joined(separator: ", "))
print(String(format: "Total Area: %.2f", totalArea))

let labels = decoded.items.compactMap { item -> String? in
    if case let .label(t) = item { return t.text }
    return nil
}
print("Labels:", labels.joined(separator: " | "))

let filtered = Scene(name: "Only Shapes", items: decoded.items.filter {
    switch $0 {
    case .label: return false
    default: return true
    }
})
let filteredData = try encoder.encode(filtered)
print("\nFiltered Scene:")
print(String(data: filteredData, encoding: .utf8)!)
