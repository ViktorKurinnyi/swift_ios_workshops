/*
View Identity & Diffing — Make updates predictable with id.
Control when subviews are recreated or preserved by switching identity.
Demonstrates .id on a subtree and ForEach identity behavior.
Focus: predictable state resets, transitions, and animations.
*/

import SwiftUI
import PlaygroundSupport

struct StatefulBox: View {
    @State private var taps = 0
    var body: some View {
        VStack(spacing: 8) {
            Text("Taps: \(taps)").font(.headline)
            Button("Tap") { taps += 1 }
                .buttonStyle(.borderedProminent)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .transition(.asymmetric(insertion: .scale, removal: .opacity))
    }
}

struct IdentityDemo: View {
    @State private var seed = 0
    @State private var mode: Mode = .stable
    enum Mode: String, CaseIterable, Identifiable { case stable, reset; var id: String { rawValue } }
    var body: some View {
        VStack(spacing: 16) {
            Text("View Identity & Diffing").font(.title2.weight(.semibold))
            Picker("Mode", selection: $mode) {
                ForEach(Mode.allCases) { Text($0.rawValue.capitalized).tag($0) }
            }.pickerStyle(.segmented)
            HStack(spacing: 12) {
                Group {
                    if mode == .stable {
                        StatefulBox()
                    } else {
                        StatefulBox().id(seed)
                    }
                }
                .frame(width: 180)
                VStack(alignment: .leading) {
                    Button("Trigger Update") { seed += 1 }
                    Text(mode == .stable ? "Keeps state" : "Resets state").foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
            }
            Divider()
            ItemList(seed: seed, resetIdentity: mode == .reset)
            Spacer(minLength: 0)
        }
        .padding(20)
        .frame(minWidth: 520, minHeight: 480)
        .animation(.spring(), value: seed)
        .animation(.spring(), value: mode)
    }
}

struct ItemList: View {
    var seed: Int
    var resetIdentity: Bool
    var items: [Int] {
        (0..<8).map { $0 + seed }.shuffled()
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ForEach Identity").font(.headline)
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(items, id: resetIdentity ? \.self : \Int.hashValue) { n in
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.blue.opacity(0.2))
                            .overlay(Text("\(n)").font(.headline))
                            .frame(width: 60, height: 60)
                            .transition(.opacity)
                    }
                }
                .padding(6)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            Text(resetIdentity ? "Identity: self (shuffles recreate views)" : "Identity: stable (positions change, states persist)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

func liveView<V: View>(_ view: V) {
    PlaygroundPage.current.setLiveView(UIHostingController(rootView: AnyView(view)))
    PlaygroundPage.current.needsIndefiniteExecution = true
}

liveView(IdentityDemo())
