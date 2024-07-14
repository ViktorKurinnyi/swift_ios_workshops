/*
Layout Fundamentals — Understand stacks, frames, alignment, and spacing.
Compose V/H/Z stacks, control sizing with frames, and tune alignment.
Demonstrates alignment guides and content hugging via fixed vs flexible.
Focus: predictable layout building blocks.
*/

import SwiftUI
import PlaygroundSupport

struct Labeled: View {
    var title: String
    var color: Color
    var body: some View {
        Text(title)
            .font(.headline)
            .padding()
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(color.opacity(0.2), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct AlignmentDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Alignment Guides").font(.headline)
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("Baseline A").font(.largeTitle)
                Text("B").font(.body)
                Text("C").font(.title3)
            }
            HStack(alignment: .center, spacing: 8) {
                Rectangle().fill(.blue.opacity(0.2)).frame(width: 40, height: 40)
                Rectangle().fill(.blue.opacity(0.2)).frame(width: 80, height: 20)
                Rectangle().fill(.blue.opacity(0.2)).frame(width: 20, height: 80)
            }
        }
        .padding(12)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct LayoutDemo: View {
    @State private var expandMiddle = false
    var body: some View {
        VStack(spacing: 16) {
            Text("Layout Fundamentals").font(.title2.weight(.semibold))
            HStack(spacing: 12) {
                Labeled(title: "Fixed", color: .blue)
                    .frame(width: 100)
                Labeled(title: expandMiddle ? "Flexible (max)" : "Flexible", color: .green)
                    .frame(maxWidth: expandMiddle ? .infinity : 160)
                Labeled(title: "Hug", color: .orange)
                    .fixedSize()
            }
            ZStack {
                RoundedRectangle(cornerRadius: 16).fill(.purple.opacity(0.08)).frame(height: 120)
                VStack(spacing: 8) {
                    Text("ZStack overlays and aligns")
                    HStack(spacing: 8) {
                        Circle().fill(.purple.opacity(0.2)).frame(width: 24, height: 24)
                        Circle().fill(.purple.opacity(0.3)).frame(width: 24, height: 24)
                        Circle().fill(.purple.opacity(0.4)).frame(width: 24, height: 24)
                    }
                }
            }
            AlignmentDemo()
            HStack {
                Button(expandMiddle ? "Compact Middle" : "Expand Middle") { withAnimation(.spring()) { expandMiddle.toggle() } }
                Spacer()
                Stepper("Spacing", value: .constant(0))
                    .labelsHidden()
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

liveView(LayoutDemo())
