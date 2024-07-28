/*
Preference Keys — Pass layout info up the view tree.
Children write values; parents read and react with onPreferenceChange.
Demonstrates measuring child sizes and computing a summary.
Focus: custom PreferenceKey and GeometryReader writers.
*/

import SwiftUI
import PlaygroundSupport

struct SizePrefKey: PreferenceKey {
    static var defaultValue: [CGFloat] = []
    static func reduce(value: inout [CGFloat], nextValue: () -> [CGFloat]) {
        value += nextValue()
    }
}

struct Measure: View {
    var body: some View {
        GeometryReader { proxy in
            Color.clear
                .preference(key: SizePrefKey.self, value: [proxy.size.height])
        }
    }
}

struct Row: View {
    var title: String
    var color: Color
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12).fill(color.opacity(0.2))
            HStack {
                Text(title).font(.headline)
                Spacer()
                Text(Date().formatted(date: .abbreviated, time: .shortened))
                    .font(.caption.monospaced())
            }
            .padding(.horizontal, 12)
        }
        .frame(height: CGFloat(Int.random(in: 36...72)))
        .overlay(Measure())
    }
}

struct PreferenceDemo: View {
    @State private var heights: [CGFloat] = []
    var average: CGFloat { heights.isEmpty ? 0 : heights.reduce(0,+) / CGFloat(heights.count) }
    var body: some View {
        VStack(spacing: 16) {
            Text("Preference Keys").font(.title2.weight(.semibold))
            VStack(spacing: 8) {
                ForEach(0..<6, id: \.self) { i in
                    Row(title: "Row \(i+1)", color: .blue)
                }
            }
            .onPreferenceChange(SizePrefKey.self) { heights = $0 }
            .padding(6)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            VStack(alignment: .leading, spacing: 8) {
                Text("Measured \(heights.count) rows")
                Text("Average height: \(Int(average))pt")
                ProgressView(value: min(1, average / 72))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            Button("Refresh") { heights = []; }
        }
        .padding(20)
        .frame(minWidth: 520, minHeight: 480)
    }
}

func liveView<V: View>(_ view: V) {
    PlaygroundPage.current.setLiveView(UIHostingController(rootView: AnyView(view)))
    PlaygroundPage.current.needsIndefiniteExecution = true
}

liveView(PreferenceDemo())
