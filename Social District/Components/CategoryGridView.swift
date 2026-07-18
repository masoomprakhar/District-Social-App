//
//  CategoryGridView.swift
//

import SwiftUI

struct CategoryCardView: View {
    let item: CategoryItem
    var onTap: () -> Void = {}

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                // Colorful icon chip
                Image(systemName: item.systemImage)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(item.tint)
                    .frame(width: 46, height: 46)
                    .background(item.tint.opacity(0.16),
                                in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                Spacer(minLength: 14)

                Text(item.title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(DistrictTheme.Palette.textPrimary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .frame(height: 118)
            .background(DistrictTheme.Palette.surface,
                        in: RoundedRectangle(cornerRadius: DistrictTheme.Radius.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DistrictTheme.Radius.card, style: .continuous)
                    .stroke(DistrictTheme.Palette.border, lineWidth: 1)
            )
        }
        .buttonStyle(PressableButtonStyle())
    }
}

struct CategoryGridView: View {
    let items: [CategoryItem]
    var onSelect: (CategoryItem) -> Void = { _ in }

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: DistrictTheme.Space.grid),
        count: 3
    )

    var body: some View {
        LazyVGrid(columns: columns, spacing: DistrictTheme.Space.grid) {
            ForEach(items) { item in
                CategoryCardView(item: item) { onSelect(item) }
            }
        }
    }
}

/// Subtle press-scale used across tappable cards.
struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
