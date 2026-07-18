import Foundation
import SwiftUI

/// A category tile shown in the home screen grid.
struct HomeCategory: Identifiable, Hashable {
    let id: UUID
    let name: String
    let symbolName: String
    let tint: Color

    init(
        id: UUID = UUID(),
        name: String,
        symbolName: String,
        tint: Color
    ) {
        self.id = id
        self.name = name
        self.symbolName = symbolName
        self.tint = tint
    }
}

/// A large card in the "In the spotlight" carousel.
struct SpotlightItem: Identifiable, Hashable {
    let id: UUID
    let title: String
    let badge: String
    let metadata: String
    let symbolName: String
    let gradientColors: [Color]

    init(
        id: UUID = UUID(),
        title: String,
        badge: String,
        metadata: String,
        symbolName: String,
        gradientColors: [Color]
    ) {
        self.id = id
        self.title = title
        self.badge = badge
        self.metadata = metadata
        self.symbolName = symbolName
        self.gradientColors = gradientColors
    }
}

/// Tabs in the custom bottom navigation bar.
enum HomeTab: String, CaseIterable, Identifiable {
    case home = "Home"
    case search = "Search"
    case socialize = "Socialize"
    case bookings = "Bookings"
    case profile = "Profile"

    var id: String { rawValue }

    var symbolName: String {
        switch self {
        case .home: return "house.fill"
        case .search: return "magnifyingglass"
        case .socialize: return "person.2.fill"
        case .bookings: return "ticket.fill"
        case .profile: return "person.crop.circle"
        }
    }
}
