/*
Animations Basics — Implicit/explicit animations and transactions.
Animate state changes with spring/ease curves and control scope.
Use withAnimation, .animation(value:), and transactions.
Demonstrates disabling parts of an animation.
*/
import SwiftUI
import PlaygroundSupport

struct ContentView: View {
    @State private var count = 0
    @State private var enableColor = true
    @State private var enableScale = true
    @State private var explicitSpin = false
    @State private var duration: Double = 0.6
    var body: some View {
        VStack(spacing: 24) {
            HStack(spacing: 20) {
                Circle()
                    .fill(enableColor ? Color(hue: Double(count % 360)/360.0, saturation: 0.8, brightness: 0.9) : .blue)
                    .frame(width: 80, height: 80)
                    .scaleEffect(enableScale ? 1 + CGFloat(count % 5) * 0.12 : 1)
                    .animation(.spring(response: duration, dampingFraction: 0.7), value: count)
                Rectangle()
                    .fill(.mint)
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(explicitSpin ? 180 : 0))
            }
            HStack {
                Button("Increment") {
                    var t = Transaction(animation: .easeInOut(duration: duration))
                    if !enableColor { t.disablesAnimations = true }
                    withTransaction(t) {
                        count += 1
                    }
                }
                Button("Spin") {
                    withAnimation(.bouncy(duration: duration)) { explicitSpin.toggle() }
                }
                Button("Reset") {
                    withAnimation(.snappy) {
                        count = 0
                        explicitSpin = false
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            controls
            Spacer()
            TimelineView(.animation) { timeline in
                let phase = timeline.date.timeIntervalSinceReferenceDate
                Capsule()
                    .fill(.cyan.opacity(0.3))
                    .frame(height: 6)
                    .overlay(alignment: .leading) {
                        GeometryReader { geo in
                            let w = geo.size.width
                            Circle()
                                .frame(width: 10, height: 10)
                                .offset(x: CGFloat((phase.truncatingRemainder(dividingBy: 1))) * (w - 10))
                        }
                    }
                    .padding(.horizontal)
            }
            .frame(height: 20)
        }
        .padding()
    }
    var controls: some View {
        VStack(spacing: 12) {
            HStack {
                Toggle("Color Animations", isOn: $enableColor)
                Toggle("Scale Animations", isOn: $enableScale)
            }
            HStack {
                Text("Duration")
                Slider(value: $duration, in: 0.2...1.5)
                Text(String(format: "%.2fs", duration)).monospacedDigit().frame(width: 56, alignment: .trailing)
            }
        }
    }
}

PlaygroundSupport.PlaygroundPage.current.setLiveView(ContentView())
