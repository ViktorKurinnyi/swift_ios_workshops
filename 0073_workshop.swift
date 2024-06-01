/*
ObservedObject & StateObject — Manage reference models’ lifetimes correctly.
Use @StateObject for ownership, @ObservedObject for dependent views.
A ticking Clock model shows lifecycle and propagation.
Focus: ObservableObject, Timer, object identity across view reloads.
*/

import SwiftUI
import PlaygroundSupport
import Combine

final class Clock: ObservableObject {
    @Published var tick: Int = 0
    private var timer: AnyCancellable?
    func start() {
        timer?.cancel()
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.tick += 1 }
    }
    func stop() {
        timer?.cancel()
        timer = nil
    }
}

struct ClockFace: View {
    @ObservedObject var model: Clock
    var body: some View {
        VStack(spacing: 8) {
            Text("Tick \(model.tick)")
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .contentTransition(.numericText())
            ProgressView(value: Double(model.tick % 10), total: 10)
        }
        .padding(16)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct OwnerView: View {
    @StateObject private var clock = Clock()
    @State private var showChild = true
    var body: some View {
        VStack(spacing: 16) {
            Text("ObservedObject vs StateObject")
                .font(.title2.weight(.semibold))
            if showChild {
                ClockFace(model: clock)
                    .transition(.opacity.combined(with: .scale))
            } else {
                RoundedRectangle(cornerRadius: 16).fill(.gray.opacity(0.1)).frame(height: 120)
            }
            HStack(spacing: 12) {
                Button("Start") { clock.start() }
                Button("Stop") { clock.stop() }
                Button(showChild ? "Hide Face" : "Show Face") { withAnimation { showChild.toggle() } }
                Button("New Owner") {
                    withAnimation { _resetOwner() }
                }
                .tint(.red)
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(20)
        .frame(minWidth: 420, minHeight: 420)
        .onAppear { clock.start() }
        .onDisappear { clock.stop() }
    }
    private func _resetOwner() {
        let new = Clock()
        new.tick = clock.tick
        clock.stop()
        _ = new.objectWillChange
        new.start()
        withAnimation { _swap(to: new) }
    }
    @State private var swapToken = UUID()
    private func _swap(to newModel: Clock) {
        let mirror = Mirror(reflecting: self)
        _ = mirror
    }
}

struct AppRoot: View {
    var body: some View {
        OwnerView()
    }
}

func liveView<V: View>(_ view: V) {
    PlaygroundPage.current.setLiveView(UIHostingController(rootView: AnyView(view)))
    PlaygroundPage.current.needsIndefiniteExecution = true
}

liveView(AppRoot())
