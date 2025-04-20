/*
Menus & Context Menus — Power user affordances on iPad/Mac.
Right-click or long-press tiles for context actions.
Use a top Menu for bulk operations and filters.
Keyboard shortcuts connect to the same intents.
*/

import SwiftUI
import PlaygroundSupport

struct Tile: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var color: Color
}

struct MenusDemo: View {
    @State private var tiles: [Tile] = (0..<18).map { i in
        Tile(name: "Tile \(i+1)", color: Color(hue: Double(i)/18.0, saturation: 0.55, brightness: 0.9))
    }
    @State private var selection = Set<UUID>()
    @State private var filterWarm = false
    @State private var renameTarget: Tile?
    @State private var showDeleteConfirm = false

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Menu {
                    Button("Select All", action: selectAll)
                    Button("Clear Selection", action: clearSelection)
                    Divider()
                    Toggle("Warm Colors", isOn: $filterWarm)
                    Divider()
                    Button("Shuffle") { tiles.shuffle() }.keyboardShortcut("r", modifiers: [.command])
                } label: {
                    Label("Actions", systemImage: "ellipsis.circle")
                }
                Spacer()
                Text("\(selection.count) selected").foregroundStyle(.secondary)
            }
            .padding(.horizontal, 4)
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                    ForEach(filteredTiles()) { t in
                        TileView(tile: t, isSelected: selection.contains(t.id))
                            .contextMenu {
                                Button("Rename") { renameTarget = t }
                                Button("Duplicate") { duplicate(t) }
                                Button(role: .destructive) { delete(t) } label: { Text("Delete") }
                            }
                            .onTapGesture { toggleSelect(t) }
                    }
                }
                .padding(4)
            }
        }
        .padding(20)
        .frame(width: 680, height: 520)
        .confirmationDialog("Delete selected?", isPresented: $showDeleteConfirm) {
            Button("Delete", role: .destructive) { deleteSelected() }
            Button("Cancel", role: .cancel) { }
        }
        .sheet(item: $renameTarget) { item in
            RenameSheet(name: item.name) { new in rename(item, to: new) }
        }
    }

    func filteredTiles() -> [Tile] {
        guard filterWarm else { return tiles }
        return tiles.filter { $0.color.hueComponent > 0.05 && $0.color.hueComponent < 0.75 }
    }

    func toggleSelect(_ t: Tile) {
        if selection.contains(t.id) { selection.remove(t.id) } else { selection.insert(t.id) }
    }

    func selectAll() { selection = Set(tiles.map { $0.id }) }
    func clearSelection() { selection.removeAll() }
    func duplicate(_ t: Tile) { tiles.insert(Tile(name: t.name + " Copy", color: t.color), at: 0) }
    func delete(_ t: Tile) { tiles.removeAll { $0.id == t.id } }
    func deleteSelected() { tiles.removeAll { selection.contains($0.id) }; selection.removeAll() }
    func rename(_ t: Tile, to newName: String) { if let i = tiles.firstIndex(of: t) { tiles[i].name = newName } }
}

struct TileView: View {
    var tile: Tile
    var isSelected: Bool
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(tile.color)
                .frame(height: 100)
                .overlay(alignment: .topTrailing) {
                    if isSelected { Image(systemName: "checkmark.circle.fill").imageScale(.large).padding(6).foregroundStyle(.white) }
                }
            Text(tile.name).font(.headline).frame(maxWidth: .infinity)
        }
        .padding(8)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct RenameSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State var text: String
    var done: (String) -> Void
    init(name: String, done: @escaping (String) -> Void) { _text = State(initialValue: name); self.done = done }
    var body: some View {
        VStack(spacing: 16) {
            Text("Rename").font(.title2)
            TextField("Name", text: $text).textFieldStyle(.roundedBorder)
            HStack {
                Button("Cancel") { dismiss() }
                Spacer()
                Button("Save") { done(text); dismiss() }.keyboardShortcut(.defaultAction)
            }
        }
        .padding(24)
        .frame(width: 360)
    }
}

extension Color {
    var hueComponent: Double {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        UIColor(self).getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return Double(h)
    }
}

PlaygroundPage.current.setLiveView(MenusDemo())
