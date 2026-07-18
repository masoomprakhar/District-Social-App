import SwiftUI

struct MovieGroupSuggestionView: View {
    let room: SocializeRoom

    private var projectedCount: Int {
        min(room.capacity, room.joinedCount + 1)
    }

    var body: some View {
        HStack(spacing: 12) {
            AvatarStackView(members: room.members, maxVisible: 3, size: 30)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text("Watch with \(room.hostName)’s group")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(DistrictTheme.Palette.textPrimary)

                    Text("SEAT TOGETHER")
                        .font(.system(size: 8, weight: .heavy))
                        .tracking(0.35)
                        .foregroundStyle(DistrictTheme.CategoryTint.movies)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(
                            DistrictTheme.CategoryTint.movies.opacity(0.16),
                            in: Capsule()
                        )
                }

                Text(
                    "\(room.joinedCount) people are going to this show · "
                        + "\(room.spotsLeft) nearby seats left"
                )
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(DistrictTheme.Palette.textSecondary)

                Text(
                    "Choose a seat beside them · "
                        + "\(room.discountPercent(for: projectedCount))% group discount"
                )
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(DistrictTheme.CategoryTint.movies)
            }

            Spacer(minLength: 4)

            Image(systemName: "chair.lounge.fill")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(DistrictTheme.CategoryTint.movies)
        }
        .padding(13)
        .background(
            LinearGradient(
                colors: [
                    DistrictTheme.CategoryTint.movies.opacity(0.16),
                    DistrictTheme.Palette.surface
                ],
                startPoint: .leading,
                endPoint: .trailing
            ),
            in: RoundedRectangle(cornerRadius: 17, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 17, style: .continuous)
                .stroke(
                    DistrictTheme.CategoryTint.movies.opacity(0.3),
                    lineWidth: 1
                )
        }
    }
}

#Preview {
    let store = SocializeStore()
    MovieGroupSuggestionView(room: store.rooms.first { $0.activityType == .movie }!)
        .padding()
        .background(DistrictTheme.Palette.background)
}
