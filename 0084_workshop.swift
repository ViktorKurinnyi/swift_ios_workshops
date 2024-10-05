/*
List Diffing & Identifiable — Efficient lists with stable identities.
Use Identifiable models, animated inserts/deletes/moves, and diff-safe updates.
Demonstrates predictable state even while shuffling or editing.
Includes batch operations to stress test the diffing.
*/
import SwiftUI
import PlaygroundSupport

struct Row: Identifiable, Equatable {
    let id: UUID
    var title: String
    var score: Int
    init(title: String, score: Int) {
        self.id = UUID()
        self.title = title
        self.score = score
    }
}

struct ContentView: View {
    @State private var rows: [Row] = (1...12).map { Row(title: "Player \($0)", score: Int.random(in: 0...100)) }
    @State private var selection: Set<UUID> = []
    var body: some View {
        NavigationStack {
            List(selection: $selection) {
                ForEach(rows) { row in
                    HStack {
                        Circle().fill(Color(hue: Double(abs(row.title.hashValue % 255))/255, saturation: 0.5, brightness: 0.9))
                            .frame(width: 20, height: 20)
                        Text(row.title)
                        Spacer()
                        Text("\(row.score)").monospacedDigit()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if selection.contains(row.id) { selection.remove(row.id) } else { selection.insert(row.id) }
                    }
                }
                .onDelete { idx in
                    withAnimation(.easeInOut) { rows.remove(atOffsets: idx) }
                }
                .onMove { s, d in
                    withAnimation(.spring()) { rows.move(fromOffsets: s, toOffset: d) }
                }
            }
            .navigationTitle("Scores")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) { EditButton() }
                ToolbarItemGroup(placement: .bottomBar) {
                    Button("Shuffle") { withAnimation(.snappy) { rows.shuffle() } }
                    Button("Reseed") {
                        withAnimation(.easeInOut) {
                            rows = rows.map { Row(title: $0.title, score: Int.random(in: 0...100)) }
                        }
                    }
                    Button("Insert 3") { insertMany() }
                    Button("Delete Sel", role: .destructive) {
                        withAnimation(.easeInOut) {
                            rows.removeAll { selection.contains($0.id) }
                            selection.removeAll()
                        }
                    }
                    Spacer()
                    Text("\(rows.count) rows").foregroundStyle(.secondary)
                }
            }
        }
    }
    func insertMany() {
        var additions: [Row] = []
        for _ in 0..<3 {
            let i = Int.random(in: 1...999)
            additions.append(Row(title: "Player \(i)", score: Int.random(in: 0...100)))
        }
        withAnimation(.spring()) {
            let idx = Int.random(in: 0...rows.count)
            rows.insert(contentsOf: additions, at: idx)
        }
    }
}

PlaygroundSupport.PlaygroundPage.current.setLiveView(ContentView())
