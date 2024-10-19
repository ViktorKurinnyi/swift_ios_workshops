/*
Sheets, Popovers, Alerts — Present modals and ephemeral UI.
Trigger and dismiss programmatically with state.
Show sheet with form, popover from a button, and alert with actions.
Mix with NavigationStack to compose flows.
*/
import SwiftUI
import PlaygroundSupport

struct ContentView: View {
    @State private var showSheet = false
    @State private var showPopover = false
    @State private var showAlert = false
    @State private var name = ""
    @State private var count = 1
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Button("Open Sheet") { showSheet = true }
                    .buttonStyle(.borderedProminent)
                Button("Show Popover") { showPopover.toggle() }
                    .popover(isPresented: $showPopover) {
                        VStack(spacing: 12) {
                            Text("Quick Actions").font(.headline)
                            Button("Add 1") { count += 1 }
                            Button("Reset") { count = 0 }
                        }
                        .padding()
                        .frame(minWidth: 220)
                    }
                Button("Confirm Action") { showAlert = true }.tint(.red)
                Text("Count: \(count)").font(.title2.monospacedDigit())
                Spacer()
            }
            .padding()
            .navigationTitle("Modals")
            .sheet(isPresented: $showSheet) {
                FormView(name: $name, count: $count)
            }
            .alert("Are you sure?", isPresented: $showAlert) {
                Button("Delete", role: .destructive) { count = 0 }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This cannot be undone.")
            }
        }
    }
}

struct FormView: View {
    @Binding var name: String
    @Binding var count: Int
    @Environment(\.dismiss) private var dismiss
    @State private var date = Date()
    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Name", text: $name)
                    Stepper("Count: \(count)", value: $count, in: 0...99)
                    DatePicker("When", selection: $date, displayedComponents: [.date, .hourAndMinute])
                }
                Section {
                    Button("Randomize") { count = Int.random(in: 0...99) }
                    Button("Fill Name") { name = ["Alex","Sam","Riley","Jordan","Avery"].randomElement()! }
                }
            }
            .navigationTitle("New Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Save") { dismiss() } }
            }
        }
    }
}

PlaygroundSupport.PlaygroundPage.current.setLiveView(ContentView())
