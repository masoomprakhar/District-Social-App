//
//  SpotlightSectionView.swift
//

import SwiftUI

struct SpotlightCardView: View {
    let item: SpotlightItem
    var onTap: () -> Void = {}

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                // Large visual area (gradient + symbol placeholder)
                ZStack(alignment: .topLeading) {
                    LinearGradient(colors: item.gradient,
                                   startPoint: .topLeading, endPoint: .bottomTrailing)

                    Image(systemName: item.systemImage)
                        .font(.system(size: 64, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.22))
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                        .padding(16)

                    Text(item.badge)
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 5)
                        .background(.black.opacity(0.28), in: Capsule())
                        .padding(12)
                }
                .frame(height: 170)

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(DistrictTheme.Palette.textPrimary)
                        .lineLimit(1)
                    Text(item.meta)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(DistrictTheme.Palette.textSecondary)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(DistrictTheme.Palette.surface)
            }
            .frame(width: 260)
            .clipShape(RoundedRectangle(cornerRadius: DistrictTheme.Radius.spotlight, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DistrictTheme.Radius.spotlight, style: .continuous)
                    .stroke(DistrictTheme.Palette.border, lineWidth: 1)
            )
        }
        .buttonStyle(PressableButtonStyle())
    }
}

struct SpotlightSectionView: View {
    let title: String
    let items: [SpotlightItem]
    var onSelect: (SpotlightItem) -> Void = { _ in }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(DistrictTheme.Palette.textPrimary)
                .padding(.horizontal, DistrictTheme.Space.screenH)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 14) {
                    ForEach(items) { item in
                        SpotlightCardView(item: item) { onSelect(item) }
                    }
                }
                .padding(.horizontal, DistrictTheme.Space.screenH)
            }
        }
    }
}
