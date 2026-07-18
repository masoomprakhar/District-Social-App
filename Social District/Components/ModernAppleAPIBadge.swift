import SwiftUI

struct ModernAppleAPIBadge: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "apple.intelligence")
                .font(.system(size: 13, weight: .semibold))

            Text("Liquid Glass · On-device AI")
                .font(.system(size: 10, weight: .bold))

            Spacer(minLength: 4)

            Text("iOS 26+")
                .font(.system(size: 9, weight: .heavy))
                .foregroundStyle(DistrictTheme.Palette.accent)
        }
        .foregroundStyle(DistrictTheme.Palette.textPrimary)
        .padding(.horizontal, 13)
        .padding(.vertical, 10)
        .glassEffect(
            .regular.tint(DistrictTheme.Palette.accent.opacity(0.16)),
            in: Capsule()
        )
        .accessibilityLabel(
            "Built with Liquid Glass and on-device Apple Intelligence"
        )
    }
}

#Preview {
    ModernAppleAPIBadge()
        .padding()
        .background(DistrictTheme.Palette.background)
}

