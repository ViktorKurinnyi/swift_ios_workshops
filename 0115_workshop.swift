/*
Background Tasks Design — Model BGTaskScheduler workflows offline.
Register task handlers, schedule requests, and simulate constraints.
Advance virtual time to let tasks run when eligible.
Demonstrates refresh vs processing semantics with priorities.
*/
import Foundation

protocol BGTask {
    var identifier: String { get }
    var earliestBeginDate: Date { get }
    func run(completion: @escaping () -> Void)
    func setTaskCompleted()
}

struct TaskRequest {
    let identifier: String
    let earliestBeginDate: Date
    let requiresExternalPower: Bool
    let requiresNetwork: Bool
}

final class BGTaskSchedulerMock {
    private var handlers: [String: (BGTask) -> Void] = [:]
    private var requests: [TaskRequest] = []
    private var now: Date
    var onLog: ((String) -> Void)?
    init(now: Date = Date()) { self.now = now }
    func register(for id: String, handler: @escaping (BGTask) -> Void) {
        handlers[id] = handler
        onLog?("registered " + id)
    }
    func submit(_ req: TaskRequest) {
        requests.append(req)
        onLog?("submitted " + req.identifier)
    }
    func advance(by seconds: TimeInterval, power: Bool = true, network: Bool = true) {
        now = now.addingTimeInterval(seconds)
        let runnable = requests.filter { $0.earliestBeginDate <= now && (!($0.requiresExternalPower) || power) && (!($0.requiresNetwork) || network) }
        requests.removeAll { x in runnable.contains(where: { $0.identifier == x.identifier && $0.earliestBeginDate == x.earliestBeginDate }) }
        runnable.sorted { $0.requiresExternalPower && !$1.requiresExternalPower }.forEach { fire($0) }
    }
    private func fire(_ req: TaskRequest) {
        guard let h = handlers[req.identifier] else { return }
        let task = SimpleBGTask(identifier: req.identifier, earliestBeginDate: req.earliestBeginDate) { [weak self] in
            self?.onLog?("completed " + req.identifier)
        }
        onLog?("running " + req.identifier)
        h(task)
    }
    private final class SimpleBGTask: BGTask {
        let identifier: String
        let earliestBeginDate: Date
        let completion: () -> Void
        init(identifier: String, earliestBeginDate: Date, completion: @escaping () -> Void) {
            self.identifier = identifier
            self.earliestBeginDate = earliestBeginDate
            self.completion = completion
        }
        func run(completion: @escaping () -> Void) {}
        func setTaskCompleted() { completion() }
    }
}

final class Repository {
    private var records: [String] = []
    func refresh() { records = ["A", "B", "C"] }
    func process() { records = records.map { $0.lowercased() } }
    func dump() -> [String] { records }
}

let now = Date()
let repo = Repository()
let scheduler = BGTaskSchedulerMock(now: now)
scheduler.onLog = { print($0) }
scheduler.register(for: "app.refresh") { task in
    repo.refresh()
    task.setTaskCompleted()
}
scheduler.register(for: "app.processing") { task in
    repo.process()
    task.setTaskCompleted()
}
let refreshReq = TaskRequest(identifier: "app.refresh", earliestBeginDate: now.addingTimeInterval(10), requiresExternalPower: false, requiresNetwork: false)
let processingReq = TaskRequest(identifier: "app.processing", earliestBeginDate: now.addingTimeInterval(20), requiresExternalPower: true, requiresNetwork: false)
scheduler.submit(refreshReq)
scheduler.submit(processingReq)
scheduler.advance(by: 5, power: false, network: true)
print(repo.dump())
scheduler.advance(by: 6, power: false, network: true)
print(repo.dump())
scheduler.advance(by: 9, power: false, network: true)
print(repo.dump())
scheduler.advance(by: 0, power: true, network: true)
print(repo.dump())
