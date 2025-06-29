/*
Widgets Overview — Build timeline entries with placeholder data.
Learn how a provider creates entries and a timeline policy.
Render entries with a simple text renderer and preview placeholders.
Everything is mocked to run in a Playground without WidgetKit.
*/
import Foundation

struct Entry: Identifiable, Hashable {
    let id = UUID()
    let date: Date
    let title: String
    let subtitle: String
    let relevance: Int
}

enum ReloadPolicy {
    case atEnd
    case after(TimeInterval)
}

struct Timeline {
    let entries: [Entry]
    let policy: ReloadPolicy
}

protocol TimelineProvider {
    func placeholder() -> Entry
    func snapshot() -> Entry
    func timeline() -> Timeline
}

struct MyWidgetProvider: TimelineProvider {
    func placeholder() -> Entry {
        Entry(date: Date(), title: "Placeholder", subtitle: "Loading...", relevance: 0)
    }
    func snapshot() -> Entry {
        Entry(date: Date(), title: "Now", subtitle: Self.subtitle(for: 0), relevance: 50)
    }
    func timeline() -> Timeline {
        let now = Date()
        var items: [Entry] = []
        for i in 0..<6 {
            let d = Calendar.current.date(byAdding: .minute, value: i * 10, to: now)!
            items.append(Entry(date: d, title: Self.title(for: i), subtitle: Self.subtitle(for: i), relevance: 100 - i * 10))
        }
        return Timeline(entries: items, policy: .after(60 * 30))
    }
    private static func title(for index: Int) -> String {
        ["Morning Brief", "Focus Sprint", "Standup Soon", "Deep Work", "Quick Break", "Wrap Up"][index % 6]
    }
    private static func subtitle(for index: Int) -> String {
        let mins = index * 10
        return "Starts in \(mins)m"
    }
}

struct TextRenderer {
    static func render(_ entry: Entry) -> String {
        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        return "[\(df.string(from: entry.date))] \(entry.title) — \(entry.subtitle) (rel \(entry.relevance))"
    }
    static func renderTimeline(_ timeline: Timeline) -> String {
        let rows = timeline.entries.map(render).joined(separator: "\n")
        let policy: String
        switch timeline.policy {
        case .atEnd: policy = "reload: at end"
        case .after(let t): policy = "reload: after \(Int(t))s"
        }
        return rows + "\n— \(policy)"
    }
}

struct WidgetPreview {
    let provider: TimelineProvider
    func show() {
        print("Placeholder:")
        print(TextRenderer.render(provider.placeholder()))
        print("\nSnapshot:")
        print(TextRenderer.render(provider.snapshot()))
        print("\nTimeline:")
        print(TextRenderer.renderTimeline(provider.timeline()))
    }
}

let provider = MyWidgetProvider()
WidgetPreview(provider: provider).show()
