/**
 FileManager & Sandboxes — Read/write atomically and manage directories.
 Work within the app sandbox using temporary and subdirectories.
 Create, list, move, copy, and remove files safely.
*/

import Foundation

let fm = FileManager.default
let root = fm.temporaryDirectory.appendingPathComponent("Sandbox-\(UUID().uuidString)", isDirectory: true)
try fm.createDirectory(at: root, withIntermediateDirectories: true)

let docs = root.appendingPathComponent("Docs", isDirectory: true)
let cache = root.appendingPathComponent("Cache", isDirectory: true)
try fm.createDirectory(at: docs, withIntermediateDirectories: true)
try fm.createDirectory(at: cache, withIntermediateDirectories: true)

let helloURL = docs.appendingPathComponent("hello.txt")
let text = (0..<5).map { "Line \($0 + 1): \(UUID().uuidString)" }.joined(separator: "\n")
try text.data(using: .utf8)!.write(to: helloURL, options: [.atomic])

var contents = try String(contentsOf: helloURL)
print("Created: \(helloURL.lastPathComponent)")
print(contents.split(separator: "\n").first ?? "")

let fh = try FileHandle(forWritingTo: helloURL)
_ = try fh.seekToEnd()
fh.write(Data("\nAppended at \(Date())".utf8))
try fh.close()

contents = try String(contentsOf: helloURL)
print("Appended lines:", contents.components(separatedBy: .newlines).count)

let listing = try fm.contentsOfDirectory(at: docs, includingPropertiesForKeys: [.fileSizeKey, .creationDateKey], options: [.skipsHiddenFiles])
for url in listing {
    let values = try url.resourceValues(forKeys: [.fileSizeKey, .creationDateKey])
    let size = values.fileSize ?? 0
    let created = values.creationDate ?? Date()
    print("File:", url.lastPathComponent, "•", size, "bytes •", created)
}

let copyURL = cache.appendingPathComponent("hello-copy.txt")
try fm.copyItem(at: helloURL, to: copyURL)
let movedURL = docs.appendingPathComponent("hello-moved.txt")
try fm.moveItem(at: helloURL, to: movedURL)

print("Exists original:", fm.fileExists(atPath: helloURL.path))
print("Exists moved:", fm.fileExists(atPath: movedURL.path))
print("Exists copy:", fm.fileExists(atPath: copyURL.path))

var copyValues = URLResourceValues()
copyValues.isExcludedFromBackup = true
var u = copyURL
try u.setResourceValues(copyValues)

let deep = root.appendingPathComponent("Deep/Nested/Dir", isDirectory: true)
try fm.createDirectory(at: deep, withIntermediateDirectories: true)
let many = (1...10).map { deep.appendingPathComponent("file_\($0).dat") }
for (i, url) in many.enumerated() {
    let bytes = Data((0..<1024 + i).map { _ in UInt8.random(in: 0...255) })
    try bytes.write(to: url, options: [.atomic])
}

func folderSize(_ url: URL) -> Int {
    let enumerator = fm.enumerator(at: url, includingPropertiesForKeys: [.fileSizeKey], options: [], errorHandler: nil)
    var total = 0
    while let f = enumerator?.nextObject() as? URL {
        let size = (try? f.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
        total += size
    }
    return total
}

let bytesBefore = folderSize(root)
print("Folder size before cleanup:", bytesBefore)

try fm.removeItem(at: deep)
let bytesAfter = folderSize(root)
print("Folder size after cleanup:", bytesAfter)

let report = [
    "root": root.path,
    "docs": docs.path,
    "cache": cache.path,
    "moved": movedURL.lastPathComponent,
    "copy": copyURL.lastPathComponent
]
print("Report:", report)
