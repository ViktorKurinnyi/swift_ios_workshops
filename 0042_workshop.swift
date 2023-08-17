/*
URLSession Essentials
Mock requests and decode responses cleanly.
Use URLProtocol to stub data and test decoding.
Everything runs offline with predictable output.
*/

import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

final class MockURLProtocol: URLProtocol {
    static var handler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func startLoading() {
        guard let handler = MockURLProtocol.handler else { return }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    override func stopLoading() {}
}

struct User: Codable, Hashable {
    let id: Int
    let name: String
    let email: String
}

struct UsersResponse: Codable {
    let users: [User]
}

struct APIError: Error, CustomStringConvertible {
    let message: String
    var description: String { message }
}

struct API {
    let session: URLSession
    func getUsers() async throws -> [User] {
        let url = URL(string: "https://api.example.com/users")!
        let (data, response) = try await session.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw APIError(message: "bad status") }
        return try JSONDecoder().decode(UsersResponse.self, from: data).users
    }
}

let config = URLSessionConfiguration.ephemeral
config.protocolClasses = [MockURLProtocol.self]
let session = URLSession(configuration: config)

MockURLProtocol.handler = { request in
    let sample = UsersResponse(users: [
        .init(id: 1, name: "Taylor", email: "taylor@example.com"),
        .init(id: 2, name: "Jordan", email: "jordan@example.com"),
        .init(id: 3, name: "Casey", email: "casey@example.com")
    ])
    let data = try! JSONEncoder().encode(sample)
    let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: ["Content-Type": "application/json"])!
    return (response, data)
}

let api = API(session: session)

Task {
    do {
        let users = try await api.getUsers()
        for u in users { print("\(u.id): \(u.name) <\(u.email)>") }
    } catch {
        print("Error:", error)
    }
    PlaygroundPage.current.needsIndefiniteExecution = false
}
