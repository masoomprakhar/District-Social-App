import SwiftUI

struct AvatarStackView: View {
    let profiles: [UserProfile]
    var maxVisible: Int = 4
    var size: CGFloat = 28

    private var visibleProfiles: [UserProfile] {
        Array(profiles.prefix(maxVisible))
    }

    private var overflowCount: Int {
        max(0, profiles.count - maxVisible)
    }

    var body: some View {
        HStack(spacing: -8) {
            ForEach(visibleProfiles) { profile in
                ProfileAvatarView(profile: profile, size: size)
            }

            if overflowCount > 0 {
                Circle()
                    .fill(AppTheme.divider)
                    .frame(width: size, height: size)
                    .overlay {
                        Text("+\(overflowCount)")
                            .font(.system(size: size * 0.32, weight: .semibold))
                            .foregroundStyle(AppTheme.secondaryText)
                    }
                    .overlay {
                        Circle()
                            .stroke(Color.white, lineWidth: 1.5)
                    }
            }
        }
    }
}
