/*
TabView & Toolbars — Build app chrome that feels native.
Compose multiple tabs with per-tab toolbars and badges.
Demonstrates search field binding and toolbar placement.
Switch tabs programmatically and maintain state.
*/
import SwiftUI
import PlaygroundSupport

struct InboxItem: Identifiable {
    let id = UUID()
    let title: String
    let unread: Bool
}

struct ContentView: View {
    enum Tab { case inbox, explore, settings }
    @State private var tab: Tab = .inbox
    @State private var query: String = ""
    @State private var inbox: [InboxItem] = (1...20).map { InboxItem(title: "Message \($0)", unread: Bool.random()) }
    @State private var toggleA = true
    @State private var toggleB = false
    var unreadCount: Int { inbox.filter(\.unread).count }
    var filteredInbox: [InboxItem] {
        inbox.filter { query.isEmpty ? true : $0.title.localizedCaseInsensitiveContains(query) }
    }
    var body: some View {
        NavigationStack {
            TabView(selection: $tab) {
                if unreadCount > 0 {
                    inboxView
                        .tabItem { Label("Inbox", systemImage: "tray") }
                        .badge(unreadCount)
                        .tag(Tab.inbox)
                } else {
                    inboxView
                        .tabItem { Label("Inbox", systemImage: "tray") }
                        .tag(Tab.inbox)
                }
                exploreView
                    .tabItem { Label("Explore", systemImage: "safari") }
                    .tag(Tab.explore)
                settingsView
                    .tabItem { Label("Settings", systemImage: "gearshape") }
                    .tag(Tab.settings)
            }
            .navigationTitle(titleFor(tab))
            .toolbar {
                if tab == .inbox {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button("Mark All Read") {
                            withAnimation { inbox = inbox.map { InboxItem(title: $0.title, unread: false) } }
                        }
                    }
                    ToolbarItem(placement: .principal) {
                        TextField("Search Inbox", text: $query).textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 260)
                    }
                }
            }
            .toolbar {
                if tab == .explore {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button("Random") { query = ["SwiftUI","Layout","Canvas","Grid","Navigation"].randomElement()! }
                        Button("Inbox") { tab = .inbox }
                    }
                }
            }
            .toolbar {
                if tab == .settings {
                    ToolbarItemGroup(placement: .bottomBar) {
                        Button("Reset") {
                            query = ""
                            toggleA = true
                            toggleB = false
                        }
                        Spacer()
                        Text("v1.0").foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
    func titleFor(_ t: Tab) -> String {
        switch t { case .inbox: return "Inbox"; case .explore: return "Explore"; case .settings: return "Settings" }
    }
    var inboxView: some View {
        List {
            ForEach(filteredInbox) { item in
                HStack {
                    Circle().fill(item.unread ? .blue : .gray.opacity(0.3)).frame(width: 10, height: 10)
                    Text(item.title)
                    Spacer()
                    if item.unread { Text("NEW").font(.caption2).padding(4).background(.blue.opacity(0.15)).cornerRadius(6) }
                }
            }
        }
    }
    var exploreView: some View {
        VStack(spacing: 16) {
            Text("Search: \(query.isEmpty ? "—" : query)").font(.headline)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(["Swift", "SwiftUI", "Concurrency", "Combine", "Actors", "Layout", "Canvas"], id: \.self) { tag in
                        Button(tag) { query = tag }
                            .buttonStyle(.borderedProminent)
                    }
                }
                .padding(.horizontal)
            }
            Spacer()
        }
        .padding()
    }
    var settingsView: some View {
        Form {
            Toggle("Enable Feature A", isOn: $toggleA)
            Toggle("Enable Feature B", isOn: $toggleB)
            Button("Go To Explore") { tab = .explore }
            Button("Clear Inbox", role: .destructive) { withAnimation { inbox.removeAll() } }
        }
    }
}

PlaygroundSupport.PlaygroundPage.current.setLiveView(ContentView())
