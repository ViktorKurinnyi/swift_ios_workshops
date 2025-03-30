/*
ScrollView Tricks — Sticky headers, programmatic scrolling, indicators.
Pinned section headers inside a LazyVStack.
Scroll to items by ID with ScrollViewReader.
Toggle scroll indicators and add a safe-area inset overlay.
*/

import SwiftUI
import PlaygroundSupport

struct Item: Identifiable, Hashable { let id: Int }

struct ScrollTricks: View {
    @State private var items = (0..<120).map { Item(id: $0) }
    @State private var showIndicators = true
    @State private var pinned = true
    @State private var target = 60

    private var pinnedConfig: PinnedScrollableViews { pinned ? [.sectionHeaders] : [] }

    var body: some View {
        VStack(spacing: 0) {
            ControlBar(target: $target, showIndicators: $showIndicators, pinned: $pinned, jump: jump)
                .padding(.bottom, 8)
            Divider()
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: showIndicators) {
                    LazyVStack(alignment: .leading, spacing: 8, pinnedViews: pinnedConfig) {
                        ForEach(0..<6, id: \.self) { section in
                            Section {
                                let base = section * 20
                                ForEach(base..<(base + 20), id: \.self) { i in
                                    Row(id: i).id(i)
                                }
                            } header: {
                                HStack {
                                    Text("Section \(section + 1)").font(.headline).padding(.vertical, 6)
                                    Spacer()
                                    Button("Jump") { withAnimation(.snappy) { proxy.scrollTo(section*20, anchor: .top) } }
                                        .buttonStyle(.borderedProminent)
                                        .font(.caption)
                                }
                                .padding(.horizontal, 12)
                                .background(.ultraThinMaterial)
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                }
                .safeAreaInset(edge: .bottom) {
                    InsetBar(target: $target, jump: { withAnimation(.easeInOut) { proxy.scrollTo(target, anchor: .center) } })
                        .padding(.horizontal, 8)
                        .padding(.bottom, 8)
                        .background(.ultraThinMaterial)
                }
                .onChange(of: target) { _, newValue in
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                        let clamped = max(0, min(newValue, items.count - 1))
                        proxy.scrollTo(clamped, anchor: .center)
                    }
                }
            }
        }
        .frame(width: 640, height: 520)
        .padding(16)
    }

    func jump(_ whereTo: Int, _ proxy: ScrollViewProxy? = nil) {}
}

struct Row: View {
    let id: Int
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8).fill(Color(hue: Double(id % 12) / 12.0, saturation: 0.6, brightness: 0.9))
                .frame(width: 44, height: 44)
                .overlay(Text("\(id)").font(.headline).foregroundStyle(.white))
            VStack(alignment: .leading, spacing: 4) {
                Text("Row #\(id)").font(.headline)
                Text("Scrollable content with pinned headers and programmatic jumps.")
                    .font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right").foregroundStyle(.secondary)
        }
        .padding(10)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct ControlBar: View {
    @Binding var target: Int
    @Binding var showIndicators: Bool
    @Binding var pinned: Bool
    var jump: (Int, ScrollViewProxy?) -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button("Top") { target = 0 }.keyboardShortcut(.home, modifiers: [])
            Button("Middle") { target = 60 }
            Button("Bottom") { target = 119 }.keyboardShortcut(.end, modifiers: [])
            Divider().frame(height: 24)
            Stepper("Target: \(target)", value: $target, in: 0...119, step: 5).frame(width: 210)
            HStack {
                Toggle("Indicators", isOn: $showIndicators).toggleStyle(.switch)
                Toggle("Pinned Headers", isOn: $pinned).toggleStyle(.switch)
            }
            Spacer()
        }
        .font(.callout)
    }
}

struct InsetBar: View {
    @Binding var target: Int
    var jump: () -> Void
    var body: some View {
        HStack {
            Text("Jump to:")
            Slider(value: Binding(get: { Double(target) }, set: { target = Int($0.rounded()) }), in: 0...119)
            Button("Go", action: jump).buttonStyle(.borderedProminent)
        }
        .font(.caption)
    }
}

PlaygroundPage.current.setLiveView(ScrollTricks())
