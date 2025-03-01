/*
Images & Symbol Rendering — SF Symbols weights, scales, and palettes.
Experiment with rendering modes, variable colors, and effects.
Compare scale, font weight, hierarchies, and palette fills.
All symbols are system-provided, no assets needed.
*/

import SwiftUI
import PlaygroundSupport

struct SymbolTile: View {
    var name: String
    var mode: SymbolRenderingMode
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: name)
                .symbolRenderingMode(mode)
                .font(.system(size: 42, weight: .regular))
                .imageScale(.large)
                .foregroundStyle(.blue, .mint, .orange)
                .symbolEffect(.pulse.byLayer, options: .repeating, value: String(describing: mode))
            Text(name).font(.footnote.monospaced()).lineLimit(1).minimumScaleFactor(0.6)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(.thinMaterial))
    }
}

struct WeightRow: View {
    let name: String
    var body: some View {
        HStack(spacing: 18) {
            ForEach([Font.Weight.ultraLight, .regular, .semibold, .black], id: \.self) { w in
                Image(systemName: name)
                    .font(.system(size: 36, weight: w))
                    .frame(width: 60, height: 60)
                    .background(RoundedRectangle(cornerRadius: 10).fill(.quaternary.opacity(0.2)))
            }
        }
    }
}

struct ContentView: View {
    @State private var scale: Image.Scale = .large
    @State private var modeIndex: Int = 0
    private let modes: [SymbolRenderingMode] = [.palette, .hierarchical, .monochrome, .multicolor]
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("SF Symbols").font(.largeTitle.bold())
            HStack {
                Picker("Scale", selection: $scale) {
                    Text("Small").tag(Image.Scale.small)
                    Text("Medium").tag(Image.Scale.medium)
                    Text("Large").tag(Image.Scale.large)
                }.pickerStyle(.segmented)
                Picker("Mode", selection: $modeIndex) {
                    Text("Palette").tag(0)
                    Text("Hierarchical").tag(1)
                    Text("Monochrome").tag(2)
                    Text("Multicolor").tag(3)
                }.pickerStyle(.menu)
            }
            HStack(spacing: 12) {
                SymbolTile(name: "bolt.badge.a", mode: modes[modeIndex])
                SymbolTile(name: "wifi.router.fill", mode: modes[modeIndex])
                SymbolTile(name: "heart.circle.fill", mode: modes[modeIndex])
            }
            .environment(\.imageScale, scale)
            VStack(alignment: .leading, spacing: 12) {
                Text("Weights").font(.headline)
                WeightRow(name: "aqi.medium")
                WeightRow(name: "figure.run.circle.fill")
            }
            VStack(alignment: .leading, spacing: 12) {
                Text("Variants").font(.headline)
                HStack(spacing: 16) {
                    Image(systemName: "envelope")
                    Image(systemName: "envelope.badge")
                    Image(systemName: "envelope.open")
                }
                .font(.system(size: 34, weight: .regular))
                HStack(spacing: 16) {
                    Image(systemName: "square.stack.3d.up.badge.a.fill").symbolRenderingMode(.palette)
                    Image(systemName: "square.stack.3d.up.badge.a.fill").symbolRenderingMode(.hierarchical)
                    Image(systemName: "square.stack.3d.up.badge.a.fill").symbolRenderingMode(.monochrome)
                }
                .font(.system(size: 34))
            }
            Spacer()
        }
        .padding(20)
        .frame(width: 560, height: 720)
    }
}

PlaygroundPage.current.setLiveView(ContentView())
