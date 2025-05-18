/*
App Lifecycle Events — Scene phases, background, foreground.
Observe scenePhase, log transitions, and pause work when inactive.
Simulate persistence on background and resume on foreground.
Live list of events with timestamps.
*/

import SwiftUI
import PlaygroundSupport

struct LifecycleDemo: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var logs: [String] = []
    @State private var timerRunning = false
    @State private var ticks = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Scene: \(phaseText)").font(.title3.weight(.semibold))
                Spacer()
                Toggle("Timer", isOn: $timerRunning).toggleStyle(.switch)
                Button("Clear") { logs.removeAll(); ticks = 0 }
            }
            .padding(.bottom, 4)
            HStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.teal.opacity(0.2))
                    .frame(height: 120)
                    .overlay(Text("Ticks: \(ticks)").font(.largeTitle.weight(.bold)))
                    .onReceive(timer) { _ in if timerRunning { ticks += 1 } }
                VStack(alignment: .leading) {
                    Button("Simulate Save") { append("Saved state") }
                    Button("Simulate Load") { append("Loaded state") }
                    Button("Background Task") { append("Queued background task") }
                }
                .buttonStyle(.bordered)
                .frame(width: 180)
            }
            .padding(.bottom, 4)
            Divider()
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 6) {
                    ForEach(logs.indices.reversed(), id: \.self) { i in
                        Text(logs[i]).frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
        .padding(20)
        .frame(width: 680, height: 520)
        .onChange(of: scenePhase) { _, newValue in
            append("Phase → \(String(describing: newValue))")
            switch newValue {
            case .active: timerRunning = true; append("Resumed work")
            case .inactive: timerRunning = false; append("Paused animations")
            case .background: timerRunning = false; append("Flushed caches")
            @unknown default: break
            }
        }
        .task {
            append("Launched")
        }
    }

    var phaseText: String { switch scenePhase { case .active: return "active"; case .inactive: return "inactive"; case .background: return "background"; default: return "unknown" } }
    func append(_ s: String) { logs.append("\(Date.now.formatted(date: .omitted, time: .standard))  •  \(s)") }
}

PlaygroundPage.current.setLiveView(LifecycleDemo())
