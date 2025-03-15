/*
Gestures Composition — Combine drag, tap, long-press safely.
Build a draggable card with double-tap and press gestures.
Resolve conflicts with highPriority and simultaneous gestures.
Animate state changes and rubber-band edges.
*/

import SwiftUI
import PlaygroundSupport

struct Card: View {
    @State private var offset: CGSize = .zero
    @State private var isPressed = false
    @State private var isSelected = false
    let bounds = CGSize(width: 160, height: 240)
    var body: some View {
        let drag = DragGesture()
            .onChanged { g in
                let x = g.translation.width
                let y = g.translation.height
                let clampedX = max(-120, min(120, x))
                let clampedY = max(-200, min(200, y))
                offset = CGSize(width: clampedX, height: clampedY)
            }
            .onEnded { _ in
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) { offset = .zero }
            }
        let press = LongPressGesture(minimumDuration: 0.25)
            .onEnded { _ in withAnimation(.snappy) { isPressed.toggle() } }
        let doubleTap = TapGesture(count: 2)
            .onEnded { withAnimation(.snappy) { isSelected.toggle() } }
        RoundedRectangle(cornerRadius: 24)
            .fill(isSelected ? AnyShapeStyle(.blue.gradient) : AnyShapeStyle(.thinMaterial))
            .overlay(alignment: .topLeading) {
                HStack(spacing: 8) {
                    Circle().fill(isSelected ? .white : .blue).frame(width: 10, height: 10)
                    Text(isSelected ? "Selected" : "Idle").font(.caption.bold())
                }
                .padding(12)
                .foregroundStyle(isSelected ? .blue : .primary)
            }
            .frame(width: 220, height: 300)
            .scaleEffect(isPressed ? 0.96 : 1)
            .shadow(radius: isPressed ? 4 : 12, y: isPressed ? 2 : 8)
            .offset(offset)
            .highPriorityGesture(doubleTap)
            .simultaneousGesture(press)
            .gesture(drag)
            .overlay(alignment: .bottom) {
                HStack(spacing: 12) {
                    Image(systemName: "hand.draw.fill")
                    Text("Drag • Double-tap selects • Long-press pulses")
                }
                .font(.footnote)
                .padding(12)
                .background(.ultraThinMaterial, in: Capsule())
                .padding(.bottom, 10)
            }
            .animation(.spring(duration: 0.25), value: isSelected)
            .animation(.spring(duration: 0.2), value: isPressed)
    }
}

struct ContentView: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [.purple.opacity(0.2), .blue.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
            VStack(spacing: 20) {
                Text("Gestures").font(.largeTitle.bold())
                Card()
                Spacer()
            }
            .padding(20)
        }
        .frame(width: 520, height: 720)
    }
}

PlaygroundPage.current.setLiveView(ContentView())
