/*
Hit Testing & Content Shape — Control interactive regions precisely.
Tap only the star when content shape is restricted to the star path.
Toggle hit testing to see overlapping views steal or ignore touches.
Live SwiftUI demo for Playgrounds on macOS or iPad.
*/

import SwiftUI
import PlaygroundSupport

struct Star: Shape {
    var points: Int = 5
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let r = min(rect.width, rect.height) / 2
        let inner = r * 0.45
        var p = Path()
        var angle = -CGFloat.pi / 2
        let step = .pi * 2 / CGFloat(points * 2)
        var first = true
        for i in 0..<(points * 2) {
            let radius = i % 2 == 0 ? r : inner
            let x = center.x + cos(angle) * radius
            let y = center.y + sin(angle) * radius
            if first { p.move(to: CGPoint(x: x, y: y)); first = false } else { p.addLine(to: CGPoint(x: x, y: y)) }
            angle += step
        }
        p.closeSubpath()
        return p
    }
}

struct HitTestDemo: View {
    @State private var taps = 0
    @State private var onlyStar = true
    @State private var hitEnabled = true
    @State private var starSize: CGFloat = 160
    @State private var overlap = true

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 8) {
                Text("Hits: \(taps)")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                HStack {
                    Toggle("Only star is tappable", isOn: $onlyStar).toggleStyle(.switch)
                    Toggle("Enable overlap hit", isOn: $overlap).toggleStyle(.switch)
                    Toggle("Hit testing ON", isOn: $hitEnabled).toggleStyle(.switch)
                }.font(.callout)
            }
            GeometryReader { geo in
                ZStack {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(LinearGradient(colors: [.purple.opacity(0.25), .blue.opacity(0.25)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    Star(points: 5)
                        .stroke(style: StrokeStyle(lineWidth: 6, lineJoin: .round))
                        .fill(Color.indigo)
                        .frame(width: starSize, height: starSize)
                        .shadow(radius: 4, y: 1)
                        .overlay(
                            Star(points: 5)
                                .fill(LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom))
                                .frame(width: starSize * 0.9, height: starSize * 0.9)
                        )
                        .allowsHitTesting(hitEnabled)
                    if overlap {
                        Circle()
                            .fill(.black.opacity(0.08))
                            .frame(width: starSize * 0.9, height: starSize * 0.9)
                            .offset(x: starSize * 0.35, y: -starSize * 0.35)
                            .overlay(Text("Overlay").font(.footnote).padding(6).background(.ultraThinMaterial).clipShape(Capsule()).offset(x: starSize * 0.35, y: -starSize * 0.35))
                            .allowsHitTesting(false)
                    }
                }
                .contentShape(.interaction, onlyStar ? AnyShape(Star()) : AnyShape(Rectangle()))
                .onTapGesture {
                    taps += 1
                    let strength = taps % 3 == 0 ? 1.0 : 0.5
                    #if os(iOS)
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: CGFloat(strength))
                    #endif
                }
            }
            .frame(height: 300)
            HStack {
                Text("Size")
                Slider(value: $starSize, in: 80...260)
                Button("Reset") { starSize = 160; taps = 0 }
                Spacer()
                Picker("Shape", selection: $onlyStar) {
                    Text("Star only").tag(true)
                    Text("Whole area").tag(false)
                }.pickerStyle(.segmented).frame(width: 240)
            }
            .padding(.horizontal)
            VStack(alignment: .leading, spacing: 8) {
                Text("Notes")
                    .font(.headline)
                Text("• contentShape(.interaction, Star()) restricts taps without changing visuals.")
                Text("• .allowsHitTesting(false) lets views ignore touches while still drawn.")
                Text("• Overlap shows precise hit control when layers intersect.")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .padding(20)
        .frame(width: 640, height: 520)
    }
}

PlaygroundPage.current.setLiveView(HitTestDemo())
