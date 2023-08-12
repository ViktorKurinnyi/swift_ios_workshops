/*
URLComponents & Query Items
Build robust URLs without stringly typing.
Compose, mutate, and parse query items safely.
Everything runs offline and prints the results.
*/

import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

struct QueryItem: Hashable {
    let name: String
    let value: String?
}

extension URLComponents {
    mutating func setQueryItems(_ items: [QueryItem]) {
        queryItems = items.map { URLQueryItem(name: $0.name, value: $0.value) }
    }
    func queryDictionary() -> [String: [String]] {
        var dict: [String: [String]] = [:]
        for item in queryItems ?? [] {
            dict[item.name, default: []].append(item.value ?? "")
        }
        return dict
    }
}

func buildSearchURL(base: String, pathSegments: [String], items: [QueryItem]) -> URL {
    var comps = URLComponents(string: base)!
    let path = (comps.path as NSString).appending("/" + pathSegments.joined(separator: "/"))
    comps.path = path.replacingOccurrences(of: "//", with: "/")
    comps.setQueryItems(items)
    return comps.url!
}

let base = "https://api.example.com"
let segments = ["v1", "search"]
let rawItems: [QueryItem] = [
    .init(name: "q", value: "swift concurrency"),
    .init(name: "limit", value: "10"),
    .init(name: "lang", value: "en"),
    .init(name: "tag", value: "ios"),
    .init(name: "tag", value: "networking"),
    .init(name: "from", value: nil)
]

let url = buildSearchURL(base: base, pathSegments: segments, items: rawItems)
print("Built URL:", url.absoluteString)

let comps = URLComponents(url: url, resolvingAgainstBaseURL: false)!
print("Scheme:", comps.scheme ?? "")
print("Host:", comps.host ?? "")
print("Path:", comps.path)

let dict = comps.queryDictionary()
print("Query Keys:", dict.keys.sorted())
print("Tags:", dict["tag"] ?? [])

var comps2 = comps
var items2 = comps2.queryItems ?? []
items2.removeAll { $0.name == "limit" }
items2.append(URLQueryItem(name: "page", value: "2"))
comps2.queryItems = items2
let page2 = comps2.url!
print("Page 2 URL:", page2.absoluteString)

var comps3 = URLComponents()
comps3.scheme = "https"
comps3.host = "files.example.com"
comps3.path = "/download"
comps3.queryItems = [
    .init(name: "file", value: "Report 2025-08-31.pdf"),
    .init(name: "disposition", value: "inline")
]
let download = comps3.url!
print("Encoded:", download.absoluteString)

let baseDocs = URL(string: "https://docs.example.com/")!
let relative = URL(string: "guides/intro")!
let resolved = URL(string: relative.absoluteString, relativeTo: baseDocs)!
print("Relative:", resolved.absoluteURL.absoluteString)

let joiner = { (base: URL, extra: [String]) -> URL in
    var c = URLComponents(url: base, resolvingAgainstBaseURL: true)!
    let appended = (c.path as NSString).appending("/" + extra.joined(separator: "/"))
    c.path = appended.replacingOccurrences(of: "//", with: "/")
    return c.url!.absoluteURL
}

let deep = joiner(URL(string: base)!, ["v2", "users", "42", "profile"])
print("Joined:", deep.absoluteString)

let decode = { (u: URL) -> [String: String] in
    let c = URLComponents(url: u, resolvingAgainstBaseURL: false)!
    var out: [String: String] = [:]
    for q in c.queryItems ?? [] {
        if let v = q.value { out[q.name] = v }
    }
    return out
}

print("Decoded page2:", decode(page2))

let searchTerms = ["swift ui", "combine", "async await"]
let urls = searchTerms.map { term in
    buildSearchURL(base: base, pathSegments: ["v1", "search"], items: [
        .init(name: "q", value: term),
        .init(name: "limit", value: "5")
    ])
}
for u in urls { print("Batch:", u.absoluteString) }

PlaygroundPage.current.needsIndefiniteExecution = false
