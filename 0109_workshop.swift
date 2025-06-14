/*
File Import/Export — DocumentPicker mocks and codecs.
Write JSON or plain text to a sandbox folder, then re-import.
No external assets; choose from generated files in a sheet.
Demonstrates Codable, manual codecs, and error handling.
*/

import SwiftUI
import PlaygroundSupport

struct Note: Codable, Identifiable, Equatable {
    var id = UUID()
    var title: String
    var body: String
    var created = Date()
}

struct FileIODemo: View {
    enum Format: String, CaseIterable, Identifiable { case json, txt; var id: String { rawValue } }
    @State private var note = Note(title: "Untitled", body: "Write something insightful…")
    @State private var format: Format = .json
    @State private var files: [URL] = []
    @State private var showImporter = false
    @State private var message = ""

    let dir: URL = {
        let base = FileManager.default.temporaryDirectory.appendingPathComponent("NotesMock", isDirectory: true)
        try? FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)
        return base
    }()

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                TextField("Title", text: $note.title).textFieldStyle(.roundedBorder)
                Picker("Format", selection: $format) { ForEach(Format.allCases) { Text($0.rawValue.uppercased()).tag($0) } }
                    .pickerStyle(.segmented).frame(width: 180)
                Button("Export") { export() }.buttonStyle(.borderedProminent)
                Button("Import") { refresh(); showImporter = true }
                Spacer()
            }
            HStack(spacing: 12) {
                TextEditor(text: $note.body)
                    .frame(minHeight: 180)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(.quaternary))
                VStack(alignment: .leading, spacing: 8) {
                    Text("Files in Mock Folder").font(.headline)
                    ScrollView {
                        LazyVStack(alignment: .leading) {
                            ForEach(files, id: \.self) { url in
                                Text(url.lastPathComponent).font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .frame(width: 240, height: 180)
            }
            .padding(.top, 4)
            HStack {
                Text(message).font(.footnote).foregroundStyle(.secondary)
                Spacer()
                Button("Generate Sample") { note = Note(title: randomTitle(), body: sampleBody()) }
            }
        }
        .padding(20)
        .frame(width: 720, height: 540)
        .onAppear { refresh() }
        .sheet(isPresented: $showImporter) {
            ImportSheet(urls: files) { url in
                importFrom(url)
            }
            .presentationDetents([.medium])
        }
    }

    func refresh() {
        files = (try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: [.contentModificationDateKey], options: [.skipsHiddenFiles]))?.sorted(by: { a, b in
            (try? a.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate ?? .distantPast) ?? .distantPast >
            (try? b.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate ?? .distantPast) ?? .distantPast
        }) ?? []
    }

    func export() {
        let url = dir.appendingPathComponent("\(note.title.replacingOccurrences(of: " ", with: "_"))_\(note.id.uuidString.prefix(6)).\(format.rawValue)")
        do {
            switch format {
            case .json:
                let data = try JSONEncoder().encode(note)
                try data.write(to: url, options: .atomic)
            case .txt:
                try note.body.data(using: .utf8)?.write(to: url, options: .atomic)
            }
            message = "Exported: \(url.lastPathComponent)"
            refresh()
        } catch {
            message = "Export failed: \(error.localizedDescription)"
        }
    }

    func importFrom(_ url: URL) {
        do {
            let data = try Data(contentsOf: url)
            if url.pathExtension.lowercased() == "json" {
                let n = try JSONDecoder().decode(Note.self, from: data)
                note = n
                format = .json
            } else {
                let body = String(decoding: data, as: UTF8.self)
                note = Note(title: url.deletingPathExtension().lastPathComponent, body: body)
                format = .txt
            }
            message = "Imported: \(url.lastPathComponent)"
        } catch {
            message = "Import failed: \(error.localizedDescription)"
        }
    }

    func randomTitle() -> String { ["Ideas", "Journal", "Checklist", "Bug Notes", "Daily Log"].randomElement()! }
    func sampleBody() -> String {
        let lines = [
            "- [ ] Write a Swift snippet",
            "- [ ] Export JSON to sandbox",
            "- [ ] Re-import as note",
            "- [ ] Celebrate with coffee"
        ]
        return lines.joined(separator: "\n")
    }
}

struct ImportSheet: View {
    var urls: [URL]
    var pick: (URL) -> Void
    var body: some View {
        NavigationView {
            List(urls, id: \.self) { url in
                Button(url.lastPathComponent) { pick(url) }
            }
            .navigationTitle("Choose a File")
        }
    }
}

PlaygroundPage.current.setLiveView(FileIODemo())
