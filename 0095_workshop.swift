/*
VoiceOver Actions — Custom rotor actions and hints.
Provide adjustable and custom actions for nonstandard controls.
Announce state changes and offer meaningful hints.
Try swipe up/down and explore the actions rotor.
*/

import SwiftUI
import PlaygroundSupport
import UIKit

struct RatingKnob: View {
    @Binding var rating: Int
    @State private var angle: Angle = .degrees(0)
    var body: some View {
        ZStack {
            Circle().fill(.thinMaterial)
            ForEach(0..<5) { i in
                Circle()
                    .fill(i < rating ? .yellow : .gray.opacity(0.3))
                    .frame(width: 18, height: 18)
                    .offset(y: -60)
                    .rotationEffect(.degrees(Double(i) * 72))
            }
            Text("\(rating)")
                .font(.system(size: 44, weight: .bold, design: .rounded))
        }
        .frame(width: 160, height: 160)
        .gesture(DragGesture(minimumDistance: 0).onChanged { g in
            let v = CGVector(dx: g.location.x - 80, dy: g.location.y - 80)
            var deg = atan2(v.dy, v.dx) * 180 / .pi + 90
            if deg < 0 { deg += 360 }
            let step = Int((deg / 360) * 5) + 1
            rating = min(5, max(1, step))
        })
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Rating")
        .accessibilityValue("\(rating) of 5")
        .accessibilityAdjustableAction { d in
            switch d { case .increment: rating = min(5, rating + 1)
            case .decrement: rating = max(1, rating - 1)
            default: break }
            UIAccessibility.post(notification: .announcement, argument: "Rating \(rating)")
        }
    }
}

struct ContentView: View {
    @State private var rating: Int = 3
    @State private var isFavorite = false
    var body: some View {
        VStack(spacing: 20) {
            Text("VoiceOver Actions").font(.largeTitle.bold())
            RatingKnob(rating: $rating)
                .accessibilityHint("Swipe up or down to change")
                .accessibilityAction(named: Text("Max")) { rating = 5 }
                .accessibilityAction(named: Text("Min")) { rating = 1 }
                .accessibilityAction(named: Text("Toggle Favorite")) { isFavorite.toggle() }
            HStack {
                Button {
                    isFavorite.toggle()
                    UIAccessibility.post(notification: .announcement, argument: isFavorite ? "Marked as favorite" : "Removed favorite")
                } label: { Label(isFavorite ? "Favorited" : "Favorite", systemImage: isFavorite ? "heart.fill" : "heart") }
                .buttonStyle(.borderedProminent)
                .accessibilityHint("Marks this item as a favorite")
                Spacer()
                Text("Rotor: swipe up/down on the knob").font(.footnote).foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            Spacer()
        }
        .padding(20)
        .frame(width: 420, height: 700)
    }
}

PlaygroundPage.current.setLiveView(ContentView())
