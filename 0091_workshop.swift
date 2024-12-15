/*
Drawing & CG in SwiftUI — Paths, shapes, and compositing.
Build layered vector art with Path, Shape, Canvas, and blend modes.
Animate transforms and strokes to explore compositing effects.
This runs in a Playground without assets.
*/

import SwiftUI
import PlaygroundSupport

struct Star: InsettableShape {
    var points: Int = 7
    var insetAmount: CGFloat = 0
    func path(in rect: CGRect) -> Path {
        let r = min(rect.width, rect.height) / 2 - insetAmount
        let c = CGPoint(x: rect.midX, y: rect.midY)
        var path = Path()
        let step = .pi * 2 / CGFloat(points * 2)
        let inner = r * 0.42
        var angle: CGFloat = -(.pi / 2)
        path.move(to: CGPoint(x: c.x + cos(angle) * r, y: c.y + sin(angle) * r))
        for i in 1..<(points * 2) {
            angle += step
            let radius = i.isMultiple(of: 2) ? r : inner
            path.addLine(to: CGPoint(x: c.x + cos(angle) * radius, y: c.y + sin(angle) * radius))
        }
        path.closeSubpath()
        return path
    }
    func inset(by amount: CGFloat) -> some InsettableShape { var s = self; s.insetAmount += amount; return s }
}

struct Lissajous: Shape {
    var a: CGFloat = 3
    var b: CGFloat = 2
    var delta: CGFloat = .pi / 2
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let steps = 1000
        let scale = min(rect.width, rect.height) / 2 * 0.9
        let c = CGPoint(x: rect.midX, y: rect.midY)
        for t in stride(from: 0, through: .pi * 2, by: (.pi * 2) / CGFloat(steps)) {
            let x = sin(a * t + delta) * scale + c.x
            let y = sin(b * t) * scale + c.y
            let pt = CGPoint(x: x, y: y)
            if t == 0 { p.move(to: pt) } else { p.addLine(to: pt) }
        }
        return p
    }
}

struct Waves: Shape {
    var phase: CGFloat
    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let h = rect.midY
        p.move(to: CGPoint(x: rect.minX, y: h))
        let amp = rect.height * 0.22
        let waveLen = rect.width / 3
        for x in stride(from: rect.minX, through: rect.maxX, by: 2) {
            let ang = (x / waveLen + phase) * .pi * 2
            let y = h + sin(ang) * amp * 0.6 + sin(ang * 0.5) * amp * 0.4
            p.addLine(to: CGPoint(x: x, y: y))
        }
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}

struct RotatingStarsCanvas: View {
    var t: CGFloat
    var body: some View {
        Canvas { ctx, size in
            let rect = CGRect(origin: .zero, size: size)
            let base = Star(points: 8).path(in: rect.insetBy(dx: 80, dy: 80))
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let gradient = Gradient(colors: [Color.white.opacity(0.9), Color.blue.opacity(0.2)])
            for i in 0..<12 {
                let rot = CGFloat(i) / 12 * .pi * 2 + t * 0.6
                var trans = CGAffineTransform.identity
                trans = trans.translatedBy(x: center.x, y: center.y)
                trans = trans.rotated(by: rot)
                trans = trans.scaledBy(x: 0.22, y: 0.22)
                let star = base.applying(trans)
                ctx.stroke(star, with: .conicGradient(gradient, center: center), lineWidth: 2)
            }
        }
        .blendMode(.screen)
    }
}

struct LissajousPanel: View {
    var t: CGFloat
    var body: some View {
        let style = StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round, dash: [2, 4], dashPhase: t * 20)
        let gradient = LinearGradient(colors: [.white.opacity(0.9), .cyan.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing)
        return Lissajous(a: 5, b: 4, delta: t)
            .stroke(style: style)
            .foregroundStyle(gradient)
            .frame(height: 300)
            .padding()
            .compositingGroup()
            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 6)
    }
}

struct WavesMaskPanel: View {
    var t: CGFloat
    var body: some View {
        let fillStyle = LinearGradient(colors: [.cyan.opacity(0.5), .mint.opacity(0.3)], startPoint: .top, endPoint: .bottom)
        return ZStack {
            Waves(phase: t)
                .fill(fillStyle)
                .mask(Star(points: 6).inset(by: 8))
                .frame(height: 180)
                .padding(.horizontal)
                .blendMode(.plusLighter)
            Star(points: 6).inset(by: 8)
                .strokeBorder(.white.opacity(0.9), lineWidth: 2)
                .frame(height: 180)
                .padding(.horizontal)
        }
    }
}

struct StarsRow: View {
    var t: CGFloat
    var body: some View {
        let items = Array(0..<5)
        return HStack(spacing: 16) {
            ForEach(items, id: \.self) { i in
                Star(points: 5 + i).inset(by: 4)
                    .fill(.radialGradient(colors: [.white, .clear], center: .center, startRadius: 0, endRadius: 60))
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(Double(i) * 10 + Double(t) * 60))
                    .background(Circle().fill(.ultraThinMaterial).blur(radius: 8))
                    .clipShape(Circle())
            }
        }
        .padding(.top, 8)
    }
}

struct ShapesPanel: View {
    var t: CGFloat
    var body: some View {
        VStack {
            LissajousPanel(t: t)
            WavesMaskPanel(t: t)
            StarsRow(t: t)
        }
        .padding(.bottom, 40)
    }
}

struct MainScene: View {
    var t: CGFloat
    var body: some View {
        ZStack {
            AngularGradient(colors: [.purple, .blue, .mint, .purple], center: .center)
                .ignoresSafeArea()
            RotatingStarsCanvas(t: t)
            ShapesPanel(t: t)
        }
    }
}

struct ContentView: View {
    @State private var t: CGFloat = 0
    var body: some View {
        MainScene(t: t)
            .onAppear {
                withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                    t = 1
                }
            }
    }
}

PlaygroundPage.current.setLiveView(ContentView().frame(width: 420, height: 700))
