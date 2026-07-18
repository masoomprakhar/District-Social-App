//
//  SearchBarView.swift
//

import SwiftUI

struct SearchBarView: View {
    let placeholder: String
    var onTap: () -> Void = {}

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(DistrictTheme.Palette.textSecondary)

                Text(placeholder)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(DistrictTheme.Palette.textSecondary)
                    .lineLimit(1)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(DistrictTheme.Palette.surfaceRaised,
                        in: RoundedRectangle(cornerRadius: DistrictTheme.Radius.search, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DistrictTheme.Radius.search, style: .continuous)
                    .stroke(DistrictTheme.Palette.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
