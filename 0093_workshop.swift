/*
Accessibility Labels — Make controls navigable and descriptive.
Apply labels, values, and hints; hide decoration; group logically.
Explore Focus, traits, and reading order to improve UX.
Toggle the state to hear VoiceOver-friendly updates.
*/

import SwiftUI
import PlaygroundSupport

struct ScoreDial: View {
    @Binding var value: Double
    var body: some View {
        ZStack {
            Circle().stroke(.gray.opacity(0.2), lineWidth: 20)
            Circle().trim(from: 0, to: value).stroke(.green, style: StrokeStyle(lineWidth: 20, lineCap: .round)).rotationEffect(.degrees(-90))
            Text("\(Int(value * 100))")
                .font(.system(size: 48, weight: .bold, design: .rounded))
        }
        .frame(width: 180, height: 180)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Score")
        .accessibilityValue("\(Int(value * 100)) percent")
        .accessibilityAdjustableAction { dir in
            switch dir {
            case .increment: value = min(1, value + 0.05)
            case .decrement: value = max(0, value - 0.05)
            default: break
            }
        }
        .accessibilityHint("Swipe up or down to change the score")
    }
}

struct Row: View {
    var icon: String
    var title: String
    var subtitle: String
    var body: some View {
        HStack {
            Image(systemName: icon)
                .imageScale(.large)
                .frame(width: 36, height: 36)
                .accessibilityHidden(true)
            VStack(alignment: .leading) {
                Text(title).font(.headline)
                Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(subtitle)")
    }
}

struct ContentView: View {
    @State private var score: Double = 0.62
    @State private var isPlaying = false
    var body: some View {
        VStack(spacing: 20) {
            Text("Accessible Player").font(.largeTitle.bold())
                .accessibilityAddTraits(.isHeader)
            ScoreDial(value: $score)
            HStack(spacing: 16) {
                Button {
                    isPlaying.toggle()
                } label: {
                    Label(isPlaying ? "Pause" : "Play", systemImage: isPlaying ? "pause.fill" : "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityHint("Double-tap to \(isPlaying ? "pause" : "play")")
                Button {
                    score = min(1, score + 0.1)
                } label: { Label("Boost", systemImage: "bolt.fill").frame(maxWidth: .infinity) }
                .buttonStyle(.bordered)
                .accessibilityLabel("Boost score")
                .accessibilityHint("Increases the score by ten percent")
            }
            .controlSize(.large)
            VStack(spacing: 12) {
                Row(icon: "clock", title: "Timer", subtitle: "30 minutes remaining")
                Row(icon: "speedometer", title: "Pace", subtitle: "Medium intensity")
                Row(icon: "text.book.closed", title: "Guide", subtitle: "Read along mode")
            }
            .accessibilitySortPriority(1)
            Spacer()
            Image(systemName: "music.quarternote.3")
                .font(.system(size: 50))
                .foregroundStyle(.tertiary)
                .accessibilityHidden(true)
        }
        .padding(20)
        .onChange(of: isPlaying) { _, newValue in
            UIAccessibility.post(notification: .announcement, argument: newValue ? "Playing" : "Paused")
        }
    }
}

PlaygroundPage.current.setLiveView(ContentView().frame(width: 420, height: 700))
