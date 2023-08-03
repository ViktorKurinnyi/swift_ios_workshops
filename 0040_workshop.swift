/**
 Compression & Data — Zip/unzip data streams with Compression.
 Compress and decompress Data using modern APIs.
 Verify integrity and measure ratios.
*/

import Foundation
import Compression

func randomText(lines: Int) -> String {
    let words = ["swift","playground","encode","decode","compress","archive","lz4","lzfse","data","stream","apple","xcode","struct","enum"]
    var out = ""
    for i in 0..<lines {
        let w = (0..<20).map { _ in words.randomElement()! }.joined(separator: " ")
        out += "\(i) \(w)\n"
    }
    return out
}

let source = randomText(lines: 3000)
let original = Data(source.utf8)

let compressed = try (original as NSData).compressed(using: .lzfse) as Data
let decompressed = try (compressed as NSData).decompressed(using: .lzfse) as Data

let ok = original == decompressed
let ratio = Double(compressed.count) / Double(original.count)
print("OK:", ok, "• ratio:", String(format: "%.2f", ratio))

let base = FileManager.default.temporaryDirectory
let inURL = base.appendingPathComponent("payload.txt")
let compURL = base.appendingPathComponent("payload.lzfse")
let outURL = base.appendingPathComponent("payload.out.txt")

try original.write(to: inURL, options: [.atomic])
try compressed.write(to: compURL, options: [.atomic])
try decompressed.write(to: outURL, options: [.atomic])

print("Files:")
print(inURL.lastPathComponent, original.count)
print(compURL.lastPathComponent, compressed.count)
print(outURL.lastPathComponent, decompressed.count)

func chunks<T: RandomAccessCollection>(_ data: T, size: Int) -> [T.SubSequence] where T.Index == Int {
    var start = 0
    var result: [T.SubSequence] = []
    while start < data.count {
        let end = min(start + size, data.count)
        result.append(data[start..<end])
        start = end
    }
    return result
}

let chunked = chunks(original, size: 8 * 1024)
var total = 0
for part in chunked {
    total += part.count
}
print("Streamed parts:", chunked.count, "• bytes:", total)

func time(_ block: () -> Void) -> TimeInterval {
    let t0 = CFAbsoluteTimeGetCurrent()
    block()
    return CFAbsoluteTimeGetCurrent() - t0
}

let t1 = time { _ = try? (original as NSData).compressed(using: .lz4) }
let t2 = time { _ = try? (original as NSData).compressed(using: .lzfse) }
let t3 = time { _ = try? (original as NSData).compressed(using: .zlib) }

print(String(format: "Bench lz4=%.3fs lzfse=%.3fs zlib=%.3fs", t1, t2, t3))

let verify = String(data: decompressed.prefix(60), encoding: .utf8) ?? ""
print("Peek:", verify.replacingOccurrences(of: "\n", with: " "))
