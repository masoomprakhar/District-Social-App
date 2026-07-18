//
//  LocationHeaderView.swift
//

import SwiftUI

struct LocationHeaderView: View {
    let primary: String
    let secondary: String
    var onBookmark: () -> Void = {}
    var onProfile: () -> Void = {}

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Button(action: {}) {
                HStack(spacing: 8) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(DistrictTheme.Palette.textPrimary)

                    VStack(alignment: .leading, spacing: 1) {
                        HStack(spacing: 4) {
                            Text(primary)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(DistrictTheme.Palette.textPrimary)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(DistrictTheme.Palette.textSecondary)
                        }
                        Text(secondary)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(DistrictTheme.Palette.textSecondary)
                    }
                }
            }
            .buttonStyle(.plain)

            Spacer(minLength: 8)

            CircleIconButton(systemImage: "bookmark", action: onBookmark)
            CircleIconButton(systemImage: "person.fill", action: onProfile)
        }
    }
}

private struct CircleIconButton: View {
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(DistrictTheme.Palette.textPrimary)
                .frame(width: 42, height: 42)
                .background(DistrictTheme.Palette.surfaceRaised, in: Circle())
                .overlay(Circle().stroke(DistrictTheme.Palette.border, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}
