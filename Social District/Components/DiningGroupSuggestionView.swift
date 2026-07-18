import SwiftUI

struct DiningGroupSuggestionView: View {
    let room: SocializeRoom

    private var projectedCount: Int {
        min(room.capacity, room.joinedCount + 1)
    }

    private var projectedDiscount: Int {
        room.discountPercent(for: projectedCount)
    }

    private var projectedSavings: Double {
        room.savings(for: projectedCount)
    }

    var body: some View {
        HStack(spacing: 12) {
            AvatarStackView(members: room.members, maxVisible: 3, size: 30)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text("Join \(room.hostName)’s table")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(DistrictTheme.Palette.textPrimary)

                    Text("SUGGESTED")
                        .font(.system(size: 8, weight: .heavy))
                        .tracking(0.4)
                        .foregroundStyle(DistrictTheme.Palette.accent)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(DistrictTheme.Palette.accentSoft, in: Capsule())
                }

                Text("\(room.joinedCount) people going · \(room.spotsLeft) spots left")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(DistrictTheme.Palette.textSecondary)

                Text(
                    "Join them and save "
                        + projectedSavings.formatted(
                            .currency(code: "INR").precision(.fractionLength(0))
                        )
                        + " · \(projectedDiscount)% off"
                )
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(DistrictTheme.Palette.accent)
            }

            Spacer(minLength: 4)

            Image(systemName: "arrow.right.circle.fill")
                .font(.system(size: 22))
                .foregroundStyle(DistrictTheme.Palette.accent)
        }
        .padding(13)
        .background(
            LinearGradient(
                colors: [
                    DistrictTheme.Palette.accent.opacity(0.16),
                    DistrictTheme.Palette.surface
                ],
                startPoint: .leading,
                endPoint: .trailing
            ),
            in: RoundedRectangle(cornerRadius: 17, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 17, style: .continuous)
                .stroke(DistrictTheme.Palette.accent.opacity(0.3), lineWidth: 1)
        }
    }
}

#Preview {
    let store = SocializeStore()
    DiningGroupSuggestionView(room: store.rooms.first { $0.activityType == .dining }!)
        .padding()
        .background(DistrictTheme.Palette.background)
}
