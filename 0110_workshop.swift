/*
Undo Managers — Multi-level undo with SwiftUI integration.
Register undo actions as you add, rename, or delete rows.
Provide explicit Undo/Redo buttons and keyboard shortcuts.
Uses Environment undoManager bridged to UIKit/AppKit.
*/

import SwiftUI
import PlaygroundSupport

struct ItemRow: Identifiable, Equatable {
    let id = UUID()
    var title: String
}

final class Store: ObservableObject {
    @Published var items: [ItemRow] = (1...6).map { ItemRow(title: "Item \($0)") }
    @Published var selection: UUID?
    
    func add(undoManager: UndoManager?) {
        let new = ItemRow(title: "New Item")
        items.insert(new, at: 0)
        undoManager?.registerUndo(withTarget: self) { target in
            target.delete(new.id, undoManager: undoManager)
        }
        undoManager?.setActionName("Add Item")
    }
    
    func rename(_ id: UUID, undoManager: UndoManager?) {
        guard let i = items.firstIndex(where: { $0.id == id }) else { return }
        let old = items[i].title
        let new = prompt("Rename", defaultText: old) ?? old
        items[i].title = new
        undoManager?.registerUndo(withTarget: self) { target in
            target.setTitle(id, to: old, undoManager: undoManager)
        }
        undoManager?.setActionName("Rename")
    }
    
    func delete(_ id: UUID, undoManager: UndoManager?) {
        guard let i = items.firstIndex(where: { $0.id == id }) else { return }
        let removed = items.remove(at: i)
        undoManager?.registerUndo(withTarget: self) { target in
            target.insert(removed, at: i, undoManager: undoManager)
        }
        undoManager?.setActionName("Delete")
    }
    
    func setTitle(_ id: UUID, to title: String, undoManager: UndoManager?) {
        if let i = items.firstIndex(where: { $0.id == id }) { items[i].title = title }
    }
    
    func insert(_ row: ItemRow, at index: Int, undoManager: UndoManager?) {
        items.insert(row, at: index)
        undoManager?.registerUndo(withTarget: self) { target in
            target.delete(row.id, undoManager: undoManager)
        }
        undoManager?.setActionName("Insert")
    }
    
    func prompt(_ title: String, defaultText: String) -> String? {
        #if os(iOS)
        return defaultText + " ✓"
        #else
        return defaultText + " ✓"
        #endif
    }
}

struct UndoDemo: View {
    @Environment(\.undoManager) private var undoManager
    @StateObject private var store = Store()
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Button("Add") { store.add(undoManager: undoManager) }.keyboardShortcut("n", modifiers: [.command])
                Button("Rename") { if let id = store.selection { store.rename(id, undoManager: undoManager) } }
                Button("Delete") { if let id = store.selection { store.delete(id, undoManager: undoManager) } }.keyboardShortcut(.delete, modifiers: [])
                Divider().frame(height: 24)
                Button("Undo") { undoManager?.undo() }.keyboardShortcut("z", modifiers: [.command])
                Button("Redo") { undoManager?.redo() }.keyboardShortcut("Z", modifiers: [.command, .shift])
                Spacer()
            }
            .buttonStyle(.borderedProminent)
            .padding(.bottom, 4)
            List(selection: $store.selection) {
                ForEach(store.items) { row in
                    Text(row.title).tag(row.id)
                }
            }
            .frame(height: 360)
            .environment(\.editMode, .constant(.active))
            HStack {
                Text("Items: \(store.items.count)")
                Spacer()
                Text("Select a row to rename or delete")
            }
            .font(.caption).foregroundStyle(.secondary)
        }
        .padding(20)
        .frame(width: 680, height: 520)
    }
}

PlaygroundPage.current.setLiveView(UndoDemo())
