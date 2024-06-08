/*
EnvironmentObject — Inject shared models and avoid singleton traps.
One Store feeds multiple screens without manual plumbing.
Demonstrates mutation from deep child and automatic updates.
Focus: environment propagation and dependency inversion.
*/

import SwiftUI
import PlaygroundSupport
import Combine

final class TodoStore: ObservableObject {
    struct Item: Identifiable, Hashable {
        let id = UUID()
        var title: String
        var done: Bool
    }
    @Published var items: [Item] = [
        .init(title: "Prototype UI", done: false),
        .init(title: "Wire up model", done: false),
        .init(title: "Ship Playground", done: false)
    ]
    func add(_ title: String) { items.append(.init(title: title, done: false)) }
    func toggle(_ id: Item.ID) {
        guard let i = items.firstIndex(where: { $0.id == id }) else { return }
        items[i].done.toggle()
    }
    var remaining: Int { items.filter{ !$0.done }.count }
}

struct TodoRow: View {
    @EnvironmentObject var store: TodoStore
    var item: TodoStore.Item
    var body: some View {
        HStack {
            Image(systemName: item.done ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(item.done ? .green : .secondary)
                .onTapGesture { store.toggle(item.id) }
            Text(item.title).strikethrough(item.done)
            Spacer()
        }
        .padding(.vertical, 6)
    }
}

struct AddBar: View {
    @EnvironmentObject var store: TodoStore
    @State private var text = ""
    var body: some View {
        HStack {
            TextField("New item", text: $text)
            Button("Add") { guard !text.isEmpty else { return }; store.add(text); text = "" }
        }
        .textFieldStyle(.roundedBorder)
        .padding(12)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct SummaryView: View {
    @EnvironmentObject var store: TodoStore
    var body: some View {
        HStack {
            Text("Remaining").font(.caption)
            Spacer()
            Text("\(store.remaining)")
                .font(.title2.weight(.bold))
                .contentTransition(.numericText())
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct TodoListScreen: View {
    @EnvironmentObject var store: TodoStore
    var body: some View {
        VStack(spacing: 16) {
            Text("EnvironmentObject Todo")
                .font(.title2.weight(.semibold))
            AddBar()
            SummaryView()
            List {
                ForEach(store.items) { item in
                    TodoRow(item: item)
                }
            }
            .listStyle(.plain)
            .frame(minHeight: 220)
        }
        .padding(20)
        .frame(minWidth: 420, minHeight: 480)
    }
}

let store = TodoStore()

func liveView<V: View>(_ view: V) {
    PlaygroundPage.current.setLiveView(UIHostingController(rootView: AnyView(view.environmentObject(store))))
    PlaygroundPage.current.needsIndefiniteExecution = true
}

liveView(TodoListScreen())
