/*
Grid & Adaptive Layout — Build responsive grids with minimal code.
Learn adaptive LazyVGrid, dynamic sizing, and spacing controls.
Shows live resizing, selection, and smooth transitions.
Works in a Swift Playground without external assets.
*/
import SwiftUI
import PlaygroundSupport

struct Item: Identifiable, Hashable {
    let id = UUID()
    let color: Color
    let number: Int
    
    static func == (lhs: Item, rhs: Item) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

struct GridCell: View {
    let item: Item
    let selected: Bool
    let aspect: CGFloat
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(item.color.opacity(selected ? 0.9 : 0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(selected ? Color.primary : Color.clear, lineWidth: 2)
                )
            Text("\(item.number)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .shadow(radius: 2)
        }
        .aspectRatio(aspect, contentMode: .fit)
        .contentShape(Rectangle())
    }
}

struct ContentView: View {
    @State private var minCell: CGFloat = 90
    @State private var spacing: CGFloat = 8
    @State private var aspect: CGFloat = 1
    @State private var selection = Set<Item>()
    private let items: [Item] = (1...60).map { i in
        let hue = Double(i) / 60.0
        return Item(color: Color(hue: hue, saturation: 0.6, brightness: 0.9), number: i)
    }
    var cols: [GridItem] { [GridItem(.adaptive(minimum: minCell), spacing: spacing)] }
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                controls
                ScrollView {
                    LazyVGrid(columns: cols, spacing: spacing) {
                        ForEach(items) { item in
                            GridCell(item: item, selected: selection.contains(item), aspect: aspect)
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                        if selection.contains(item) { selection.remove(item) } else { selection.insert(item) }
                                    }
                                }
                        }
                    }
                    .padding(spacing)
                }
            }
            .navigationTitle("Adaptive Grid")
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button(selection.isEmpty ? "Select All" : "Clear") {
                        if selection.isEmpty { selection = Set(items) } else { selection.removeAll() }
                    }
                    .buttonStyle(.bordered)
                    Spacer()
                    Text("\(selection.count) selected")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    var controls: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Min Width")
                Slider(value: $minCell, in: 60...180, step: 1)
                Text("\(Int(minCell))")
                    .monospacedDigit()
                    .frame(width: 44, alignment: .trailing)
            }
            HStack {
                Text("Spacing")
                Slider(value: $spacing, in: 0...20, step: 1)
                Text("\(Int(spacing))")
                    .monospacedDigit()
                    .frame(width: 44, alignment: .trailing)
            }
            HStack {
                Text("Aspect")
                Slider(value: $aspect, in: 0.6...1.6, step: 0.05)
                Text(String(format: "%.2f", aspect))
                    .monospacedDigit()
                    .frame(width: 44, alignment: .trailing)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
        .padding(.top)
    }
}

func liveView<V: View>(_ view: V) {
    PlaygroundPage.current.setLiveView(UIHostingController(rootView: AnyView(view)))
    PlaygroundPage.current.needsIndefiniteExecution = true
}

liveView(ContentView())
