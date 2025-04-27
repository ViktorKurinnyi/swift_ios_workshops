/*
Mac Catalyst Considerations — Desktop behaviors from SwiftUI.
Detect Catalyst to tweak layout, hover, and shortcuts.
Present split views and sidebars on desktop, stacks on touch.
One codebase, tailored per environment.
*/

import SwiftUI
import PlaygroundSupport

struct PlatformDemo: View {
    @State private var sidebarWidth: CGFloat = 220
    @State private var selection: Int? = 1
    @State private var hovered = false
    var body: some View {
        Group {
            #if os(macOS) || targetEnvironment(macCatalyst)
            HSplitView {
                Sidebar(selection: $selection).frame(minWidth: 180, idealWidth: sidebarWidth, maxWidth: 300)
                Detail(selection: selection, hovered: $hovered)
            }
            .frame(width: 740, height: 520)
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    HStack {
                        Text("Catalyst/Desktop").font(.headline)
                        Slider(value: $sidebarWidth, in: 180...300, step: 10).frame(width: 160)
                    }
                }
            }
            #else
            NavigationView {
                Sidebar(selection: $selection)
                Detail(selection: selection, hovered: $hovered)
            }
            .navigationViewStyle(.stack)
            .toolbar {
                ToolbarItem(placement: .principal) { Text("Touch Device").font(.headline) }
            }
            .frame(width: 740, height: 520)
            #endif
        }
    }
}

struct Sidebar: View {
    @Binding var selection: Int?
    var body: some View {
        List(selection: $selection) {
            Section("Folders") {
                Label("Inbox", systemImage: "tray").tag(1)
                Label("Starred", systemImage: "star").tag(2)
                Label("Archive", systemImage: "archivebox").tag(3)
            }
        }
        .listStyle(SidebarListStyle())
    }
}

struct Detail: View {
    var selection: Int?
    @Binding var hovered: Bool
    var body: some View {
        VStack(spacing: 16) {
            Text(title).font(.largeTitle.weight(.semibold))
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(hovered ? .blue.opacity(0.25) : .teal.opacity(0.2))
                .frame(height: 260)
                .overlay(Text("Hover on desktop, touch on mobile").font(.title3))
                .onHover { inside in hovered = inside }
            HStack {
                Button("Primary") { }
                    .keyboardShortcut(.defaultAction)
                Button("Delete", role: .destructive) { }
                    .keyboardShortcut(.delete, modifiers: [])
                Button("Find") { }
                    .keyboardShortcut("f", modifiers: [.command])
                Spacer()
                Toggle("Sidebar Dense Mode", isOn: .constant(true))
            }
            .padding(.horizontal)
            Text(platformString)
                .font(.caption).foregroundStyle(.secondary)
        }
        .padding(24)
    }

    var title: String { switch selection { case 2: return "Starred"; case 3: return "Archive"; default: return "Inbox" } }
    var platformString: String {
        #if targetEnvironment(macCatalyst)
        return "Running under Mac Catalyst"
        #elseif os(macOS)
        return "Running as native macOS"
        #elseif os(iOS)
        return "Running on iOS/iPadOS"
        #else
        return "Unknown platform"
        #endif
    }
}

PlaygroundPage.current.setLiveView(PlatformDemo())
