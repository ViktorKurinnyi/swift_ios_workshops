/*
Availability & Conditional Compilation — Gate features with @available and #if.
Demonstrate platform, Swift version, and feature availability guards.
Provide fallbacks where needed and select implementations at compile time.
Print which code path executed so behavior is visible.
*/

import Foundation

@available(iOS 16, macOS 13, *)
public func modernAlgorithm(_ xs: [Int]) -> Int {
    xs.reduce(0, +)
}

@available(*, deprecated, message: "Use modernAlgorithm")
public func legacyAlgorithm(_ xs: [Int]) -> Int {
    var s = 0
    for x in xs { s += x }
    return s
}

public func chooseAlgorithm(_ xs: [Int]) -> Int {
    if #available(iOS 16, macOS 13, *) {
        return modernAlgorithm(xs)
    } else {
        return legacyAlgorithm(xs)
    }
}

public func buildMessage() -> String {
    #if swift(>=5.9)
    let mode = "Swift >= 5.9"
    #else
    let mode = "Swift < 5.9"
    #endif

    #if os(macOS)
    let platform = "macOS"
    #elseif os(iOS)
    let platform = "iOS"
    #else
    let platform = "otherOS"
    #endif

    #if canImport(Combine)
    let feature = "Combine available"
    #else
    let feature = "Combine missing"
    #endif

    return "\(mode) on \(platform) with \(feature)"
}

let xs = Array(1...10)
let total = chooseAlgorithm(xs)
print("Total:", total)

let msg = buildMessage()
print("Build:", msg)
