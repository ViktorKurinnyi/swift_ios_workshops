/*
Sorting & Partitioning
Stable multi-key sorts via descriptors and custom comparators.
In-place partitioning vs a stable partitioned view.
All examples print order to make behavior obvious.
*/
import Foundation

struct Task: Hashable {
    var id: Int
    var group: String
    var title: String
    var priority: Int
}

let tasks: [Task] = [
    .init(id: 1, group: "A", title: "Fix UI", priority: 2),
    .init(id: 2, group: "B", title: "Migrate DB", priority: 3),
    .init(id: 3, group: "A", title: "Write Docs", priority: 1),
    .init(id: 4, group: "B", title: "Ship v1.0", priority: 5),
    .init(id: 5, group: "A", title: "Refactor", priority: 3),
    .init(id: 6, group: "B", title: "Onboard", priority: 1),
    .init(id: 7, group: "A", title: "Profile", priority: 4),
    .init(id: 8, group: "B", title: "Design", priority: 2),
    .init(id: 9, group: "A", title: "Audit", priority: 2),
    .init(id: 10, group: "B", title: "Hotfix", priority: 5),
    .init(id: 11, group: "A", title: "Cleanup", priority: 3),
    .init(id: 12, group: "B", title: "Reindex", priority: 2),
]

func show(_ header: String, _ array: [Task]) {
    let s = array.map { "\($0.group)#\($0.id):\($0.title)(p\($0.priority))" }.joined(separator: " | ")
    print(header, s)
}

print("=== Stable multi-key sort with descriptors ===")
let byGroup = SortDescriptor(\Task.group, order: .forward)
let byPriorityDesc = SortDescriptor(\Task.priority, order: .reverse)
let byTitleLocalized = SortDescriptor(\Task.title, comparator: .localizedStandard)
let stableSorted = tasks.sorted(using: [byGroup, byPriorityDesc, byTitleLocalized])
show("stable, group ↑ then priority ↓ then title:", stableSorted)

print("\n=== Custom SortComparator ===")
struct PriorityThenID: SortComparator {
    var order: SortOrder = .forward
    func compare(_ a: Task, _ b: Task) -> ComparisonResult {
        if a.priority != b.priority {
            if a.priority > b.priority { return .orderedAscending }
            if a.priority < b.priority { return .orderedDescending }
        }
        if a.id != b.id {
            return a.id < b.id ? .orderedAscending : .orderedDescending
        }
        return .orderedSame
    }
}
let comparatorSorted = tasks.sorted(using: PriorityThenID())
show("comparator: priority ↓ then id ↑:", comparatorSorted)

print("\n=== In-place partition (not stable) ===")
var working = tasks
let pivot = working.partition { $0.priority < 3 }
let left = Array(working[..<pivot])
let right = Array(working[pivot...])
show("left (>=3) arbitrary order:", left)
show("right (<3) arbitrary order:", right)

print("\n=== Stable partitioned view ===")
extension Sequence {
    func stablePartitioned(by belongsInSecond: (Element) -> Bool) -> [Element] {
        var first: [Element] = []
        var second: [Element] = []
        for e in self {
            if belongsInSecond(e) { second.append(e) } else { first.append(e) }
        }
        return first + second
    }
}
let stablePartition = tasks.stablePartitioned { $0.priority < 3 }
show("stable left+right:", stablePartition)

print("\n=== Key-path comparator convenience ===")
var keyPathSorted = tasks
keyPathSorted.sort(using: KeyPathComparator(\.title, order: .forward))
show("title ↑ via KeyPathComparator:", keyPathSorted)

print("\nDone.")