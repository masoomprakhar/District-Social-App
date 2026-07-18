import SwiftUI

// MARK: - Color tokens

extension Color {
    /// Near-black page background — #0E0E10
    static let districtBackground = Color(red: 0.055, green: 0.055, blue: 0.063)
    /// Elevated card surface — #1A1A1D
    static let districtSurface = Color(red: 0.102, green: 0.102, blue: 0.114)
    /// Search bar / lighter fill — #232327
    static let districtSurfaceHigh = Color(red: 0.137, green: 0.137, blue: 0.153)
    /// Hairline stroke
    static let districtStroke = Color.white.opacity(0.07)
    static let districtTextPrimary = Color.white
    static let districtTextSecondary = Color.white.opacity(0.55)
    /// District purple — #8B5CF6, used sparingly (Socialize)
    static let districtPurple = Color(red: 0.545, green: 0.361, blue: 0.965)
    /// Darker end of the Socialize gradient
    static let districtPurpleDeep = Color(red: 0.278, green: 0.176, blue: 0.541)

    // Muted category icon tints
    static let districtCoral = Color(red: 0.949, green: 0.463, blue: 0.412)
    static let districtAmber = Color(red: 0.945, green: 0.690, blue: 0.322)
    static let districtPink = Color(red: 0.918, green: 0.443, blue: 0.612)
    static let districtBlue = Color(red: 0.373, green: 0.557, blue: 0.925)
    static let districtGreen = Color(red: 0.322, green: 0.690, blue: 0.494)
    static let districtTeal = Color(red: 0.263, green: 0.733, blue: 0.694)
}

// MARK: - Typography (scales with Dynamic Type)

extension Font {
    static let districtSectionTitle: Font = .system(.title3, weight: .bold)
    static let districtLocationPrimary: Font = .system(.headline, weight: .semibold)
    static let districtLocationSecondary: Font = .system(.footnote)
    static let districtCardLabel: Font = .system(.subheadline, weight: .semibold)
    static let districtMetadata: Font = .system(.caption, weight: .medium)
    static let districtBadge: Font = .system(.caption2, weight: .semibold)
    static let districtSpotlightTitle: Font = .system(.title2, weight: .heavy)
}

// MARK: - Radii & spacing

enum DistrictRadius {
    static let searchBar: CGFloat = 18
    static let categoryCard: CGFloat = 20
    static let banner: CGFloat = 22
    static let spotlightCard: CGFloat = 24
}

enum DistrictSpacing {
    static let pageInset: CGFloat = 20
    static let section: CGFloat = 26
    static let gridItem: CGFloat = 12
}

// MARK: - Motion

/// Subtle premium press feedback: scale to 0.97 with a soft spring.
struct DistrictPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == DistrictPressStyle {
    static var districtPress: DistrictPressStyle { DistrictPressStyle() }
}
