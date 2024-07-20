/*
GeometryReader Basics — React to container size and coordinates.
Measure available space and position elements proportionally.
Demonstrates dynamic layout, alignment, and overlay metrics.
Focus: reading geometry for adaptive views.
*/

import SwiftUI
import PlaygroundSupport

struct Bars: View {
    var count: Int
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width / CGFloat(count)
            HStack(alignment: .bottom, spacing: 2) {
                ForEach(0..<count, id: \.self) { i in
                    let h = CGFloat((i + 1)) / CGFloat(count) * geo.size.height
                    Rectangle()
                        .fill(Color.blue.opacity(0.25 + Double(i) / Double(count) * 0.6))
                        .frame(width: w - 2, height: h)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .bottomLeading)
        }
    }
}

struct GeometryDemo: View {
    @State private var count = 12
    @State private var point: CGPoint = .zero
    var body: some View {
        VStack(spacing: 16) {
            Text("GeometryReader Basics").font(.title2.weight(.semibold))
            ZStack {
                RoundedRectangle(cornerRadius: 16).fill(.gray.opacity(0.08)).frame(height: 220)
                    .overlay(
                        Bars(count: count).padding(12)
                    )
                    .gesture(DragGesture(minimumDistance: 0).onChanged { value in point = value.location })
                GeometryReader { proxy in
                    let s = proxy.size
                    let x = max(0, min(point.x, s.width))
                    let y = max(0, min(point.y, s.height))
                    let p = CGPoint(x: x, y: y)
                    let nx = x / s.width
                    let ny = y / s.height
                    Circle()
                        .strokeBorder(.red, lineWidth: 2)
                        .frame(width: 18, height: 18)
                        .position(p)
                        .animation(.default, value: p)
                    VStack(alignment: .trailing) {
                        Text("x: \(Int(nx * 100))%")
                        Text("y: \(Int(ny * 100))%")
                    }
                    .font(.caption.monospaced())
                    .padding(8)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .position(x: s.width - 60, y: 30)
                }
            }
            HStack {
                Stepper("Bars: \(count)", value: $count, in: 3...40)
                Spacer()
                Button("Randomize") { point = CGPoint(x: .random(in: 0...240), y: .random(in: 0...200)) }
            }
            Spacer(minLength: 0)
        }
        .padding(20)
        .frame(minWidth: 520, minHeight: 480)
    }
}

func liveView<V: View>(_ view: V) {
    PlaygroundPage.current.setLiveView(UIHostingController(rootView: AnyView(view)))
    PlaygroundPage.current.needsIndefiniteExecution = true
}

liveView(GeometryDemo())
