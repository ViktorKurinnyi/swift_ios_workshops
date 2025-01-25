/*
Dynamic Type & Sizes — Respect user fonts and layouts.
Demonstrate scalable text, minimum scaling, and layout priorities.
Preview different Dynamic Type sizes using controls.
Everything adapts within a single SwiftUI view hierarchy.
*/

import SwiftUI
import PlaygroundSupport

struct Pill: View {
    var text: String
    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(Capsule().fill(.ultraThinMaterial))
    }
}

struct ArticleCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Designing for Dynamic Type")
                .font(.title2.bold())
                .lineLimit(2)
                .minimumScaleFactor(0.7)
                .accessibilityAddTraits(.isHeader)
            Text("Make layouts resilient by embracing larger fonts and content reflow.")
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
            HStack {
                Pill(text: "Accessibility")
                Pill(text: "SwiftUI")
                Spacer()
                Text("7 min")
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(.secondary)
                    .layoutPriority(1)
            }
            HStack(spacing: 12) {
                Label("Read", systemImage: "book.pages.fill")
                    .font(.headline)
                    .padding(.vertical, 10).padding(.horizontal, 16)
                    .background(RoundedRectangle(cornerRadius: 12).fill(.blue.gradient))
                    .foregroundStyle(.white)
                Label("Save", systemImage: "bookmark.fill")
                    .padding(.vertical, 10).padding(.horizontal, 16)
                    .background(RoundedRectangle(cornerRadius: 12).strokeBorder(.secondary))
            }
            .labelStyle(.titleAndIcon)
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(.quaternary.opacity(0.15)))
    }
}

struct ContentView: View {
    @State private var dynSize: DynamicTypeSize = .large
    @State private var columns: Int = 1
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Dynamic Type").font(.largeTitle.bold())
                Spacer()
                Picker("", selection: $dynSize) {
                    ForEach(DynamicTypeSize.allCases, id: \.self) { size in
                        Text(String(describing: size).replacingOccurrences(of: "x", with: " x")).tag(size)
                    }
                }
                .pickerStyle(.menu)
            }
            Stepper("Columns: \(columns)", value: $columns, in: 1...3)
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: columns), spacing: 16) {
                    ForEach(0..<6) { _ in ArticleCard() }
                }
                .padding(.vertical, 6)
            }
            .overlay(alignment: .bottomTrailing) {
                Text("Size: \(String(describing: dynSize))").font(.footnote).padding(8).background(.ultraThinMaterial).clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(20)
        .environment(\.dynamicTypeSize, dynSize)
        .frame(width: 520, height: 720)
    }
}

PlaygroundPage.current.setLiveView(ContentView())
