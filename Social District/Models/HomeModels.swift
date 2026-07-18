//
//  HomeModels.swift
//  Lightweight models backing the home screen.
//
//  If your project already defines equivalents, delete these and point the
//  views at your existing types — the views only read the fields shown here.
//

import SwiftUI

struct CategoryItem: Identifiable {
    let id = UUID()
    let title: String
    let systemImage: String
    let tint: Color
}

struct SpotlightItem: Identifiable {
    let id = UUID()
    let title: String
    let badge: String
    let meta: String
    let systemImage: String
    let gradient: [Color]
}

// MARK: - Sample content

enum HomeSampleData {
    static let categories: [CategoryItem] = [
        .init(title: "Dining",     systemImage: "fork.knife",       tint: DistrictTheme.CategoryTint.dining),
        .init(title: "Movies",     systemImage: "movieclapper.fill", tint: DistrictTheme.CategoryTint.movies),
        .init(title: "Events",     systemImage: "music.mic",        tint: DistrictTheme.CategoryTint.events),
        .init(title: "Stores",     systemImage: "bag.fill",         tint: DistrictTheme.CategoryTint.stores),
        .init(title: "Activities", systemImage: "figure.hiking",    tint: DistrictTheme.CategoryTint.activities),
        .init(title: "Play",       systemImage: "sportscourt.fill", tint: DistrictTheme.CategoryTint.play),
    ]

    static let spotlight: [SpotlightItem] = [
        .init(title: "Arijit Singh: India Tour",
              badge: "CONCERT",
              meta: "Sat · 7:00 PM · JLN Stadium",
              systemImage: "music.microphone",
              gradient: [Color(red: 0.20, green: 0.16, blue: 0.42), Color(red: 0.42, green: 0.24, blue: 0.62)]),
        .init(title: "Zomaland Food Carnival",
              badge: "FESTIVAL",
              meta: "This weekend · Aerocity",
              systemImage: "takeoutbag.and.cup.and.straw.fill",
              gradient: [Color(red: 0.42, green: 0.16, blue: 0.16), Color(red: 0.66, green: 0.30, blue: 0.18)]),
        .init(title: "Delhi Comic Con",
              badge: "EXPO",
              meta: "Fri–Sun · NSIC Grounds, Okhla",
              systemImage: "sparkles",
              gradient: [Color(red: 0.11, green: 0.28, blue: 0.36), Color(red: 0.16, green: 0.50, blue: 0.52)]),
        .init(title: "The Odyssey",
              badge: "THEATRE",
              meta: "Fri · 7:30 PM · Kamani Auditorium",
              systemImage: "theatermasks.fill",
              gradient: [Color(red: 0.35, green: 0.20, blue: 0.10), Color(red: 0.55, green: 0.35, blue: 0.15)]),
    ]
}
