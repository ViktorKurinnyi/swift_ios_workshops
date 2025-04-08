/*
Markdown in SwiftUI — Render formatted text with Text(markdown:).
Use headings, lists, code blocks, emphasis, and links.
Switch theme and dynamic type to test rendering.
No UIKit or WebView required.
*/

import SwiftUI
import PlaygroundSupport

struct MarkdownDemo: View {
    @State private var size: DynamicTypeSize = .large
    @State private var dark = false
    @State private var showCode = true

    var body: some View {
        VStack {
            ScrollView {
                Text(makeMarkdown())
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .dynamicTypeSize(size)
            }
            .padding(.bottom, 8)
            HStack {
                Picker("Size", selection: $size) {
                    ForEach(DynamicTypeSize.allCases.filter { $0 <= .accessibility2 }, id: \.self) { s in
                        Text("\(String(describing: s))").tag(s)
                    }
                }
                .pickerStyle(.menu)
                Toggle("Show code", isOn: $showCode).toggleStyle(.switch)
                Toggle("Dark", isOn: $dark).toggleStyle(.switch)
                Spacer()
            }
            .padding(12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .padding(20)
        .frame(width: 680, height: 520)
        .preferredColorScheme(dark ? .dark : .light)
    }

    func makeMarkdown() -> AttributedString {
        let codeBlock = showCode ? """
```swift
struct Greeting: View {
    var body: some View { Text("Hello, Markdown!") }
}
```
""" : ""
        let md = """
# Markdown in SwiftUI

Render **bold**, *italic*, ~~strikethrough~~, `inline code`, and [links](https://developer.apple.com).
- Lists support nested items
    - Including sub-bullets
- Emojis work too 🎉
> Blockquotes are supported and adapt to Dynamic Type.

\(codeBlock)
"""
        return (try? AttributedString(markdown: md)) ?? AttributedString("Failed to parse markdown.")
    }
}

PlaygroundPage.current.setLiveView(MarkdownDemo())
