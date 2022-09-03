/*
Class Initialization & ARC
Create retain cycles and see why they leak.
Break them with weak and unowned references and watch deinits fire.
Trace object lifetimes through scopes for intuition about ARC.
*/

import Foundation

final class PersonStrong {
    let name: String
    var apartment: ApartmentStrong?
    init(name: String) { self.name = name; print("PersonStrong init", name) }
    deinit { print("PersonStrong deinit", name) }
}

final class ApartmentStrong {
    let unit: String
    var tenant: PersonStrong?
    init(unit: String) { self.unit = unit; print("ApartmentStrong init", unit) }
    deinit { print("ApartmentStrong deinit", unit) }
}

func strongCycleDemo() {
    var p: PersonStrong? = PersonStrong(name: "Alice")
    var a: ApartmentStrong? = ApartmentStrong(unit: "4A")
    p!.apartment = a
    a!.tenant = p
    p = nil
    a = nil
    print("Strong cycle still alive (no deinit messages)")
}

final class PersonWeak {
    let name: String
    var apartment: ApartmentWeak?
    init(name: String) { self.name = name; print("PersonWeak init", name) }
    deinit { print("PersonWeak deinit", name) }
}

final class ApartmentWeak {
    let unit: String
    weak var tenant: PersonWeak?
    init(unit: String) { self.unit = unit; print("ApartmentWeak init", unit) }
    deinit { print("ApartmentWeak deinit", unit) }
}

func weakBreakDemo() {
    var p: PersonWeak? = PersonWeak(name: "Bob")
    var a: ApartmentWeak? = ApartmentWeak(unit: "7B")
    p!.apartment = a
    a!.tenant = p
    p = nil
    a = nil
    print("Weak reference allowed deinits above")
}

final class Customer {
    let name: String
    var card: CreditCard?
    init(name: String) { self.name = name; print("Customer init", name) }
    deinit { print("Customer deinit", name) }
}

final class CreditCard {
    let number: Int
    unowned let owner: Customer
    init(number: Int, owner: Customer) {
        self.number = number
        self.owner = owner
        print("CreditCard init", number, "for", owner.name)
    }
    deinit { print("CreditCard deinit", number) }
}

func unownedDemo() {
    do {
        let c = Customer(name: "Carol")
        c.card = CreditCard(number: 4242, owner: c)
        print("Owner name via card:", c.card!.owner.name)
    }
    print("Customer and card should deinit after scope")
}

print("=== Strong cycle ===")
strongCycleDemo()
print("=== Weak break ===")
weakBreakDemo()
print("=== Unowned owner ===")
unownedDemo()
