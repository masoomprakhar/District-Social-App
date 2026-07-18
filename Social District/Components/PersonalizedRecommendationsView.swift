import SwiftUI

struct PersonalizedRecommendationsView: View {
    let listings: [SocializeListing]
    var onSelect: (SocializeListing) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Picked for you")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(DistrictTheme.Palette.textPrimary)
                    Text("Based on your movies, dining, and saved plans")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(DistrictTheme.Palette.textSecondary)
                }

                Spacer()

                Image(systemName: "sparkles")
                    .foregroundStyle(DistrictTheme.Palette.accent)
            }
            .padding(.horizontal, DistrictTheme.Space.screenH)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(Array(listings.prefix(5))) { listing in
                        Button {
                            onSelect(listing)
                        } label: {
                            recommendationCard(listing)
                        }
                        .buttonStyle(PressableButtonStyle())
                    }
                }
                .padding(.horizontal, DistrictTheme.Space.screenH)
            }
        }
    }

    private func recommendationCard(
        _ listing: SocializeListing
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: listing.systemImage)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(listing.category.tint)
                    .frame(width: 46, height: 46)
                    .background(
                        listing.category.tint.opacity(0.16),
                        in: RoundedRectangle(cornerRadius: 14)
                    )

                Spacer()

                Text("\(matchScore(for: listing))% MATCH")
                    .font(.system(size: 9, weight: .heavy))
                    .foregroundStyle(DistrictTheme.Palette.accent)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(listing.title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(DistrictTheme.Palette.textPrimary)
                    .lineLimit(2)
                Text(listing.venueName)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(DistrictTheme.Palette.textSecondary)
                    .lineLimit(1)
            }

            Text(reason(for: listing))
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(DistrictTheme.Palette.textSecondary)
                .lineLimit(2)

            Text(
                listing.pricePerPerson,
                format: .currency(code: "INR").precision(.fractionLength(0))
            )
            .font(.system(size: 16, weight: .heavy))
            .foregroundStyle(DistrictTheme.Palette.textPrimary)
        }
        .frame(width: 190, height: 190, alignment: .topLeading)
        .padding(15)
        .background(
            DistrictTheme.Palette.surface,
            in: RoundedRectangle(cornerRadius: 22)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 22)
                .stroke(DistrictTheme.Palette.border, lineWidth: 1)
        }
    }

    private func matchScore(for listing: SocializeListing) -> Int {
        switch listing.category {
        case .movies: 96
        case .dining: 93
        case .events: 89
        case .activities: 87
        case .play: 85
        case .stores: 82
        }
    }

    private func reason(for listing: SocializeListing) -> String {
        switch listing.category {
        case .movies: "Because you prefer IMAX and evening shows"
        case .dining: "Similar to restaurants you save"
        case .events: "Matches your weekend event activity"
        case .stores: "Near places you frequently explore"
        case .activities: "Fits your creative weekend interests"
        case .play: "Beginner-friendly and social"
        }
    }
}

