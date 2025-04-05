/*
Text Rendering & AttributedString — Rich text without UIKit.
Build styled runs, links, small caps, kerning, baseline tweaks.
Mutate attributes live to see dynamic rendering updates.
Works in SwiftUI Playgrounds on iPad (UIKit).
*/

import SwiftUI
import PlaygroundSupport
import UIKit

struct AttributedDemo: View {
    @State private var weight: Font.Weight = .bold
    @State private var kern: Double = 0.8
    @State private var raise: Double = 0.0
    @State private var underline = true
    @State private var smallCaps = true
    @State private var mono = true
    @State private var hue: Double = 0.62

    var body: some View {
        VStack(spacing: 16) {
            Text(makeString())
                .textSelection(.enabled)
                .padding(12)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            Controls(weight: $weight, kern: $kern, raise: $raise, underline: $underline, smallCaps: $smallCaps, mono: $mono, hue: $hue)
            Spacer()
        }
        .padding(20)
        .frame(width: 680, height: 520)
    }

    func makeString() -> AttributedString {
        let s = NSMutableAttributedString()

        // Helpers
        func uiWeight(_ w: Font.Weight) -> UIFont.Weight {
            switch w {
                case .ultraLight: return .ultraLight
                case .thin: return .thin
                case .light: return .light
                case .regular: return .regular
                case .medium: return .medium
                case .semibold: return .semibold
                case .bold: return .bold
                case .heavy: return .heavy
                case .black: return .black
                default: return .regular
            }
        }
        func systemFont(size: CGFloat, weight: Font.Weight, design: UIFontDescriptor.SystemDesign?) -> UIFont {
            var desc = UIFont.systemFont(ofSize: size, weight: uiWeight(weight)).fontDescriptor
            if let design, let d = desc.withDesign(design) { desc = d }
            return UIFont(descriptor: desc, size: size)
        }
        // Small caps feature constants
        let kLowerCaseType = 37
        let kLowerCaseSmallCapsSelector = 3
        let kUpperCaseType = 38
        let kUpperCaseSmallCapsSelector = 1
        func smallCapsFont(from font: UIFont) -> UIFont {
            let settings: [[UIFontDescriptor.FeatureKey: Any]] = [
                [.featureIdentifier: kLowerCaseType, .typeIdentifier: kLowerCaseSmallCapsSelector],
                [.featureIdentifier: kUpperCaseType, .typeIdentifier: kUpperCaseSmallCapsSelector]
            ]
            let desc = font.fontDescriptor.addingAttributes([.featureSettings: settings])
            return UIFont(descriptor: desc, size: font.pointSize)
        }

        // Title: "Swift "
        let titleFont = systemFont(size: 42, weight: weight, design: .rounded)
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: titleFont,
            .foregroundColor: UIColor(hue: CGFloat(hue), saturation: 0.8, brightness: 0.9, alpha: 1.0)
        ]
        s.append(NSAttributedString(string: "Swift ", attributes: titleAttrs))

        // "Typography"
        var typoFont = systemFont(size: 34, weight: .semibold, design: .serif)
        if smallCaps { typoFont = smallCapsFont(from: typoFont) }
        let typoAttrs: [NSAttributedString.Key: Any] = [
            .font: typoFont,
            .kern: kern
        ]
        s.append(NSAttributedString(string: "Typography", attributes: typoAttrs))

        // Newline
        s.append(NSAttributedString(string: "\n", attributes: [:]))

        // Body lead-in: "Build "
        let bodyFont = systemFont(size: 18, weight: .medium, design: .rounded)
        s.append(NSAttributedString(string: "Build ", attributes: [.font: bodyFont]))

        // Code: "AttributedString"
        let codeFont: UIFont = mono
            ? {
                if let desc = UIFont.systemFont(ofSize: UIFont.labelFontSize).fontDescriptor.withDesign(.monospaced) {
                    return UIFont(descriptor: desc, size: 17)
                } else {
                    return UIFont.monospacedSystemFont(ofSize: 17, weight: .regular)
                }
            }()
            : systemFont(size: 17, weight: .regular, design: .rounded)

        let codeAttrs: [NSAttributedString.Key: Any] = [
            .font: codeFont,
            .backgroundColor: UIColor.secondaryLabel.withAlphaComponent(0.1),
            .baselineOffset: raise
        ]
        s.append(NSAttributedString(string: "AttributedString", attributes: codeAttrs))

        // Mid: " with styled runs, "
        s.append(NSAttributedString(string: " with styled runs, ", attributes: [.font: bodyFont]))

        // Link: "links"
        var linkAttrs: [NSAttributedString.Key: Any] = [
            .font: bodyFont,
            .link: URL(string: "https://developer.apple.com/documentation/foundation/attributedstring") as Any
        ]
        if underline { linkAttrs[.underlineStyle] = NSUnderlineStyle.single.rawValue }
        s.append(NSAttributedString(string: "links", attributes: linkAttrs))

        // End: ", and fine typographic control."
        s.append(NSAttributedString(string: ", and fine typographic control.", attributes: [.font: bodyFont]))

        return AttributedString(s)
    }
}

struct Controls: View {
    @Binding var weight: Font.Weight
    @Binding var kern: Double
    @Binding var raise: Double
    @Binding var underline: Bool
    @Binding var smallCaps: Bool
    @Binding var mono: Bool
    @Binding var hue: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Picker("Weight", selection: $weight) {
                    Text("Light").tag(Font.Weight.light)
                    Text("Regular").tag(Font.Weight.regular)
                    Text("Medium").tag(Font.Weight.medium)
                    Text("Bold").tag(Font.Weight.bold)
                    Text("Black").tag(Font.Weight.black)
                }.pickerStyle(.segmented).frame(width: 400)
                Toggle("Underline link", isOn: $underline).toggleStyle(.switch)
            }
            HStack {
                HStack { Text("Kern"); Slider(value: $kern, in: -0.5...2.0) }
                HStack { Text("Baseline"); Slider(value: $raise, in: -4...8) }
                HStack { Text("Hue"); Slider(value: $hue, in: 0...1) }
            }
            HStack {
                Toggle("Small Caps", isOn: $smallCaps)
                Toggle("Monospaced code", isOn: $mono)
                Spacer()
            }
        }
        .font(.callout)
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

PlaygroundPage.current.setLiveView(AttributedDemo())
