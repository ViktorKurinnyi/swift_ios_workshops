/*
Live Activities Basics — Present real-time glanceable info (simulated).
Model attributes, state updates, and lifecycle without ActivityKit.
Render a compact and expanded view for each state transition.
Run a short session with deterministic state changes.
*/
import Foundation

struct ActivityAttributes: Hashable {
    var name: String
    var goal: Int
}

enum ActivityContent: Equatable {
    case inactive
    case active(progress: Int)
    case ended(final: String)
}

final class LiveActivitySim {
    let attributes: ActivityAttributes
    private(set) var state: ActivityContent = .inactive {
        didSet { onUpdate?(state) }
    }
    var onUpdate: ((ActivityContent) -> Void)?
    init(attributes: ActivityAttributes) { self.attributes = attributes }
    func start() {
        guard case .inactive = state else { return }
        state = .active(progress: 0)
    }
    func update(progress: Int) {
        guard case .active = state else { return }
        state = .active(progress: progress)
    }
    func end(summary: String) {
        state = .ended(final: summary)
    }
}

struct LockScreenView {
    static func render(attributes: ActivityAttributes, content: ActivityContent) -> String {
        switch content {
        case .inactive:
            return "⏸️ \(attributes.name) — not started"
        case .active(let p):
            let pct = Int(Double(p) / Double(max(attributes.goal, 1)) * 100)
            return "🔴 \(attributes.name) \(p)/\(attributes.goal) — \(pct)%"
        case .ended(let s):
            return "✅ \(attributes.name) — \(s)"
        }
    }
}

struct ExpandedView {
    static func render(attributes: ActivityAttributes, content: ActivityContent) -> String {
        switch content {
        case .inactive:
            return "Get ready for \(attributes.name). Goal: \(attributes.goal)."
        case .active(let p):
            let remaining = max(attributes.goal - p, 0)
            let barCount = 20
            let filled = min(barCount, Int(Double(p) / Double(max(attributes.goal, 1)) * Double(barCount)))
            let bar = String(repeating: "█", count: filled) + String(repeating: "░", count: barCount - filled)
            return "[\(bar)] Remaining: \(remaining)"
        case .ended(let s):
            return "Summary: \(s)"
        }
    }
}

let attrs = ActivityAttributes(name: "Breathing Session", goal: 10)
let activity = LiveActivitySim(attributes: attrs)
activity.onUpdate = { content in
    print(LockScreenView.render(attributes: attrs, content: content))
    print(ExpandedView.render(attributes: attrs, content: content))
    print("—")
}
activity.start()
for p in stride(from: 2, through: 10, by: 2) { activity.update(progress: p) }
activity.end(summary: "Calm achieved in 4 steps")
