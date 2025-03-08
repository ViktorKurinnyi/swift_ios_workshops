/*
Async Images Pipeline — Cache and render progressively (local mock).
Simulate a loader that emits placeholder, low-res, then final symbol.
Actor-backed cache avoids reloading across requests.
Tap to load and observe progressive updates; no network used.
*/

import SwiftUI
import PlaygroundSupport

enum Phase: Equatable {
    case empty
    case low(Image)
    case final(Image)
    case failure
}

actor ImageCache {
    static let shared = ImageCache()
    private var store: [String: Image] = [:]
    func image(for key: String) -> Image? { store[key] }
    func set(_ image: Image, for key: String) { store[key] = image }
}

struct ProgressiveImage: View {
    let key: String
    @State private var phase: Phase = .empty
    var body: some View {
        ZStack {
            switch phase {
            case .empty:
                RoundedRectangle(cornerRadius: 16).fill(.quaternary.opacity(0.2))
                Text("Tap to Load").font(.footnote).foregroundStyle(.secondary)
            case .low(let img):
                img.resizable().scaledToFit().blur(radius: 6).opacity(0.8)
            case .final(let img):
                img.resizable().scaledToFit()
            case .failure:
                VStack { Image(systemName: "exclamationmark.triangle"); Text("Failed") }
            }
        }
        .frame(height: 220)
        .background(RoundedRectangle(cornerRadius: 16).fill(.thinMaterial))
        .task(id: key) {
            if let cached = await ImageCache.shared.image(for: key) {
                phase = .final(cached)
                return
            }
        }
        .onTapGesture { load() }
        .animation(.default, value: phase)
    }
    func load() {
        Task {
            phase = .low(Image(systemName: key))
            try? await Task.sleep(nanoseconds: 400_000_000)
            let final = Image(systemName: key)
            await ImageCache.shared.set(final, for: key)
            phase = .final(final)
        }
    }
}

struct ContentView: View {
    @State private var keys = ["globe.americas.fill", "moon.stars.fill", "photo.on.rectangle.angled", "wifi.router.fill", "person.crop.circle.badge.checkmark"]
    @State private var shuffleToken = 0
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Async Image (Mocked)").font(.largeTitle.bold())
                Spacer()
                Button {
                    keys.shuffle()
                    shuffleToken += 1
                } label: { Label("Shuffle", systemImage: "shuffle") }
            }
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                    ForEach(keys, id: \.self) { k in
                        ProgressiveImage(key: k)
                            .id("\(k)-\(shuffleToken)")
                    }
                }
                .padding(.vertical, 6)
            }
            HStack {
                Button("Clear Cache") {
                    Task { await ImageCache.shared.set(Image(systemName: "trash"), for: "invalid-clears") }
                }
                .buttonStyle(.bordered)
                Spacer()
                Text("Tap tiles to load. Cached items skip blur stage.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
        }
        .padding(20)
        .frame(width: 560, height: 720)
    }
}

PlaygroundPage.current.setLiveView(ContentView())
