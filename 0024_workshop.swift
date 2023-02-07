/*
Lazy Sequences & Performance
Compose pipelines that short-circuit and avoid unnecessary work.
Contrast eager vs lazy with prefix, and cache when reusing results.
Run in a Playground to see traces and counts.
*/
import Foundation

var mapHits = 0
var filterHits = 0

func resetCounts() {
    mapHits = 0
    filterHits = 0
}

func square(_ n: Int) -> Int {
    mapHits += 1
    print("map -> \(n) → \(n*n)")
    return n*n
}

func isDivisibleBy3(_ n: Int) -> Bool {
    filterHits += 1
    let ok = n % 3 == 0
    print("filter? \(n) → \(ok)")
    return ok
}

let numbers = Array(1...20)

print("=== Eager pipeline with prefix ===")
resetCounts()
let eagerPipeline = numbers.map(square).filter(isDivisibleBy3).prefix(3)
let eagerResult = Array(eagerPipeline)
print("eager result:", eagerResult)
print("eager map hits:", mapHits, "filter hits:", filterHits)

print("\n=== Lazy pipeline with prefix (short-circuits) ===")
resetCounts()
let lazyPipeline = numbers.lazy.map(square).filter(isDivisibleBy3).prefix(3)
let lazyResult = Array(lazyPipeline)
print("lazy result:", lazyResult)
print("lazy map hits:", mapHits, "filter hits:", filterHits)

print("\n=== Reusing a lazy pipeline recomputes work ===")
resetCounts()
let reusable = numbers.lazy.map(square).filter(isDivisibleBy3)
let firstUse = Array(reusable.prefix(2))
let secondUse = Array(reusable.prefix(2))
print("first use:", firstUse)
print("second use:", secondUse)
print("total map hits after two traversals:", mapHits, "filter hits:", filterHits)

print("\n=== Cache when you need to traverse repeatedly ===")
resetCounts()
let cached = Array(numbers.lazy.map(square).filter(isDivisibleBy3))
let firstCached = Array(cached.prefix(2))
let secondCached = Array(cached.prefix(2))
print("first cached:", firstCached)
print("second cached:", secondCached)
print("map hits to build cache once:", mapHits, "filter hits:", filterHits)

print("\n=== Mix-and-match: lazy + prefix + map chain ===")
resetCounts()
let chain = numbers.lazy
    .filter { $0.isMultiple(of: 2) }
    .map { $0 * 3 }
    .filter { $0 % 4 != 0 }
    .prefix(5)
let chainResult = Array(chain)
print("chain result:", chainResult)
print("map/filter evaluated items are minimized by laziness")