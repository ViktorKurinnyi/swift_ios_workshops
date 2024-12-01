/*
TimelineView & Canvas — Draw time-varying, vector-based scenes.
Use TimelineView to drive frames and Canvas for custom drawing.
Build an analog clock with tick marks and smooth hands.
Interactive controls for speed and style.
*/
import SwiftUI
import PlaygroundSupport

struct ContentView: View {
    @State private var speed: Double = 1
    @State private var showTicks = true
    @State private var style = 0
    var body: some View {
        VStack(spacing: 16) {
            controls
            TimelineView(.animation(minimumInterval: 1/60)) { timeline in
                let t = timeline.date.timeIntervalSinceReferenceDate * speed
                ClockView(t: t, showTicks: showTicks, style: style)
                    .frame(width: 260, height: 260)
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
            }
            Spacer()
        }
        .padding()
    }
    var controls: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Speed")
                Slider(value: $speed, in: 0.1...8)
                Text(String(format: "%.1fx", speed)).monospacedDigit().frame(width: 56, alignment: .trailing)
            }
            HStack {
                Toggle("Ticks", isOn: $showTicks)
                Picker("Style", selection: $style) {
                    Text("Classic").tag(0); Text("Neumorph").tag(1); Text("Outline").tag(2)
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 280)
            }
        }
    }
}

struct ClockView: View {
    let t: TimeInterval
    let showTicks: Bool
    let style: Int
    var body: some View {
        Canvas { ctx, size in
            let rect = CGRect(origin: .zero, size: size)
            let center = CGPoint(x: rect.midX, y: rect.midY)
            let radius = min(rect.width, rect.height) / 2 - 8
            let second = t.truncatingRemainder(dividingBy: 60)
            let minute = (t / 60).truncatingRemainder(dividingBy: 60)
            let hour = (t / 3600).truncatingRemainder(dividingBy: 12)
            if style == 0 {
                ctx.fill(Path(ellipseIn: rect.insetBy(dx: 6, dy: 6)), with: .color(.white))
                ctx.stroke(Path(ellipseIn: rect.insetBy(dx: 6, dy: 6)), with: .color(.black.opacity(0.1)), lineWidth: 2)
            } else if style == 1 {
                let base = Path(ellipseIn: rect.insetBy(dx: 8, dy: 8))
                ctx.fill(base, with: .linearGradient(.init(colors: [.white, .gray.opacity(0.05)]), startPoint: rect.origin, endPoint: CGPoint(x: rect.maxX, y: rect.maxY)))
                ctx.addFilter(.shadow(color: .black.opacity(0.15), radius: 8, x: 6, y: 6))
                ctx.addFilter(.shadow(color: .white.opacity(0.7), radius: 8, x: -6, y: -6))
            } else {
                ctx.stroke(Path(ellipseIn: rect.insetBy(dx: 6, dy: 6)), with: .color(.secondary), lineWidth: 2)
            }
            if showTicks {
                for i in 0..<60 {
                    let angle = Double(i) / 60 * .pi * 2
                    let isHour = i % 5 == 0
                    let len: CGFloat = isHour ? 14 : 7
                    let w: CGFloat = isHour ? 3 : 1
                    let start = point(center, radius - 20, angle)
                    let end = point(center, radius - 20 - len, angle)
                    var p = Path()
                    p.move(to: start); p.addLine(to: end)
                    ctx.stroke(p, with: .color(.primary.opacity(isHour ? 0.6 : 0.3)), lineWidth: w)
                }
            }
            let sAngle = second / 60 * .pi * 2
            let mAngle = (minute + second/60) / 60 * .pi * 2
            let hAngle = (hour + minute/60) / 12 * .pi * 2
            hand(ctx, center, radius: radius - 50, angle: hAngle, width: 6, color: .primary)
            hand(ctx, center, radius: radius - 30, angle: mAngle, width: 4, color: .primary.opacity(0.8))
            hand(ctx, center, radius: radius - 24, angle: sAngle, width: 2, color: .red)
            ctx.fill(Path(ellipseIn: CGRect(x: center.x - 4, y: center.y - 4, width: 8, height: 8)), with: .color(.primary))
        }
    }
    func hand(_ ctx: GraphicsContext, _ c: CGPoint, radius: CGFloat, angle: Double, width: CGFloat, color: Color) {
        var p = Path()
        p.move(to: c)
        p.addLine(to: point(c, radius, angle))
        ctx.stroke(p, with: .color(color), style: StrokeStyle(lineWidth: width, lineCap: .round))
    }
    func point(_ c: CGPoint, _ r: CGFloat, _ angle: Double) -> CGPoint {
        CGPoint(x: c.x + cos(angle - .pi/2) * r, y: c.y + sin(angle - .pi/2) * r)
    }
}

PlaygroundSupport.PlaygroundPage.current.setLiveView(ContentView())
