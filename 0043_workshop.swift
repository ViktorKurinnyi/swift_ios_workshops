/*
WebSockets with URLSession
Stream messages and heartbeat pings locally.
Use a fake task to mirror URLSessionWebSocketTask.
Send, receive, and close without touching the network.
*/

import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

struct WebSocketMessage: Equatable {
    let text: String
}

protocol WebSocketLike: AnyObject {
    func send(_ message: WebSocketMessage) async
    func receive() async -> WebSocketMessage?
    func close() async
}

final class FakeWebSocket: WebSocketLike {
    private let stream: AsyncStream<WebSocketMessage>
    private let cont: AsyncStream<WebSocketMessage>.Continuation
    private var closed = false
    private let lock = NSLock()
    private var heartTask: Task<Void, Never>?

    init(heartbeatSeconds: Double = 0.5) {
        var c: AsyncStream<WebSocketMessage>.Continuation!
        self.stream = AsyncStream<WebSocketMessage> { cont in
            c = cont
        }
        self.cont = c
        self.heartTask = Task {
            var count = 0
            while !Task.isCancelled && !self.isClosed {
                try? await Task.sleep(nanoseconds: UInt64(heartbeatSeconds * 1_000_000_000))
                count += 1
                await self.send(.init(text: "ping \(count)"))
                if count >= 3 { break }
            }
        }
    }

    private var isClosed: Bool {
        lock.lock(); defer { lock.unlock() }
        return closed
    }

    func send(_ message: WebSocketMessage) async {
        if isClosed { return }
        cont.yield(message)
        if message.text.hasPrefix("echo ") {
            cont.yield(WebSocketMessage(text: "echoed " + String(message.text.dropFirst(5))))
        }
    }

    func receive() async -> WebSocketMessage? {
        var iterator = stream.makeAsyncIterator()
        return await iterator.next()
    }

    func close() async {
        lock.lock()
        closed = true
        lock.unlock()
        cont.finish()
        heartTask?.cancel()
    }
}

struct WebSocketClient {
    let makeSocket: () -> WebSocketLike
    func runDemo() async {
        let socket = makeSocket()
        await socket.send(.init(text: "echo hello"))
        await socket.send(.init(text: "echo world"))
        var received: [String] = []
        while received.count < 5 {
            if let msg = await socket.receive() {
                received.append(msg.text)
                print("recv:", msg.text)
            } else {
                break
            }
        }
        await socket.close()
    }
}

let client = WebSocketClient {
    FakeWebSocket(heartbeatSeconds: 0.25)
}

Task {
    await client.runDemo()
    PlaygroundPage.current.needsIndefiniteExecution = false
}
