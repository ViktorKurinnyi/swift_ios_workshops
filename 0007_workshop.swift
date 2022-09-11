/*
Closure Capture Lists
See how closures retain captured objects and how cycles form.
Break cycles with [weak self] and handle lifetimes safely.
Observe captured values vs references with snapshots and mutations.
*/

import Foundation

final class Owner {
    var name: String = "Owner"
    var handler: (() -> Void)?
    init() { print("Owner init") }
    deinit { print("Owner deinit") }
    func makeLeak() {
        handler = { print(self.name) }
    }
    func makeSafe() {
        handler = { [weak self] in
            print(self?.name ?? "nil")
        }
    }
}

print("=== Strong capture causes a cycle ===")
do {
    let o = Owner()
    o.makeLeak()
    o.handler?()
    print("Leaving scope with cycle intact")
}
print("If no 'Owner deinit' above, it leaked via cycle")

print("=== Break the cycle by releasing the closure ===")
do {
    let o = Owner()
    o.makeLeak()
    o.handler?()
    o.handler = nil
    print("Leaving scope after breaking cycle")
}

print("=== Weak capture avoids the cycle ===")
do {
    let o = Owner()
    o.makeSafe()
    o.handler?()
    print("Leaving scope with weak capture")
}

print("=== Capturing values vs references ===")
var counter = 0
let next = { () -> Int in
    counter += 1
    return counter
}
print(next(), next(), next())

let snapshot = { [count = counter] in count }
counter += 10
print("Snapshot still:", snapshot(), "counter now:", counter)

print("=== [unowned self] when lifetime is guaranteed ===")
final class Greeter {
    var make: (() -> String)?
    init(name: String) {
        make = { [unowned self] in "Hello, \(name) from \(self)" }
    }
    deinit { print("Greeter deinit") }
}
do {
    let g = Greeter(name: "Swift")
    print(g.make?() ?? "")
}

print("=== Done ===")
