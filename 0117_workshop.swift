/*
Dependency Injection Lite — Pass services through environments cleanly.
Define an Environment, a global Current, and a key-path @Inject wrapper.
Swap environments for tests and previews without touching call sites.
Show services using date, uuid, and logger dependencies.
*/
import Foundation

protocol DateProviding { func now() -> Date }
protocol Logging { func log(_ message: String) }

struct DefaultDateProvider: DateProviding { func now() -> Date { Date() } }
struct TestDateProvider: DateProviding { let fixed: Date; func now() -> Date { fixed } }

struct ConsoleLogger: Logging {
    func log(_ message: String) { print(message) }
}
struct BufferLogger: Logging {
    var buffer: (String) -> Void
    func log(_ message: String) { buffer(message) }
}

struct Environment {
    var date: DateProviding
    var logger: Logging
    var uuid: () -> UUID
    static var `default`: Environment {
        Environment(date: DefaultDateProvider(), logger: ConsoleLogger(), uuid: { UUID() })
    }
}

enum Current {
    static var env: Environment = .default
}

@propertyWrapper
struct Inject<Value> {
    private let keyPath: WritableKeyPath<Environment, Value>
    init(_ keyPath: WritableKeyPath<Environment, Value>) { self.keyPath = keyPath }
    var wrappedValue: Value {
        get { Current.env[keyPath: keyPath] }
        set { Current.env[keyPath: keyPath] = newValue }
    }
}

struct Reporter {
    @Inject(\Environment.date) var date: DateProviding
    @Inject(\Environment.logger) var logger: Logging
    @Inject(\Environment.uuid) var uuid: () -> UUID
    func report(_ message: String) {
        let df = ISO8601DateFormatter()
        let stamp = df.string(from: date.now())
        logger.log("[\(stamp)] \(uuid().uuidString.prefix(8)) — \(message)")
    }
}

let reporter = Reporter()
reporter.report("Boot")

let capture = NSMutableArray()
Current.env = Environment(date: TestDateProvider(fixed: Date(timeIntervalSince1970: 1_700_000_000)), logger: BufferLogger(buffer: { capture.add($0) }), uuid: { UUID(uuidString: "12345678-1234-1234-1234-1234567890ab")! })
let testReporter = Reporter()
testReporter.report("Preview run")
for line in capture { print(line as! String) }
