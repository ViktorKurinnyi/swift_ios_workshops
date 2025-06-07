/*
AppStorage & SceneStorage — Persist lightweight state instantly.
UserDefaults-backed @AppStorage and per-scene @SceneStorage.
Close and reopen the live view to see persistence behavior.
Simple counters, theme toggle, and per-tab draft text.
*/

import SwiftUI
import PlaygroundSupport

struct StorageDemo: View {
    @AppStorage("global.counter") private var counter = 0
    @AppStorage("global.isDark") private var isDark = false
    @SceneStorage("tab.index") private var tab = 0
    @SceneStorage("draft.text.0") private var draft0 = ""
    @SceneStorage("draft.text.1") private var draft1 = ""

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Stepper("Counter: \(counter)", value: $counter, in: 0...999).frame(width: 260)
                Toggle("Dark Mode", isOn: $isDark).toggleStyle(.switch)
                Button("Reset All") { counter = 0; isDark = false; draft0 = ""; draft1 = ""; tab = 0 }
                Spacer()
            }
            .padding(.bottom, 4)
            TabView(selection: $tab) {
                DraftEditor(title: "Draft A", text: $draft0).tag(0)
                DraftEditor(title: "Draft B", text: $draft1).tag(1)
            }
            .tabViewStyle(.automatic)
            .frame(height: 360)
            HStack {
                Text("Tab index persists per scene")
                Spacer()
                Text("AppStorage lives across scenes")
            }
            .font(.caption).foregroundStyle(.secondary)
        }
        .padding(20)
        .frame(width: 680, height: 520)
        .preferredColorScheme(isDark ? .dark : .light)
    }
}

struct DraftEditor: View {
    var title: String
    @Binding var text: String
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.title3.weight(.semibold))
            TextEditor(text: $text)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(.quaternary))
                .textInputAutocapitalization(.sentences)
            HStack {
                Text("\(text.count) chars")
                Spacer()
                Button("Lorem") { text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit." }
                Button("Clear") { text.removeAll() }
            }
        }
        .padding(12)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .padding(12)
    }
}

PlaygroundPage.current.setLiveView(StorageDemo())
