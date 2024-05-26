/*
SwiftUI State & Binding — One-way data flow with @State and @Binding.
Parent owns the source of truth; children mutate via bindings only.
Demonstrates value propagation across nested views.
Focus: @State, @Binding, value vs. reference semantics.
*/

import SwiftUI
import PlaygroundSupport

struct Knob: View {
    @Binding var value: Double
    var label: String
    var range: ClosedRange<Double> = 0...1
    var body: some View {
        VStack(spacing: 8) {
            Slider(value: $value, in: range)
            HStack {
                Text(label).font(.footnote)
                Spacer()
                Text(value.formatted(.number.precision(.fractionLength(2))).description)
                    .font(.caption.monospaced())
            }
        }
        .padding(12)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct ToggleRow: View {
    @Binding var isOn: Bool
    var text: String
    var body: some View {
        HStack {
            Toggle(isOn: $isOn) { Text(text) }.toggleStyle(.switch)
            Spacer()
            Circle().fill(isOn ? .green : .gray.opacity(0.2)).frame(width: 10, height: 10)
        }
        .padding(12)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct Meter: View {
    var volume: Double
    var brightness: Double
    var enabled: Bool
    var body: some View {
        VStack(spacing: 12) {
            ProgressView(value: volume)
            ProgressView(value: brightness)
            HStack {
                Text("Enabled").font(.footnote)
                Spacer()
                Text(enabled ? "Yes" : "No").font(.caption).foregroundStyle(enabled ? .green : .secondary)
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct ParentView: View {
    @State private var volume = 0.25
    @State private var brightness = 0.5
    @State private var enabled = true
    var body: some View {
        VStack(spacing: 16) {
            Text("State & Binding")
                .font(.title2.weight(.semibold))
            HStack(spacing: 12) {
                Knob(value: $volume, label: "Volume", range: 0...1)
                Knob(value: $brightness, label: "Brightness", range: 0...1)
            }
            ToggleRow(isOn: $enabled, text: "Feature Enabled")
            Meter(volume: volume, brightness: brightness, enabled: enabled)
            HStack {
                Button("Randomize") {
                    volume = Double.random(in: 0...1)
                    brightness = Double.random(in: 0...1)
                }
                .buttonStyle(.borderedProminent)
                Button("Reset") {
                    volume = 0.25; brightness = 0.5; enabled = true
                }
            }
        }
        .padding(20)
        .frame(minWidth: 420, minHeight: 420)
    }
}

func liveView<V: View>(_ view: V) {
    PlaygroundPage.current.setLiveView(UIHostingController(rootView: AnyView(view)))
    PlaygroundPage.current.needsIndefiniteExecution = true
}

liveView(ParentView())
