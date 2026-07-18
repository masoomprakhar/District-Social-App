import SwiftUI

struct RoomCardView: View {
    let room: SocializeRoom

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: room.activityType.symbolName)
                    .font(.system(size: 21, weight: .semibold))
                    .foregroundStyle(activityTint)
                    .frame(width: 46, height: 46)
                    .background(activityTint.opacity(0.16), in: RoundedRectangle(cornerRadius: 14))

                VStack(alignment: .leading, spacing: 5) {
                    Text(room.title)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(DistrictTheme.Palette.textPrimary)
                        .lineLimit(2)

                    Label(
                        "\(room.venueName) · \(room.venueArea)",
                        systemImage: "mappin.and.ellipse"
                    )
                    .lineLimit(1)

                    Label(
                        room.dateTime.formatted(date: .abbreviated, time: .shortened),
                        systemImage: "calendar"
                    )
                }
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(DistrictTheme.Palette.textSecondary)

                Spacer(minLength: 0)
            }

            HStack(spacing: 10) {
                Circle()
                    .fill(DistrictTheme.Palette.accentSoft)
                    .frame(width: 32, height: 32)
                    .overlay {
                        Image(systemName: room.hostAvatarSystemImage)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(DistrictTheme.Palette.accent)
                    }

                VStack(alignment: .leading, spacing: 1) {
                    Text("Hosted by \(room.hostName)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(DistrictTheme.Palette.textSecondary)
                    Text("\(room.joinedCount)/\(room.capacity) joined")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(DistrictTheme.Palette.textPrimary)
                }

                Spacer()

                AvatarStackView(members: room.members, maxVisible: 3, size: 28)
            }

            HStack {
                DiscountBadgeView(room: room)

                Spacer()

                Text(room.isFull ? "Room full" : "\(room.spotsLeft) spots left")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(
                        room.isFull
                            ? DistrictTheme.Palette.textSecondary
                            : DistrictTheme.Palette.textPrimary
                    )
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(DistrictTheme.Palette.surfaceRaised, in: Capsule())
            }
        }
        .padding(16)
        .background(
            DistrictTheme.Palette.surface,
            in: RoundedRectangle(cornerRadius: 22, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(DistrictTheme.Palette.border, lineWidth: 1)
        }
    }

    private var activityTint: Color {
        switch room.activityType {
        case .movie: DistrictTheme.CategoryTint.movies
        case .dining: DistrictTheme.CategoryTint.dining
        }
    }
}

#Preview {
    RoomCardView(room: SocializeStore().rooms[0])
        .padding()
        .background(DistrictTheme.Palette.background)
}
