/*
Bidirectional Text — Mirror layouts and handle RTL nuances.
Toggle layoutDirection and see stacks, alignment, and symbols flip.
Use text alignment and spacers to keep intent clear in RTL.
Works without external assets; explore mixed-direction text.
*/

import SwiftUI
import PlaygroundSupport

struct RTLBadge: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "arrow.left.and.right")
            Text("Bi-di Ready")
                .font(.caption.weight(.semibold))
        }
        .padding(.vertical, 6).padding(.horizontal, 10)
        .background(Capsule().strokeBorder(.secondary))
    }
}

struct Message: Identifiable {
    let id = UUID()
    let author: String
    let text: String
}

struct ChatBubble: View {
    let message: Message
    let isMe: Bool
    var body: some View {
        HStack {
            if isMe { Spacer() }
            VStack(alignment: .leading, spacing: 6) {
                Text(message.author).font(.caption).foregroundStyle(.secondary)
                Text(message.text)
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 12).fill(isMe ? .blue.opacity(0.15) : .secondary.opacity(0.15)))
            }
            if !isMe { Spacer() }
        }
        .padding(.horizontal)
    }
}

struct ContentView: View {
    @State private var rtl = false
    @State private var messages: [Message] = [
        Message(author: "Ahmad", text: "مرحبا! Welcome to SwiftUI."),
        Message(author: "Sara", text: "Bidirectional النص works fine 🙂"),
        Message(author: "You", text: "Mixing English و العربية in one line.")
    ]
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                RTLBadge()
                Spacer()
                Toggle("RTL", isOn: $rtl).labelsHidden()
            }
            .padding(.horizontal)
            List {
                ForEach(Array(messages.enumerated()), id: \.element.id) { i, m in
                    ChatBubble(message: m, isMe: m.author == "You")
                        .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
            .environment(\.layoutDirection, rtl ? .rightToLeft : .leftToRight)
            VStack(spacing: 8) {
                TextField(rtl ? "اكتب رسالة" : "Type a message", text: .constant(""))
                    .textFieldStyle(.roundedBorder)
                HStack {
                    Label("Attach", systemImage: "paperclip")
                    Spacer()
                    Button {
                    } label: { Label("Send", systemImage: "paperplane.fill") }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(.horizontal)
        }
        .padding(.top, 12)
        .frame(width: 520, height: 720)
        .environment(\.layoutDirection, rtl ? .rightToLeft : .leftToRight)
    }
}

PlaygroundPage.current.setLiveView(ContentView())
