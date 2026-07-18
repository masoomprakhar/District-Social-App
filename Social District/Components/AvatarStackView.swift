import SwiftUI

struct AvatarStackView: View {
    private let avatars: [AvatarItem]
    var maxVisible: Int = 4
    var size: CGFloat = 28

    init(profiles: [UserProfile], maxVisible: Int = 4, size: CGFloat = 28) {
        self.avatars = profiles.map {
            AvatarItem(id: $0.id, symbolName: $0.symbolName, color: $0.accentColor)
        }
        self.maxVisible = maxVisible
        self.size = size
    }

    init(members: [RoomMember], maxVisible: Int = 4, size: CGFloat = 28) {
        let colors: [Color] = [
            DistrictTheme.CategoryTint.movies,
            DistrictTheme.CategoryTint.dining,
            DistrictTheme.CategoryTint.stores,
            DistrictTheme.CategoryTint.play
        ]
        self.avatars = members.enumerated().map { index, member in
            AvatarItem(
                id: member.id,
                symbolName: member.avatarSystemImage,
                color: colors[index % colors.count]
            )
        }
        self.maxVisible = maxVisible
        self.size = size
    }

    private var visibleAvatars: [AvatarItem] {
        Array(avatars.prefix(maxVisible))
    }

    private var overflowCount: Int {
        max(0, avatars.count - maxVisible)
    }

    var body: some View {
        HStack(spacing: -8) {
            ForEach(visibleAvatars) { avatar in
                Circle()
                    .fill(avatar.color.opacity(0.22))
                    .frame(width: size, height: size)
                    .overlay {
                        Image(systemName: avatar.symbolName)
                            .font(.system(size: size * 0.45, weight: .semibold))
                            .foregroundStyle(avatar.color)
                    }
                    .overlay {
                        Circle().stroke(DistrictTheme.Palette.surface, lineWidth: 2)
                    }
            }

            if overflowCount > 0 {
                Circle()
                    .fill(DistrictTheme.Palette.surfaceRaised)
                    .frame(width: size, height: size)
                    .overlay {
                        Text("+\(overflowCount)")
                            .font(.system(size: size * 0.32, weight: .semibold))
                            .foregroundStyle(DistrictTheme.Palette.textSecondary)
                    }
                    .overlay {
                        Circle()
                            .stroke(DistrictTheme.Palette.surface, lineWidth: 2)
                    }
            }
        }
    }
}

private struct AvatarItem: Identifiable {
    let id: UUID
    let symbolName: String
    let color: Color
}
