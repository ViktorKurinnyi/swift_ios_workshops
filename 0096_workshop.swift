/*
Localization Basics — String catalogs and plural rules.
Use String(localized:) with defaults and simple plural logic.
Simulate locale switching to see formatting changes.
All fallback strings are English within this Playground.
*/

import SwiftUI
import PlaygroundSupport

struct Localizer {
    static func text(_ key: String, default value: String) -> String {
        NSLocalizedString(key, tableName: nil, bundle: .main, value: value, comment: "")
    }
    static func plural(_ count: Int, one: String, other: String) -> String {
        count == 1 ? one : other.replacingOccurrences(of: "%d", with: String(count))
    }
    static func amount(_ value: Double, locale: Locale) -> String {
        value.formatted(.currency(code: locale.currency?.identifier ?? "USD").presentation(.standard).locale(locale))
    }
}

struct ContentView: View {
    @State private var locale: Locale = .current
    @State private var cartCount: Int = 1
    @State private var total: Double = 19.99
    var body: some View {
        VStack(spacing: 16) {
            Text("Localization").font(.largeTitle.bold())
            Picker("Locale", selection: $locale) {
                Text("English (US)").tag(Locale(identifier: "en_US"))
                Text("Arabic (Egypt)").tag(Locale(identifier: "ar_EG"))
                Text("French (France)").tag(Locale(identifier: "fr_FR"))
                Text("Hindi (India)").tag(Locale(identifier: "hi_IN"))
            }
            .pickerStyle(.segmented)
            VStack(alignment: .leading, spacing: 12) {
                let greeting = Localizer.text("greeting", default: "Welcome")
                Text(greeting).font(.title2.weight(.semibold))
                HStack {
                    Stepper("Items: \(cartCount)", value: $cartCount, in: 0...9)
                    Button("Add") { cartCount = min(9, cartCount + 1) }
                }
                let itemLine = Localizer.plural(cartCount, one: "You have 1 item in the cart.", other: "You have %d items in the cart.")
                Text(itemLine).font(.body)
                HStack {
                    Text("Total")
                    Spacer()
                    Text(Localizer.amount(total, locale: locale)).monospacedDigit()
                }
                .font(.title3)
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 12).fill(.ultraThinMaterial))
                Button {
                    total += 3.5
                } label: { Label("Add a snack", systemImage: "cart.badge.plus") }
                .buttonStyle(.borderedProminent)
            }
            Spacer()
            Text(Localizer.text("footer.note", default: "Strings use defaults if no catalog is present."))
                .font(.footnote).foregroundStyle(.secondary)
        }
        .padding(20)
        .environment(\.locale, locale)
        .frame(width: 520, height: 720)
    }
}

PlaygroundPage.current.setLiveView(ContentView())
