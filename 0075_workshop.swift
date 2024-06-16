/*
Observation @Observable — Replace boilerplate with automatic change tracking.
Use @Observable models and @Bindable to edit nested state.
No Publishers or objectWillChange needed.
Focus: modern Observation framework (Xcode 15+).
*/

import SwiftUI
import PlaygroundSupport
import Observation

@Observable
final class Settings {
    var username: String = "pat"
    var notifications: Bool = true
    var volume: Double = 0.7
    var theme: Theme = .system
    enum Theme: String, CaseIterable, Identifiable { case system, light, dark; var id: String { rawValue } }
}

struct SettingsEditor: View {
    @Bindable var settings: Settings
    var body: some View {
        Form {
            Section("Profile") {
                TextField("Username", text: $settings.username)
                Toggle("Notifications", isOn: $settings.notifications)
            }
            Section("Playback") {
                Slider(value: $settings.volume, in: 0...1)
                HStack { Text("Volume"); Spacer(); Text(settings.volume.formatted(.number.precision(.fractionLength(2)))) }
            }
            Section("Appearance") {
                Picker("Theme", selection: $settings.theme) {
                    ForEach(Settings.Theme.allCases) { t in Text(t.rawValue.capitalized).tag(t) }
                }
                .pickerStyle(.segmented)
            }
        }
    }
}

struct SettingsSummary: View {
    var settings: Settings
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("User: \(settings.username)")
            Text("Notifications: \(settings.notifications ? "On" : "Off")")
            Text("Theme: \(settings.theme.rawValue.capitalized)")
            ProgressView(value: settings.volume).frame(height: 6)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct ObservationDemo: View {
    @State private var settings = Settings()
    var body: some View {
        VStack(spacing: 16) {
            Text("Observation @Observable")
                .font(.title2.weight(.semibold))
            SettingsSummary(settings: settings)
            SettingsEditor(settings: settings)
                .frame(minHeight: 220)
            HStack {
                Button("Randomize") {
                    settings.username = ["pat","sam","lee","ava","kai"].randomElement()!
                    settings.notifications.toggle()
                    settings.volume = Double.random(in: 0...1)
                    settings.theme = Settings.Theme.allCases.randomElement()!
                }
                Button("Reset") { settings = Settings() }
            }
        }
        .padding(20)
        .frame(minWidth: 460, minHeight: 520)
    }
}

func liveView<V: View>(_ view: V) {
    PlaygroundPage.current.setLiveView(UIHostingController(rootView: AnyView(view)))
    PlaygroundPage.current.needsIndefiniteExecution = true
}

liveView(ObservationDemo())
