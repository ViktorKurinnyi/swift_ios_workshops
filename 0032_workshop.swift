/*
Teaches reproducible and secure randomness.
Implements a seedable RNG (xoroshiro128++) and uses SystemRandomNumberGenerator for entropy.
Covers sampling, shuffling, byte generation, and distribution checks.
All output is deterministic when using the same seed.
*/
import Foundation
import Security

struct SplitMix64 {
    private var state: UInt64
    init(seed: UInt64) { self.state = seed &+ 0x9E3779B97F4A7C15 }
    mutating func next() -> UInt64 {
        var z = state
        z = (z &+ 0x9E3779B97F4A7C15)
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        let r = z ^ (z >> 31)
        state = z
        return r
    }
}

struct Xoroshiro128PP: RandomNumberGenerator {
    private var s0: UInt64
    private var s1: UInt64
    init(seed: UInt64) {
        var sm = SplitMix64(seed: seed)
        self.s0 = sm.next()
        self.s1 = sm.next()
    }
    private static func rotl(_ x: UInt64, by k: UInt64) -> UInt64 {
        return (x << k) | (x >> (64 - k))
    }
    mutating func next() -> UInt64 {
        let result = Xoroshiro128PP.rotl(s0 &+ s1, by: 17) &+ s0
        var s1_ = s1 ^ s0
        s0 = Xoroshiro128PP.rotl(s0, by: 49) ^ s1_ ^ (s1_ << 21)
        s1 = Xoroshiro128PP.rotl(s1_, by: 28)
        return result
    }
}

extension Data {
    static func randomBytes<G: RandomNumberGenerator>(count: Int, using rng: inout G) -> Data {
        var bytes = [UInt8](repeating: 0, count: count)
        var i = 0
        while i < count {
            let v: UInt64 = rng.next()
            var t = v
            for _ in 0..<8 where i < count {
                bytes[i] = UInt8(truncatingIfNeeded: t)
                t >>= 8
                i += 1
            }
        }
        return Data(bytes)
    }
}

func sample<G: RandomNumberGenerator, S: Sequence>(_ n: Int, from source: S, using rng: inout G) -> [S.Element] {
    var a = Array(source)
    a.shuffle(using: &rng)
    return Array(a.prefix(n))
}

func rollDie<G: RandomNumberGenerator>(sides: Int, using rng: inout G) -> Int {
    Int.random(in: 1...sides, using: &rng)
}

var seededA = Xoroshiro128PP(seed: 42)
var seededB = Xoroshiro128PP(seed: 42)
let rollsA = (0..<10).map { _ in rollDie(sides: 6, using: &seededA) }
let rollsB = (0..<10).map { _ in rollDie(sides: 6, using: &seededB) }
print("seeded equal:", rollsA == rollsB, rollsA)

var seededC = Xoroshiro128PP(seed: 12345)
var list = Array(1...12)
list.shuffle(using: &seededC)
var seededD = Xoroshiro128PP(seed: 12345)
var list2 = Array(1...12)
list2.shuffle(using: &seededD)
print("shuffle equal:", list == list2, list)

var sys = SystemRandomNumberGenerator()
let secureRolls = (0..<5).map { _ in rollDie(sides: 20, using: &sys) }
print("secure d20 rolls:", secureRolls)

var rngBytes = Xoroshiro128PP(seed: 99)
let deterministic = Data.randomBytes(count: 16, using: &rngBytes)
print("det bytes hex:", deterministic.map { String(format: "%02x", $0) }.joined())

var secureData = Data(count: 32)
let r = secureData.withUnsafeMutableBytes { buf in
    SecRandomCopyBytes(kSecRandomDefault, buf.count, buf.baseAddress!)
}
if r == errSecSuccess {
    print("secure bytes hex:", secureData.map { String(format: "%02x", $0) }.joined())
} else {
    print("secure bytes error:", r)
}

var freq = [Int: Int](uniqueKeysWithValues: (1...6).map { ($0, 0) })
var fair = Xoroshiro128PP(seed: 2024)
for _ in 0..<10000 {
    freq[rollDie(sides: 6, using: &fair), default: 0] += 1
}
print("die frequencies:", freq.sorted { $0.key < $1.key })

var rng = Xoroshiro128PP(seed: 7)
let pick = sample(5, from: "abcdefghijklmnopqrstuvwxyz", using: &rng)
print("sample letters:", String(pick))
