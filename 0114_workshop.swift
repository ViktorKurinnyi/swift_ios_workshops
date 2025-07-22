/*
Notifications Scheduling — Local notifications with categories (mock).
Define categories and actions, schedule requests, and simulate delivery.
Drive a tiny event loop to advance time and show action handling.
No permissions or system APIs, everything runs in-process.
*/
import Foundation

struct NotificationCategory: Hashable {
    let id: String
    let actions: [String]
}

struct NotificationRequest: Hashable {
    let id: String
    let title: String
    let body: String
    let category: NotificationCategory
    let triggerDate: Date
}

final class LocalNotificationCenterMock {
    private var queue: [NotificationRequest] = []
    private var now: Date
    init(now: Date = Date()) { self.now = now }
    func schedule(_ req: NotificationRequest) {
        queue.append(req)
        queue.sort { $0.triggerDate < $1.triggerDate }
    }
    func advance(by interval: TimeInterval) {
        now = now.addingTimeInterval(interval)
        deliverDue()
    }
    private func deliverDue() {
        let due = queue.filter { $0.triggerDate <= now }
        queue.removeAll { $0.triggerDate <= now }
        due.forEach { deliver($0) }
    }
    private func deliver(_ req: NotificationRequest) {
        let df = DateFormatter(); df.dateFormat = "HH:mm:ss"
        print("[" + df.string(from: now) + "] " + req.title + " — " + req.body + " {" + req.category.id + "}")
        handleDefaultAction(for: req)
    }
    private func handleDefaultAction(for req: NotificationRequest) {
        if req.category.actions.contains("SNOOZE") {
            let snoozed = NotificationRequest(id: req.id + ".snooze", title: req.title, body: "Snoozed 1m", category: req.category, triggerDate: now.addingTimeInterval(60))
            schedule(snoozed)
            print("→ snoozed")
        } else {
            print("→ dismissed")
        }
    }
}

let category = NotificationCategory(id: "TIMER", actions: ["SNOOZE", "DISMISS"])
let start = Date()
let center = LocalNotificationCenterMock(now: start)
let req1 = NotificationRequest(id: "break", title: "Take a break", body: "Stand up and stretch", category: category, triggerDate: start.addingTimeInterval(5))
let req2 = NotificationRequest(id: "water", title: "Hydrate", body: "Drink a glass of water", category: category, triggerDate: start.addingTimeInterval(12))
center.schedule(req1)
center.schedule(req2)
center.advance(by: 5)
center.advance(by: 60)
center.advance(by: 7)
