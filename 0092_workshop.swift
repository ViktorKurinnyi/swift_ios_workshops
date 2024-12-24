/*
Styling & Theming — Build reusable styles and color schemes.
Create a tiny design system with semantic colors and control styles.
Switch light/dark and see components adapt automatically.
All SwiftUI; no assets needed.
*/

import SwiftUI
import PlaygroundSupport

enum Brand {
    static let corner: CGFloat = 14
    static let spacing: CGFloat = 12
    static let gradient = LinearGradient(colors: [.indigo, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
    static func bg(_ scheme: ColorScheme) -> Color { scheme == .dark ? .black : .white }
    static func text(_ scheme: ColorScheme) -> Color { scheme == .dark ? .white : .black }
    static func surface(_ scheme: ColorScheme) -> Color { scheme == .dark ? .gray.opacity(0.15) : .gray.opacity(0.06) }
    static func accent(_ scheme: ColorScheme) -> Color { .blue }
}

struct PrimaryButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .background(Brand.gradient.opacity(configuration.isPressed ? 0.7 : 1))
            .clipShape(RoundedRectangle(cornerRadius: Brand.corner, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: Brand.corner, style: .continuous).strokeBorder(.white.opacity(0.2)))
            .shadow(radius: configuration.isPressed ? 2 : 8, y: configuration.isPressed ? 1 : 6)
            .foregroundStyle(.white)
            .font(.headline.weight(.semibold))
            .animation(.snappy, value: configuration.isPressed)
    }
}

struct CapsuleToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            ZStack(alignment: configuration.isOn ? .trailing : .leading) {
                Capsule().fill(configuration.isOn ? .green.opacity(0.8) : .gray.opacity(0.4))
                Circle().fill(.white).padding(3)
            }
            .frame(width: 60, height: 34)
            .animation(.spring(duration: 0.25), value: configuration.isOn)
            .onTapGesture { configuration.isOn.toggle() }
        }
    }
}

struct Card<Content: View>: View {
    @Environment(\.colorScheme) private var scheme
    var title: String
    var content: Content
    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    var body: some View {
        VStack(alignment: .leading, spacing: Brand.spacing) {
            Text(title).font(.headline)
            content
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Brand.surface(scheme))
        .clipShape(RoundedRectangle(cornerRadius: Brand.corner, style: .continuous))
    }
}

struct ContentView: View {
    @State private var isDark = false
    @State private var notify = true
    @State private var volume: Double = 0.6
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Theme").font(.largeTitle.bold())
                Spacer()
                Toggle("", isOn: $isDark).toggleStyle(SwitchToggleStyle())
            }
            .padding(.bottom, 4)
            Card("Playback") {
                VStack(alignment: .leading, spacing: 12) {
                    Toggle("Notifications", isOn: $notify).toggleStyle(CapsuleToggleStyle())
                    HStack {
                        Image(systemName: "speaker.fill")
                        Slider(value: $volume, in: 0...1)
                        Image(systemName: "speaker.wave.3.fill")
                    }
                }
            }
            Card("Actions") {
                VStack(spacing: 12) {
                    Button {
                    } label: { Label("Play Now", systemImage: "play.fill") }
                    .buttonStyle(PrimaryButton())
                    Button {
                    } label: { Label("Add to Queue", systemImage: "text.badge.plus") }
                    .buttonStyle(PrimaryButton())
                }
            }
            Spacer(minLength: 0)
        }
        .padding(20)
        .foregroundStyle(Brand.text(isDark ? .dark : .light))
        .background(Brand.bg(isDark ? .dark : .light).gradient.opacity(0.9))
        .preferredColorScheme(isDark ? .dark : .light)
        .tint(Brand.accent(isDark ? .dark : .light))
        .frame(maxWidth: 520, maxHeight: 700)
    }
}

PlaygroundPage.current.setLiveView(ContentView())
