/*
Focus & Keyboard — Drive focus chains for iPad/Mac.
Build multi-field forms with FocusState and submit handling.
Add keyboard shortcuts and Next/Previous navigation.
Programmatically focus and validate.
*/
import SwiftUI
import PlaygroundSupport

struct ContentView: View {
    enum Field: Hashable { case name, email, password, bio }
    @FocusState private var focus: Field?
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var bio = ""
    @State private var log: [String] = []
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Group {
                    TextField("Name", text: $name)
                        .textContentType(.name)
                        .submitLabel(.next)
                        .focused($focus, equals: .name)
                        .onSubmit { focus = .email }
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .submitLabel(.next)
                        .focused($focus, equals: .email)
                        .onSubmit { focus = .password }
                    SecureField("Password", text: $password)
                        .textContentType(.newPassword)
                        .submitLabel(.next)
                        .focused($focus, equals: .password)
                        .onSubmit { focus = .bio }
                    TextEditor(text: $bio)
                        .frame(height: 100)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(.secondary.opacity(0.2)))
                        .focused($focus, equals: .bio)
                }
                HStack {
                    Button("Prev") { focus = prev(of: focus) }
                    Button("Next") { focus = next(of: focus) }.keyboardShortcut(.tab, modifiers: [.command])
                    Button("Submit") { submit() }.keyboardShortcut(.return, modifiers: [.command])
                }
                .buttonStyle(.borderedProminent)
                List(log, id: \.self) { Text($0).font(.footnote.monospaced()) }
            }
            .padding()
            .navigationTitle("Focus & Keyboard")
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Button("Prev") { focus = prev(of: focus) }
                    Button("Next") { focus = next(of: focus) }
                    Spacer()
                    Button("Done") { focus = nil }
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    Button("Focus Name") { focus = .name }
                    Button("Focus Email") { focus = .email }
                    Button("Clear") {
                        name = ""; email = ""; password = ""; bio = ""; focus = nil; log.removeAll()
                    }
                }
            }
        }
        .onAppear { focus = .name }
    }
    func submit() {
        var issues: [String] = []
        if name.isEmpty { issues.append("Missing name") }
        if !email.contains("@") { issues.append("Invalid email") }
        if password.count < 6 { issues.append("Password too short") }
        if issues.isEmpty { log.append("OK \(Date())") } else { log.append("Errors: \(issues.joined(separator: ", "))") }
    }
    func next(of f: Field?) -> Field? {
        switch f { case .name: return .email; case .email: return .password; case .password: return .bio; default: return nil }
    }
    func prev(of f: Field?) -> Field? {
        switch f { case .bio: return .password; case .password: return .email; case .email: return .name; default: return nil }
    }
}

PlaygroundSupport.PlaygroundPage.current.setLiveView(ContentView())
