import SwiftUI

struct SocializeListingCardView: View {
    let listing: SocializeListing
    let socializeModeEnabled: Bool

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            listing.category.tint.opacity(0.4),
                            listing.category.tint.opacity(0.12)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 78, height: 94)
                .overlay {
                    Image(systemName: listing.systemImage)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(listing.category.tint)
                }

            VStack(alignment: .leading, spacing: 6) {
                Text(listing.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(DistrictTheme.Palette.textPrimary)
                    .lineLimit(1)

                Text("\(listing.venueName) · \(listing.venueArea)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(DistrictTheme.Palette.textSecondary)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(DistrictTheme.CategoryTint.events)
                    Text(listing.rating, format: .number.precision(.fractionLength(1)))
                    Text("·")
                    Text(listing.detail)
                        .lineLimit(1)
                }
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(DistrictTheme.Palette.textSecondary)

                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(
                        socializeModeEnabled
                            ? listing.socializePrice
                            : listing.pricePerPerson,
                        format: .currency(code: "INR").precision(.fractionLength(0))
                    )
                    .font(.system(size: 17, weight: .heavy))
                    .foregroundStyle(DistrictTheme.Palette.textPrimary)

                    if socializeModeEnabled {
                        Text(
                            listing.pricePerPerson,
                            format: .currency(code: "INR").precision(.fractionLength(0))
                        )
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(DistrictTheme.Palette.textSecondary)
                        .strikethrough()
                    }

                    Text("per person")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(DistrictTheme.Palette.textSecondary)

                    if socializeModeEnabled {
                        Text("UP TO 20% OFF")
                            .font(.system(size: 8, weight: .heavy))
                            .foregroundStyle(DistrictTheme.Palette.accent)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(DistrictTheme.Palette.accentSoft, in: Capsule())
                    }
                }
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(DistrictTheme.Palette.textTertiary)
        }
        .padding(14)
        .background(
            DistrictTheme.Palette.surface,
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(
                    socializeModeEnabled
                        ? DistrictTheme.Palette.accent.opacity(0.25)
                        : DistrictTheme.Palette.border,
                    lineWidth: 1
                )
        }
    }
}

#Preview {
    let store = SocializeStore()
    SocializeListingCardView(
        listing: store.listings[0],
        socializeModeEnabled: true
    )
    .padding()
    .background(DistrictTheme.Palette.background)
}
