/*
Value vs Reference Essentials
Build a tiny copy-on-write container using class storage.
Observe when two values share storage and when a unique copy is made.
Run and watch identities and values change across mutations.
*/

import Foundation

final class Storage {
    var array: [Int]
    init(_ array: [Int]) { self.array = array }
}

struct CowArray {
    private var storage: Storage

    init(_ array: [Int]) {
        self.storage = Storage(array)
    }

    var values: [Int] { storage.array }
    var count: Int { storage.array.count }
    var identity: ObjectIdentifier { ObjectIdentifier(storage) }

    subscript(_ index: Int) -> Int {
        get { storage.array[index] }
        set {
            ensureUnique()
            storage.array[index] = newValue
        }
    }

    mutating func append(_ value: Int) {
        ensureUnique()
        storage.array.append(value)
    }

    private mutating func ensureUnique() {
        if !isKnownUniquelyReferenced(&storage) {
            storage = Storage(storage.array)
        }
    }
}

func show(_ label: String, _ cow: CowArray) {
    print(label, "values:", cow.values, "storage:", cow.identity)
}

var a = CowArray([1, 2, 3])
var b = a
print("=== Start: two values share storage ===")
show("a", a)
show("b", b)

print("=== Mutate b: triggers copy-on-write ===")
b.append(99)
show("a", a)
show("b", b)

print("=== Mutate a via subscript: stays independent ===")
a[0] = 42
show("a", a)
show("b", b)

print("=== More copies from b ===")
var c = b
show("c (before change)", c)
c[1] = -7
show("b (unchanged)", b)
show("c (after change)", c)

final class RefBox {
    var value: Int
    init(_ value: Int) { self.value = value }
}

func id(_ object: AnyObject) -> ObjectIdentifier { ObjectIdentifier(object) }

print("=== Reference identity demo ===")
let r1 = RefBox(10)
let r2 = r1
print("r1 id:", id(r1))
print("r2 id:", id(r2))
r2.value = 77
print("r1.value:", r1.value, "r2.value:", r2.value)

print("=== Mixed: store arrays inside COW ===")
var cow1 = CowArray(Array(0..<5))
var cow2 = cow1
show("cow1", cow1)
show("cow2", cow2)
cow2.append(5)
show("cow1 (after cow2 append)", cow1)
show("cow2 (after append)", cow2)

print("=== End ===")
