/*
Copy-on-Write by Hand — Back your struct with a reference store and share intelligently.
Observe sharing, unique mutations, and identity of storage.
Build a tiny text buffer with appends, edits, and slicing.
*/

import Foundation

struct TextBuffer: CustomStringConvertible {
    final class Storage {
        var scalars: [UnicodeScalar]
        init(_ s: String) { self.scalars = Array(s.unicodeScalars) }
    }

    private var storage: Storage

    init(_ s: String = "") { storage = Storage(s) }

    private mutating func makeUnique() {
        if !isKnownUniquelyReferenced(&storage) {
            storage = Storage(String(String.UnicodeScalarView(storage.scalars)))
        }
    }

    var description: String { String(String.UnicodeScalarView(storage.scalars)) }

    mutating func append(_ s: String) {
        makeUnique()
        storage.scalars.append(contentsOf: s.unicodeScalars)
    }

    mutating func replace(range: Range<Int>, with s: String) {
        makeUnique()
        let replacement = Array(s.unicodeScalars)
        storage.scalars.replaceSubrange(range, with: replacement)
    }

    mutating func removeLast(_ n: Int = 1) {
        makeUnique()
        let k = max(0, storage.scalars.count - n)
        storage.scalars.removeSubrange(k..<storage.scalars.count)
    }

    var count: Int { storage.scalars.count }

    func slice(range: Range<Int>) -> String {
        let clamped = range.clamped(to: 0..<count)
        let view = String.UnicodeScalarView(Array(storage.scalars[clamped]))
        return String(view)
    }

    var storageID: String {
        String(describing: ObjectIdentifier(storage))
    }
}

extension Range where Bound == Int {
    func clamped(to bounds: Range<Int>) -> Range<Int> {
        let lower = Swift.max(lowerBound, bounds.lowerBound)
        let upper = Swift.min(upperBound, bounds.upperBound)
        return lower..<Swift.max(lower, upper)
    }
}

func demo() {
    var a = TextBuffer("Hello, world")
    var b = a
    print("a==b text:", a.description == b.description)
    print("a storage:", a.storageID)
    print("b storage:", b.storageID)

    b.append("!")
    print("after b.append")
    print("a storage:", a.storageID)
    print("b storage:", b.storageID)
    print("a:", a)
    print("b:", b)

    var c = b
    c.replace(range: 7..<12, with: "Swift")
    c.append(" 🚀")
    print("c storage:", c.storageID)
    print("b storage:", b.storageID)
    print("c:", c)

    print("slice of c:", c.slice(range: 7..<12))
    c.removeLast(3)
    print("trimmed c:", c)

    var d = a
    d.append(" and Swift")
    print("a:", a)
    print("d:", d)
}

demo()
