/*
MatchedGeometryEffect — Delight with shared transitions.
Animate views moving between hierarchies with a shared namespace.
Toggle layouts and watch shapes and text morph smoothly.
Works with stacks, grids, and overlays.
*/
import SwiftUI
import PlaygroundSupport

struct ContentView: View {
    @Namespace private var ns
    @State private var expanded = false
    @State private var selection = 0
    var body: some View {
        VStack(spacing: 16) {
            header
            ZStack {
                if expanded {
                    detail
                        .transition(.asymmetric(insertion: .opacity.combined(with: .scale(scale: 0.95)), removal: .opacity))
                } else {
                    grid
                        .transition(.opacity)
                }
            }
            .animation(.spring(response: 0.45, dampingFraction: 0.85), value: expanded)
            Spacer()
            controls
        }
        .padding()
    }
    var header: some View {
        HStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(.blue.gradient)
                .frame(width: 48, height: 48)
                .matchedGeometryEffect(id: "icon", in: ns)
            Text("Matched Geometry")
                .font(.title2.weight(.semibold))
                .matchedGeometryEffect(id: "title", in: ns, properties: .position, anchor: .leading, isSource: !expanded)
            Spacer()
            Button(expanded ? "Close" : "Expand") { expanded.toggle() }
                .buttonStyle(.borderedProminent)
        }
    }
    var grid: some View {
        let colors: [Color] = [.pink, .teal, .orange, .purple, .indigo, .green]
        return LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 12) {
            ForEach(0..<12) { i in
                let c = colors[i % colors.count]
                RoundedRectangle(cornerRadius: 16)
                    .fill(c.opacity(0.4))
                    .overlay(
                        Text("\(i + 1)")
                            .font(.headline)
                            .matchedGeometryEffect(id: "num\(i)", in: ns)
                    )
                    .frame(height: 80)
                    .onTapGesture {
                        selection = i
                        withAnimation { expanded = true }
                    }
            }
        }
        .matchedGeometryEffect(id: "container", in: ns)
    }
    var detail: some View {
        VStack(alignment: .leading, spacing: 12) {
            RoundedRectangle(cornerRadius: 24)
                .fill(.blue.opacity(0.25))
                .frame(height: 160)
                .overlay(
                    Text("Card \(selection + 1)")
                        .font(.largeTitle.weight(.bold))
                        .matchedGeometryEffect(id: "num\(selection)", in: ns)
                )
                .matchedGeometryEffect(id: "container", in: ns)
            HStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.blue.gradient)
                    .frame(width: 48, height: 48)
                    .matchedGeometryEffect(id: "icon", in: ns)
                Text("Matched Geometry")
                    .font(.title2.weight(.semibold))
                    .matchedGeometryEffect(id: "title", in: ns, properties: .position, anchor: .leading)
                Spacer()
            }
            Text(lorem)
                .font(.callout)
                .foregroundStyle(.secondary)
            Button("Back") { withAnimation { expanded = false } }
                .buttonStyle(.bordered)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
    }
    var controls: some View {
        EmptyView()
    }
    var lorem: String {
        "Smoothly transition elements between containers using matchedGeometryEffect. It’s great for hero animations, expanding cards, and delightful detail transitions."
    }
}

PlaygroundSupport.PlaygroundPage.current.setLiveView(ContentView())
