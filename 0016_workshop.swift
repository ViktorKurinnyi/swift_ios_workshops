/*
Subscripts Beyond Arrays — Add indexers to your own types for expressive APIs.
Implement a 2D Matrix with scalar and range subscripts and a Polynomial type.
Add a safe subscript on Collection and demonstrate slicing.
Conclude with computations using the custom subscripts.
*/

import Foundation

public struct Matrix: CustomStringConvertible, Equatable {
    public let rows: Int
    public let cols: Int
    private var storage: [Double]
    public init(rows: Int, cols: Int, repeating value: Double = 0) {
        precondition(rows > 0 && cols > 0)
        self.rows = rows
        self.cols = cols
        self.storage = Array(repeating: value, count: rows * cols)
    }
    public var description: String {
        var lines: [String] = []
        for r in 0..<rows {
            let row = (0..<cols).map { String(format: "%.2f", self[r, $0]) }.joined(separator: " ")
            lines.append(row)
        }
        return lines.joined(separator: "\n")
    }
    public subscript(_ r: Int, _ c: Int) -> Double {
        get {
            precondition(0 <= r && r < rows && 0 <= c && c < cols)
            return storage[r * cols + c]
        }
        set {
            precondition(0 <= r && r < rows && 0 <= c && c < cols)
            storage[r * cols + c] = newValue
        }
    }
    public subscript(_ r: ClosedRange<Int>, _ c: ClosedRange<Int>) -> Matrix {
        get {
            let nr = r.count
            let nc = c.count
            var m = Matrix(rows: nr, cols: nc)
            var ri = 0
            for rr in r {
                var ci = 0
                for cc in c {
                    m[ri, ci] = self[rr, cc]
                    ci += 1
                }
                ri += 1
            }
            return m
        }
        set {
            precondition(newValue.rows == r.count && newValue.cols == c.count)
            var ri = 0
            for rr in r {
                var ci = 0
                for cc in c {
                    self[rr, cc] = newValue[ri, ci]
                    ci += 1
                }
                ri += 1
            }
        }
    }
    public static func *(lhs: Matrix, rhs: Matrix) -> Matrix {
        precondition(lhs.cols == rhs.rows)
        var out = Matrix(rows: lhs.rows, cols: rhs.cols)
        for i in 0..<lhs.rows {
            for j in 0..<rhs.cols {
                var sum = 0.0
                for k in 0..<lhs.cols { sum += lhs[i, k] * rhs[k, j] }
                out[i, j] = sum
            }
        }
        return out
    }
}

public struct Poly: CustomStringConvertible {
    public var coeffs: [Double]
    public init(_ coeffs: [Double]) { self.coeffs = coeffs }
    public subscript(degree: Int) -> Double {
        get { degree < coeffs.count ? coeffs[degree] : 0 }
        set {
            if degree >= coeffs.count { coeffs += Array(repeating: 0, count: degree - coeffs.count + 1) }
            coeffs[degree] = newValue
        }
    }
    public func callAsFunction(_ x: Double) -> Double {
        var acc = 0.0
        for i in stride(from: coeffs.count - 1, through: 0, by: -1) { acc = acc * x + coeffs[i] }
        return acc
    }
    public var description: String { coeffs.enumerated().map { "\($0.element)x^\($0.offset)" }.joined(separator: " + ") }
}

public extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

var A = Matrix(rows: 3, cols: 3)
A[0,0] = 1; A[0,1] = 2; A[0,2] = 3
A[1,0] = 0; A[1,1] = 1; A[1,2] = 4
A[2,0] = 5; A[2,1] = 6; A[2,2] = 0

var B = Matrix(rows: 3, cols: 3, repeating: 1)
B[1...2, 0...1] = Matrix(rows: 2, cols: 2, repeating: 2)
let C = A * B
print("A:\n\(A)")
print("B:\n\(B)")
print("C = A*B:\n\(C)")

var p = Poly([1, 0, 1])
p[1] = -3
let y = p(2)
print("Poly:", p, "P(2) =", y)

let arr = [10, 20, 30]
print("Safe:", arr[safe: 2] as Any, arr[safe: 5] as Any)
