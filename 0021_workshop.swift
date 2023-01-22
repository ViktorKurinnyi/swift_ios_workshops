/*
String & Unicode Truths — Handle scalars, clusters, indices, and normalization.
Learn canonical equivalence, diacritics, and why Character ≠ Unicode.Scalar count.
Slice safely with String.Index and compare with normalization-aware strategies.
All runnable in a plain Swift Playground without external assets.
*/
import Foundation

func section(_ title: String) { print("\n=== \(title) ===") }

section("Canonical Equivalence")
let cafe1 = "café"
let cafe2 = "cafe\u{301}"
print("cafe1 == cafe2:", cafe1 == cafe2)
print("characters:", cafe1.count, cafe2.count)
print("unicodeScalars:", cafe1.unicodeScalars.count, cafe2.unicodeScalars.count)

section("Normalization (NFC/NFD)")
let nfc1 = cafe1.precomposedStringWithCanonicalMapping
let nfd1 = cafe1.decomposedStringWithCanonicalMapping
let nfc2 = cafe2.precomposedStringWithCanonicalMapping
let nfd2 = cafe2.decomposedStringWithCanonicalMapping
print("NFC equal:", nfc1 == nfc2)
print("NFD equal:", nfd1 == nfd2)

section("Diacritic-Insensitive Search")
let haystack = "Cafetería — Hoy café frío y fresas"
let needle = "Cafe"
let foldedHaystack = haystack.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
let foldedNeedle = needle.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
print("contains (folded):", foldedHaystack.contains(foldedNeedle))

section("Extended Grapheme Clusters")
let flag = "🇪🇸"
let technologist = "👨🏽‍💻"
let mixed = "A\(flag)\(technologist)!"
print("string:", mixed)
print("characters:", mixed.count)
print("unicodeScalars:", mixed.unicodeScalars.count)
for ch in mixed {
    let scalars = ch.unicodeScalars.map { String(format:"U+%04X", $0.value) }.joined(separator: " ")
    print("char:", ch, "scalars:", scalars)
}

section("Indexing by Character")
let i1 = mixed.index(mixed.startIndex, offsetBy: 1)
let i2 = mixed.index(after: i1)
let slice = mixed[i1..<i2]
print("slice at [1]:", slice)
let last = mixed.index(before: mixed.endIndex)
print("last char:", mixed[last])

section("Insert Combining Mark via UnicodeScalars")
var cafe3 = "cafe"
cafe3.unicodeScalars.insert("\u{301}", at: cafe3.unicodeScalars.endIndex)
print("constructed:", cafe3, "== café:", cafe3 == cafe1)
print("constructed scalars:", cafe3.unicodeScalars.map{String(format:"U+%04X", $0.value)}.joined(separator:" "))

section("Decomposed Editing then Recompose")
var decomposed = cafe1.decomposedStringWithCanonicalMapping
let removed = decomposed.unicodeScalars.filter { $0.properties.canonicalCombiningClass == .notReordered }
let recomposed = String(String.UnicodeScalarView(removed)).precomposedStringWithCanonicalMapping
print("removed diacritics:", recomposed)

section("Find Cluster Containing Base Scalar")
let manScalar = "👨".unicodeScalars.first!
if let idx = mixed.firstIndex(where: { ch in ch.unicodeScalars.contains(where: { $0 == manScalar }) }) {
    print("cluster with U+1F468:", mixed[idx])
}

section("Stable Equality vs. Binary Equality")
let bytesEqual = cafe1.unicodeScalars.elementsEqual(cafe2.unicodeScalars)
print("binary scalars equal:", bytesEqual, "string equal:", cafe1 == cafe2)

section("Safe Slicing Around Cluster Boundaries")
let start = mixed.startIndex
let end = mixed.index(start, offsetBy: 3)
let safeSub = mixed[start..<end]
print("first three clusters:", safeSub)

section("Normalization-Aware Sorting Demo")
let words = ["résumé", "resume", "resumé", "résume"]
let normalized = words.map { ($0, $0.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)) }
let sorted = normalized.sorted { $0.1 < $1.1 }.map { $0.0 }
print("sorted (folded):", sorted)
