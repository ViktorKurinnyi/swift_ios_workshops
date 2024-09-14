/*
Custom Layout Protocol — Implement a bespoke layout container.
Build a flowing chip layout with SwiftUI’s Layout API.
Control line-breaking, spacing, and alignment.
Interactive demo to tweak width and spacing.
*/
import SwiftUI
import PlaygroundSupport

struct Flow: Layout {
    var spacing: CGFloat = 8
    var lineSpacing: CGFloat = 8
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.replacingUnspecifiedDimensions().width
        var x: CGFloat = 0
        var y: CGFloat = 0
        var lineHeight: CGFloat = 0
        for s in subviews {
            let size = s.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += lineHeight + lineSpacing
                lineHeight = 0
            }
            lineHeight = max(lineHeight, size.height)
            x += size.width + spacing
        }
        return CGSize(width: maxWidth, height: y + lineHeight)
    }
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let maxWidth = bounds.width
        var x: CGFloat = 0
        var y: CGFloat = 0
        var lineHeight: CGFloat = 0
        for s in subviews {
            let size = s.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += lineHeight + lineSpacing
                lineHeight = 0
            }
            s.place(at: CGPoint(x: bounds.minX + x, y: bounds.minY + y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
    }
}

struct Chip: View, Identifiable, Equatable {
    let id = UUID()
    let text: String
    var body: some View {
        Text(text)
            .font(.system(.body, design: .rounded).weight(.medium))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(RoundedRectangle(cornerRadius: 14).fill(Color.accentColor.opacity(0.15)))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(.secondary.opacity(0.25)))
    }
}

struct ContentView: View {
    @State private var width: CGFloat = 320
    @State private var spacing: CGFloat = 8
    @State private var lineSpacing: CGFloat = 8
    @State private var chips: [Chip] = [
        Chip(text: "SwiftUI"), Chip(text: "Layout"),
        Chip(text: "Flow"), Chip(text: "Animation"),
        Chip(text: "Navigation"), Chip(text: "Grid"),
        Chip(text: "Canvas"), Chip(text: "Timeline"),
        Chip(text: "Combine"), Chip(text: "Concurrency"),
        Chip(text: "Accessibility"), Chip(text: "Testable"),
        Chip(text: "Preview"), Chip(text: "Performance"),
        Chip(text: "Result Builders"), Chip(text: "Protocols"),
        Chip(text: "Generics"), Chip(text: "Actors")
    ]
    var body: some View {
        VStack(spacing: 16) {
            controls
            ScrollView {
                Flow(spacing: spacing, lineSpacing: lineSpacing) {
                    ForEach(chips) { c in
                        c
                            .contextMenu {
                                Button("Promote") {
                                    withAnimation(.spring()) {
                                        if let i = chips.firstIndex(where: { $0.id == c.id }) { chips.move(fromOffsets: IndexSet(integer: i), toOffset: 0) }
                                    }
                                }
                                Button("Remove", role: .destructive) {
                                    withAnimation(.easeInOut) {
                                        chips.removeAll { $0.id == c.id }
                                    }
                                }
                            }
                    }
                }
                .frame(width: width, alignment: .leading)
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                .animation(.spring(response: 0.35, dampingFraction: 0.85), value: chips)
                .animation(.spring(response: 0.35, dampingFraction: 0.85), value: width)
                .padding()
            }
            HStack {
                Button("Shuffle") {
                    withAnimation(.snappy) { chips.shuffle() }
                }
                Button("Add") {
                    withAnimation(.snappy) {
                        let nouns = ["Edge","Pulse","Wave","Beam","Loop","Scope","Stack","Orbit","Nimbus","Quartz"]
                        let adjs = ["Quick","Tiny","Bold","Smart","Swift","Neat","Calm","Sunny","Warm","Cool"]
                        chips.append(Chip(text: "\(adjs.randomElement()!) \(nouns.randomElement()!)"))
                    }
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    var controls: some View {
        VStack {
            HStack {
                Text("Width")
                Slider(value: $width, in: 240...520)
                Text("\(Int(width))").monospacedDigit().frame(width: 56, alignment: .trailing)
            }
            HStack {
                Text("Spacing")
                Slider(value: $spacing, in: 0...24)
                Text("\(Int(spacing))").monospacedDigit().frame(width: 56, alignment: .trailing)
            }
            HStack {
                Text("Line Spacing")
                Slider(value: $lineSpacing, in: 0...24)
                Text("\(Int(lineSpacing))").monospacedDigit().frame(width: 56, alignment: .trailing)
            }
        }
    }
}

PlaygroundSupport.PlaygroundPage.current.setLiveView(ContentView())
