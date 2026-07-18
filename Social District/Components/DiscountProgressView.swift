import SwiftUI

struct DiscountProgressView: View {
    let room: SocializeRoom

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Group discount")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(DistrictTheme.Palette.textPrimary)
                    Text(statusMessage)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(DistrictTheme.Palette.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Text("\(room.currentDiscountPercent)%")
                    .font(.system(size: 24, weight: .heavy))
                    .foregroundStyle(DistrictTheme.Palette.accent)
            }

            VStack(spacing: 9) {
                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(DistrictTheme.Palette.surfaceRaised)
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        DistrictTheme.Palette.accent,
                                        DistrictTheme.CategoryTint.movies
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(
                                width: proxy.size.width
                                    * min(1, CGFloat(room.joinedCount) / CGFloat(room.capacity))
                            )
                    }
                }
                .frame(height: 8)

                HStack {
                    Text("1")
                    Spacer()
                    ForEach(room.discountTiers) { tier in
                        Text("\(tier.minMembers) · \(tier.discountPercent)%")
                            .foregroundStyle(
                                room.joinedCount >= tier.minMembers
                                    ? DistrictTheme.Palette.accent
                                    : DistrictTheme.Palette.textTertiary
                            )
                        if tier.id != room.discountTiers.last?.id {
                            Spacer()
                        }
                    }
                }
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(DistrictTheme.Palette.textTertiary)
            }

            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Base price")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(DistrictTheme.Palette.textSecondary)
                    Text(room.basePrice, format: .currency(code: "INR").precision(.fractionLength(0)))
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(DistrictTheme.Palette.textSecondary)
                        .strikethrough(room.currentDiscountPercent > 0)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 3) {
                    Text("Current price")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(DistrictTheme.Palette.textSecondary)
                    Text(room.currentPrice, format: .currency(code: "INR").precision(.fractionLength(0)))
                        .font(.system(size: 22, weight: .heavy))
                        .foregroundStyle(DistrictTheme.Palette.textPrimary)
                }
            }
        }
        .padding(18)
        .background(
            DistrictTheme.Palette.surface,
            in: RoundedRectangle(cornerRadius: 22, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(DistrictTheme.Palette.accent.opacity(0.28), lineWidth: 1)
        }
    }

    private var statusMessage: String {
        if room.isFull {
            "Maximum group discount unlocked"
        } else if let tier = room.nextDiscountTier, let needed = room.nextTierMembersNeeded {
            "Join to unlock \(tier.discountPercent)% · \(needed) more \(needed == 1 ? "person" : "people") needed"
        } else {
            "Maximum discount unlocked — your group saves together"
        }
    }
}

#Preview {
    DiscountProgressView(room: SocializeStore().rooms[0])
        .padding()
        .background(DistrictTheme.Palette.background)
}
