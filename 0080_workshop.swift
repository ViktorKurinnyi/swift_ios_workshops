/*
Anchor Preferences — Measure and overlay relative geometry.
Attach anchors in children and resolve them higher in the tree.
Demonstrates a selection highlight drawn using bounds anchors.
Focus: anchors, preference transform, overlay rendering.
*/

import SwiftUI
import PlaygroundSupport

struct BoundsKey: PreferenceKey {
    static var defaultValue: [UUID: Anchor<CGRect>] = [:]
    static func reduce(value: inout [UUID: Anchor<CGRect>], nextValue: () -> [UUID: Anchor<CGRect>]) {
        value.merge(nextValue()) { $1 }
    }
}

struct RowView: View {
    let id: UUID
    var title: String
    var selected: Bool
    var body: some View {
        ZStack(alignment: .leading) {
            HStack {
                Text(title).font(.headline)
                Spacer()
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(selected ? .green : .secondary)
            }
            .padding(.horizontal, 12)
        }
        .frame(height: 44)
        .background(
            GeometryReader { proxy in
                Color.clear
                    .anchorPreference(key: BoundsKey.self, value: .bounds) { [id: $0] }
            }
        )
    }
}

struct AnchorDemo: View {
    @State private var selection: UUID? = nil
    @Namespace private var ns
    let items: [(UUID, String)] = (0..<8).map { (UUID(), "Item \($0 + 1)") }
    var body: some View {
        VStack(spacing: 16) {
            Text("Anchor Preferences").font(.title2.weight(.semibold))
            ZStack(alignment: .topLeading) {
                VStack(spacing: 8) {
                    ForEach(items, id: \.0) { pair in
                        RowView(id: pair.0, title: pair.1, selected: pair.0 == selection)
                            .contentShape(Rectangle())
                            .onTapGesture { withAnimation(.spring()) { selection = pair.0 } }
                    }
                }
                .padding(6)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .overlayPreferenceValue(BoundsKey.self) { dict in
                GeometryReader { proxy in
                    if let sel = selection, let anchor = dict[sel] {
                        let rect = proxy[anchor]
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(.blue, lineWidth: 3)
                            .matchedGeometryEffect(id: "selection", in: ns)
                            .frame(width: rect.width, height: rect.height)
                            .position(x: rect.midX, y: rect.midY)
                            .animation(.spring(), value: selection)
                    }
                }
            }
            HStack {
                Button("Clear") { withAnimation(.spring()) { selection = nil } }
                Spacer()
                Text(selection == nil ? "None" : "Selected").foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding(20)
        .frame(minWidth: 520, minHeight: 520)
    }
}

func liveView<V: View>(_ view: V) {
    PlaygroundPage.current.setLiveView(UIHostingController(rootView: AnyView(view)))
    PlaygroundPage.current.needsIndefiniteExecution = true
}

liveView(AnchorDemo())
