//
//  SocializeBannerView.swift
//
//  Distinctive horizontal entry point for the Socialize feature.
//  Tapping it should navigate to your existing SocializeHomeView — the
//  navigation is wired at the call site in HomeView.
//

import SwiftUI

struct SocializeBannerView: View {
    var onTap: () -> Void = {}

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // People icon on an accent chip
                Image(systemName: "person.2.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(DistrictTheme.Palette.accent,
                                in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 8) {
                        Text("Socialize")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(DistrictTheme.Palette.textPrimary)

                        Text("NEW")
                            .font(.system(size: 10, weight: .heavy))
                            .foregroundStyle(DistrictTheme.Palette.accent)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(DistrictTheme.Palette.accentSoft,
                                        in: Capsule())
                    }
                    Text("Find people to go out with")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(DistrictTheme.Palette.textSecondary)
                }

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(DistrictTheme.Palette.textSecondary)
            }
            .padding(16)
            .background {
                ZStack {
                    DistrictTheme.Palette.surface
                    LinearGradient(
                        colors: [DistrictTheme.Palette.accent.opacity(0.18), .clear],
                        startPoint: .leading, endPoint: .trailing
                    )
                }
                .clipShape(RoundedRectangle(cornerRadius: DistrictTheme.Radius.banner, style: .continuous))
            }
            .overlay(
                RoundedRectangle(cornerRadius: DistrictTheme.Radius.banner, style: .continuous)
                    .stroke(DistrictTheme.Palette.accent.opacity(0.35), lineWidth: 1)
            )
        }
        .buttonStyle(PressableButtonStyle())
    }
}
