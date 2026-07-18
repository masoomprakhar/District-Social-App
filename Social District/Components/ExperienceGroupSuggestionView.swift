import SwiftUI

struct ExperienceGroupSuggestionView: View {
    let listing: SocializeListing
    let suggestion: ExperienceGroupSuggestion
    let isJoined: Bool

    private var savings: Double {
        listing.pricePerPerson * Double(suggestion.discountPercent) / 100
    }

    var body: some View {
        HStack(spacing: 12) {
            AvatarStackView(
                members: suggestion.members,
                maxVisible: 3,
                size: 30
            )

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(suggestion.cardTitle)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(DistrictTheme.Palette.textPrimary)

                    Text(isJoined ? "JOINED" : badgeTitle)
                        .font(.system(size: 8, weight: .heavy))
                        .tracking(0.35)
                        .foregroundStyle(listing.category.tint)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(listing.category.tint.opacity(0.16), in: Capsule())
                }

                Text(suggestion.cardSubtitle)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(DistrictTheme.Palette.textSecondary)
                    .lineLimit(1)

                Text(
                    isJoined
                        ? "You’re part of this group"
                        : "\(suggestion.joinedCount) going · \(suggestion.spotsLeft) spots · "
                            + "save "
                            + savings.formatted(
                                .currency(code: "INR").precision(.fractionLength(0))
                            )
                )
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(listing.category.tint)
            }

            Spacer(minLength: 4)

            Image(systemName: trailingSymbol)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(listing.category.tint)
        }
        .padding(13)
        .background(
            LinearGradient(
                colors: [
                    listing.category.tint.opacity(0.15),
                    DistrictTheme.Palette.surface
                ],
                startPoint: .leading,
                endPoint: .trailing
            ),
            in: RoundedRectangle(cornerRadius: 17, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 17, style: .continuous)
                .stroke(listing.category.tint.opacity(0.3), lineWidth: 1)
        }
    }

    private var badgeTitle: String {
        switch listing.category {
        case .events: "SIT TOGETHER"
        case .stores: "SHOP TOGETHER"
        case .activities: "JOIN SESSION"
        case .play: "JOIN TEAM"
        case .dining, .movies: "SUGGESTED"
        }
    }

    private var trailingSymbol: String {
        switch listing.category {
        case .events: "ticket.fill"
        case .stores: "bag.fill"
        case .activities: "figure.walk"
        case .play: "sportscourt.fill"
        case .dining: "fork.knife"
        case .movies: "chair.lounge.fill"
        }
    }
}

#Preview {
    let store = SocializeStore()
    let listing = store.listings.first { $0.category == .events }!
    let suggestion = store.experienceSuggestion(for: listing)!
    return ExperienceGroupSuggestionView(
        listing: listing,
        suggestion: suggestion,
        isJoined: false
    )
    .padding()
    .background(DistrictTheme.Palette.background)
}
