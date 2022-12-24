/*
Result and Throwing APIs — Unify error handling with Result bridges.
Model domain errors, convert throwing code into Result, and transform with map/flatMap.
Show composing multiple fallible steps and extracting values.
Finish with a small flow that validates and computes.
*/

import Foundation

public enum MathError: Error, CustomStringConvertible {
    case notANumber(String)
    case outOfRange(Int)
    case divisionByZero
    public var description: String {
        switch self {
        case .notANumber(let s): return "not a number: \(s)"
        case .outOfRange(let n): return "out of range: \(n)"
        case .divisionByZero: return "division by zero"
        }
    }
}

public func parseInt(_ s: String) throws -> Int {
    guard let n = Int(s.trimmingCharacters(in: .whitespacesAndNewlines)) else { throw MathError.notANumber(s) }
    return n
}

public func clamp(_ n: Int, range: ClosedRange<Int>) throws -> Int {
    guard range.contains(n) else { throw MathError.outOfRange(n) }
    return n
}

public func divide(_ a: Int, by b: Int) throws -> Int {
    guard b != 0 else { throw MathError.divisionByZero }
    return a / b
}

public func attempt<T>(_ f: () throws -> T) -> Result<T, Error> {
    do { return .success(try f()) } catch { return .failure(error) }
}

public struct ErrorString: Error, CustomStringConvertible {
    public let value: String
    public init(_ value: String) { self.value = value }
    public var description: String { value }
}

public extension Result {
    func getOrNil() -> Success? { try? get() }
    func mapErrorString() -> Result<Success, ErrorString> { mapError { ErrorString("\($0)") } }
}

let inputs = [" 42", "9", "0", "oops"]
let parsed = inputs.map { s in attempt { try parseInt(s) } }
print("Parsed:", parsed)

let safe = parsed.compactMap { try? $0.get() }.filter { $0 >= 0 }
print("Safe ints:", safe)

let range = 1...100
let validated = safe.map { n in attempt { try clamp(n, range: range) } }
print("Validated:", validated)

let quotient = attempt {
    let a = try clamp(84, range: range)
    let b = try clamp(2, range: range)
    return try divide(a, by: b)
}
print("Quotient:", quotient)

let chained = attempt { try divide(100, by: 5) }
    .flatMap { a in attempt { try divide(a, by: 2) } }
    .map { $0 * 3 }
print("Chained:", chained)

switch quotient {
case .success(let v): print("Success value:", v)
case .failure(let e): print("Failed with:", e)
}
