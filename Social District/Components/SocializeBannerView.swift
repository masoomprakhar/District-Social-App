import SwiftUI

/// Prominent horizontal entry card for the Socialize feature.
struct SocializeBannerView: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .fill(Color.districtPurple.opacity(0.28))
                    .frame(width: 52, height: 52)
                    .overlay {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 21, weight: .semibold))
                            .foregroundStyle(Color.districtPurple)
                    }

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text("Socialize")
                            .font(.system(.headline, weight: .bold))
                            .foregroundStyle(Color.districtTextPrimary)

                        Text("NEW")
                            .font(.districtBadge)
                            .tracking(0.5)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(Color.districtPurple)
                            .clipShape(Capsule())
                    }

                    Text("Find people to go out with")
                        .font(.districtLocationSecondary)
                        .foregroundStyle(Color.districtTextSecondary)
                }
                .lineLimit(1)

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.districtTextSecondary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: DistrictRadius.banner, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.districtPurple.opacity(0.22),
                                Color.districtPurpleDeep.opacity(0.16),
                                Color.districtSurface
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .background(
                RoundedRectangle(cornerRadius: DistrictRadius.banner, style: .continuous)
                    .fill(Color.districtSurface)
            )
            .overlay {
                RoundedRectangle(cornerRadius: DistrictRadius.banner, style: .continuous)
                    .stroke(Color.districtStroke, lineWidth: 1)
            }
        }
        .buttonStyle(.districtPress)
    }
}

#Preview {
    SocializeBannerView {}
        .padding(DistrictSpacing.pageInset)
        .background(Color.districtBackground)
}
