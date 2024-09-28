/*
NavigationStack & Path — Push, pop, and deep-link robustly.
Model routes, navigate programmatically, and restore state.
Includes deep-link parsing from a text field.
Uses NavigationStack with type-safe destinations.
*/
import SwiftUI
import PlaygroundSupport

enum Route: Hashable {
    case number(Int)
    case user(String)
    case detail(String, Int)
}

struct ContentView: View {
    @State private var path: [Route] = []
    @State private var input: String = "user:alex -> detail:orders:3"
    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 16) {
                HStack {
                    TextField("Enter deeplink", text: $input)
                        .textFieldStyle(.roundedBorder)
                        .submitLabel(.go)
                        .onSubmit { openLink(input) }
                    Button("Open") { openLink(input) }.buttonStyle(.borderedProminent)
                }
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        Button("Push 1→2→3") {
                            path.append(contentsOf: [.number(1), .number(2), .number(3)])
                        }
                        Button("Random User") {
                            let users = ["alex","sam","riley","jordan","casey","morgan"]
                            path.append(.user(users.randomElement()!))
                        }
                        Button("Reset") { path.removeAll() }.tint(.red)
                    }
                    .buttonStyle(.bordered)
                }
                List(1...20, id: \.self) { i in
                    NavigationLink("Item #\(i)", value: Route.detail("item", i))
                }
            }
            .padding()
            .navigationTitle("Home")
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .number(let n):
                    NumberView(n: n) { path.removeAll(where: { $0 == .number(n) }) }
                case .user(let name):
                    UserView(name: name)
                case .detail(let kind, let id):
                    DetailView(kind: kind, id: id)
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button("Pop") { if !path.isEmpty { path.removeLast() } }
                    Button("Root") { path.removeAll() }
                    Spacer()
                    Text("Depth: \(path.count)").foregroundStyle(.secondary)
                }
            }
        }
    }
    func openLink(_ text: String) {
        var new: [Route] = []
        let parts = text.components(separatedBy: "->").map { $0.trimmingCharacters(in: .whitespaces) }
        for p in parts {
            if p.hasPrefix("user:") {
                new.append(.user(String(p.dropFirst(5))))
            } else if p.hasPrefix("detail:") {
                let comps = p.split(separator: ":")
                if comps.count == 3, let id = Int(comps[2]) {
                    new.append(.detail(String(comps[1]), id))
                }
            } else if p.hasPrefix("number:"), let num = Int(p.dropFirst(7)) {
                new.append(.number(num))
            }
        }
        withAnimation(.snappy) { path.append(contentsOf: new) }
    }
}

struct NumberView: View {
    let n: Int
    var onClose: () -> Void
    var body: some View {
        VStack(spacing: 20) {
            Text("Number \(n)").font(.system(size: 48, weight: .bold, design: .rounded))
            HStack {
                NavigationLink("Next", value: Route.number(n + 1))
                Button("Close") { onClose() }.tint(.red)
            }
        }
        .padding()
        .navigationTitle("#\(n)")
    }
}

struct UserView: View {
    let name: String
    var body: some View {
        List {
            Section("Profile") {
                Label(name.capitalized, systemImage: "person.crop.circle")
                Label("\(Int.random(in: 1...9999)) followers", systemImage: "person.2")
            }
            Section("Actions") {
                NavigationLink("Open Orders", value: Route.detail("orders", Int.random(in: 1...10)))
                NavigationLink("Open Posts", value: Route.detail("posts", Int.random(in: 1...10)))
            }
        }
        .navigationTitle("@\(name)")
    }
}

struct DetailView: View {
    let kind: String
    let id: Int
    var body: some View {
        VStack(spacing: 16) {
            Text("\(kind.capitalized) #\(id)").font(.title.bold())
            Text(UUID().uuidString).font(.footnote.monospaced())
        }
        .padding()
        .navigationTitle("\(kind)#\(id)")
    }
}

PlaygroundSupport.PlaygroundPage.current.setLiveView(ContentView())
