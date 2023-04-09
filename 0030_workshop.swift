/*
Bitwise & Options Sets — Model feature flags with OptionSet.
Compose flags, test membership, toggle bits, and derive roles and masks.
Use raw integers safely while keeping APIs expressive.
*/

import Foundation

struct Features: OptionSet, CustomStringConvertible {
    let rawValue: UInt16

    init(rawValue: UInt16) { self.rawValue = rawValue }

    static let pro           = Features(rawValue: 1 << 0)
    static let offline       = Features(rawValue: 1 << 1)
    static let cloudSync     = Features(rawValue: 1 << 2)
    static let analytics     = Features(rawValue: 1 << 3)
    static let debugTools    = Features(rawValue: 1 << 4)
    static let experimental  = Features(rawValue: 1 << 5)
    static let betaUI        = Features(rawValue: 1 << 6)
    static let accessibility = Features(rawValue: 1 << 7)
    static let admin         = Features(rawValue: 1 << 8)
    static let educator      = Features(rawValue: 1 << 9)

    static func bit(_ n: Int) -> Features {
        Features(rawValue: 1 << n)
    }

    static let basic: Features = [.offline, .accessibility]
    static let standard: Features = [.offline, .cloudSync, .analytics, .accessibility]
    static let premium: Features = [.pro, .cloudSync, .analytics, .betaUI, .accessibility]
    static let superuser: Features = [.admin, .debugTools, .pro, .cloudSync, .analytics]

    var description: String {
        var parts: [String] = []
        if contains(.pro) { parts.append("pro") }
        if contains(.offline) { parts.append("offline") }
        if contains(.cloudSync) { parts.append("cloudSync") }
        if contains(.analytics) { parts.append("analytics") }
        if contains(.debugTools) { parts.append("debugTools") }
        if contains(.experimental) { parts.append("experimental") }
        if contains(.betaUI) { parts.append("betaUI") }
        if contains(.accessibility) { parts.append("accessibility") }
        if contains(.admin) { parts.append("admin") }
        if contains(.educator) { parts.append("educator") }
        return parts.isEmpty ? "∅" : parts.joined(separator: ",")
    }
}

extension FixedWidthInteger {
    var binaryPadded: String {
        let bits = String(self, radix: 2)
        let pad = String(repeating: "0", count: bitWidth - bits.count)
        return pad + bits
    }
}

func mask(allow: Features, deny: Features = []) -> Features {
    Features(rawValue: allow.rawValue & ~deny.rawValue)
}

func apply(serverBits: UInt16) -> Features {
    Features(rawValue: serverBits)
}

func demo() {
    var current: Features = .basic
    print("basic:", current, current.rawValue.binaryPadded)

    current.insert(.cloudSync)
    current.remove(.offline)
    print("toggled:", current, current.rawValue.binaryPadded)

    let server = apply(serverBits: 0b0000_0011_1011)
    print("server:", server, server.rawValue.binaryPadded)

    let allowed = mask(allow: .premium, deny: [.betaUI])
    let effective = current.union(allowed).intersection(server)
    print("effective:", effective, effective.rawValue.binaryPadded)

    if effective.contains(.analytics) { print("analytics enabled") }
    if !effective.contains(.offline) { print("requires network") }

    let dynamic = Features(unioning: Features.bit(12), Features.bit(13))
    let all = effective.union(dynamic)
    print("with dynamic:", all.rawValue.binaryPadded)

    let roles: [String: Features] = [
        "guest": .basic,
        "member": .standard,
        "vip": .premium,
        "root": .superuser
    ]
    let request: Features = [.analytics, .cloudSync, .pro]
    let best = roles.min { lhs, rhs in
        lhs.value.symmetricDifference(request).count < rhs.value.symmetricDifference(request).count
    }!
    print("closest role:", best.key, best.value)
}

private extension Features {
    var count: Int { rawValue.nonzeroBitCount }
}

private extension Features {
    init(unioning a: Features, _ b: Features) {
        self = a.union(b)
    }
}

demo()
