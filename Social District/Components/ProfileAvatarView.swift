import SwiftUI

struct ProfileAvatarView: View {
    let profile: UserProfile
    var size: CGFloat = 40
    var showVerifiedBadge: Bool = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Circle()
                .fill(profile.accentColor.opacity(0.18))
                .frame(width: size, height: size)
                .overlay {
                    Image(systemName: profile.symbolName)
                        .font(.system(size: size * 0.42, weight: .semibold))
                        .foregroundStyle(profile.accentColor)
                }
                .overlay {
                    Circle()
                        .stroke(Color.white, lineWidth: size > 36 ? 2.5 : 1.5)
                }

            if showVerifiedBadge && profile.isVerified {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: size * 0.32))
                    .foregroundStyle(AppTheme.socializePurple)
                    .background(
                        Circle()
                            .fill(Color.white)
                            .frame(width: size * 0.28, height: size * 0.28)
                    )
                    .offset(x: 2, y: 2)
            }
        }
    }
}
