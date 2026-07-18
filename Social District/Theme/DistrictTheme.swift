//
//  DistrictTheme.swift
//  Design tokens for the District-style home screen.
//
//  Centralizes color, radius, spacing, and typography so every component
//  reads from one source. Drop this in first; the other files depend on it.
//

import SwiftUI

enum DistrictTheme {

    // MARK: Color

    enum Palette {
        /// Near-black app background (#101012).
        static let background = Color(red: 0.063, green: 0.063, blue: 0.071)
        /// Elevated card surface, a touch lighter than the background.
        static let surface = Color(red: 0.106, green: 0.106, blue: 0.118)
        /// Search bar / secondary fill, lighter still for contrast.
        static let surfaceRaised = Color(red: 0.145, green: 0.145, blue: 0.157)
        /// Hairline borders on cards.
        static let border = Color.white.opacity(0.07)

        static let textPrimary = Color.white
        static let textSecondary = Color.white.opacity(0.55)
        static let textTertiary = Color.white.opacity(0.38)

        /// Socialize / brand accent.
        static let accent = Color(red: 0.545, green: 0.361, blue: 0.965)      // ~#8B5CF6
        static let accentSoft = Color(red: 0.545, green: 0.361, blue: 0.965).opacity(0.16)
    }

    // MARK: Shape

    enum Radius {
        static let search: CGFloat = 20
        static let card: CGFloat = 24
        static let banner: CGFloat = 24
        static let spotlight: CGFloat = 22
        static let control: CGFloat = 100   // fully rounded circles/pills
    }

    // MARK: Spacing

    enum Space {
        static let screenH: CGFloat = 20    // horizontal screen inset
        static let section: CGFloat = 28    // between major sections
        static let grid: CGFloat = 12       // between grid cells
    }
}

// MARK: - Category accent tints (used inside icon chips)

extension DistrictTheme {
    /// A small vocabulary of tints so the grid feels "colorful" without images.
    enum CategoryTint {
        static let dining = Color(red: 1.00, green: 0.42, blue: 0.36)   // coral
        static let movies = Color(red: 0.55, green: 0.47, blue: 1.00)   // violet
        static let events = Color(red: 0.98, green: 0.66, blue: 0.24)   // amber
        static let stores = Color(red: 0.30, green: 0.78, blue: 0.62)   // teal-green
        static let activities = Color(red: 0.36, green: 0.72, blue: 1.00) // sky
        static let play = Color(red: 0.98, green: 0.45, blue: 0.68)     // pink
    }
}
