import SwiftUI

struct VenueSafetyIndicator: View {
    let isPublicVenue: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: isPublicVenue ? "shield.checkered" : "shield")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(isPublicVenue ? AppTheme.safetyGreen : AppTheme.secondaryText)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(
                            isPublicVenue
                                ? AppTheme.safetyGreen.opacity(0.12)
                                : AppTheme.background
                        )
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(isPublicVenue ? "Public venue" : "Private meetup")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppTheme.primaryText)
                Text(
                    isPublicVenue
                        ? "Meets at a known public location for added safety."
                        : "Confirm details with the host before joining."
                )
                .font(.system(size: 12))
                .foregroundStyle(AppTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white)
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(
                            isPublicVenue
                                ? AppTheme.safetyGreen.opacity(0.25)
                                : AppTheme.divider,
                            lineWidth: 1
                        )
                }
        )
    }
}
