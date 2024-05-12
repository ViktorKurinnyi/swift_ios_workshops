/*
SwiftUI: Minimal App Skeleton — Create a live view that actually renders.
You’ll wire up a tiny app shell that composes views and shows real output.
Runs in an Xcode Playground via PlaygroundSupport live view.
Focus: simple state, actions, scene-style composition.
*/

import SwiftUI
import PlaygroundSupport

struct CounterButton: View {
    var title: String
    var action: () -> Void
    var body: some View {
        Button(title, action: action)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.blue.opacity(0.15), in: Capsule())
    }
}

struct Chip: View {
    var text: String
    var active: Bool
    var body: some View {
        Text(text)
            .font(.footnote.monospaced())
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(active ? .green.opacity(0.25) : .gray.opacity(0.15), in: Capsule())
    }
}

struct DashboardCard<Content: View>: View {
    var title: String
    @ViewBuilder var content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.headline)
            content
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct RootView: View {
    @State private var count = 0
    @State private var toggled = false
    @State private var now = Date()
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Mini Playground App")
                    .font(.title2.weight(.semibold))
                Spacer()
                Chip(text: toggled ? "ON" : "OFF", active: toggled)
            }
            .padding(.top, 4)
            DashboardCard(title: "Counter") {
                HStack(spacing: 12) {
                    CounterButton(title: "-1") { count = max(0, count - 1) }
                    CounterButton(title: "+1") { count += 1 }
                    Toggle(isOn: $toggled) { Text("Toggle") }
                        .toggleStyle(.switch)
                }
                .font(.body)
                Text("Total: \(count)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .contentTransition(.numericText())
            }
            DashboardCard(title: "Timeline") {
                VStack(alignment: .leading, spacing: 8) {
                    Text(now.formatted(date: .abbreviated, time: .standard))
                        .font(.title3.monospaced())
                    ProgressView(value: Double(count % 10), total: 10)
                    HStack {
                        ForEach(0..<10) { i in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(i < count % 10 ? .blue : .gray.opacity(0.2))
                                .frame(width: 12, height: 8)
                        }
                    }.frame(height: 8)
                }
            }
            DashboardCard(title: "Composition") {
                HStack(spacing: 12) {
                    ForEach(0..<min(count, 6), id: \.self) { i in
                        Circle()
                            .fill(Gradient(colors: [.blue, .purple]))
                            .frame(width: 24, height: 24)
                            .overlay(Text("\(i+1)").font(.caption2).foregroundStyle(.white))
                            .transition(.scale.combined(with: .opacity))
                    }
                    Spacer(minLength: 0)
                }
                .animation(.spring(duration: 0.35), value: count)
            }
            Spacer(minLength: 0)
        }
        .padding(20)
        .frame(minWidth: 360, maxWidth: 600, minHeight: 420)
        .background(.background)
        .task {
            for _ in 0..<10_000 {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                now = Date()
            }
        }
    }
}

func liveView<V: View>(_ view: V) {
    PlaygroundPage.current.setLiveView(UIHostingController(rootView: AnyView(view)))
    PlaygroundPage.current.needsIndefiniteExecution = true
}

liveView(RootView())
