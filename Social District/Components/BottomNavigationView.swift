//
//  BottomNavigationView.swift
//

import SwiftUI

enum AppTab: Int, CaseIterable {
    case home, search, socialize, bookings, profile

    var title: String {
        switch self {
        case .home: "Home"
        case .search: "Search"
        case .socialize: "Socialize"
        case .bookings: "Bookings"
        case .profile: "Profile"
        }
    }

    var systemImage: String {
        switch self {
        case .home: "house.fill"
        case .search: "magnifyingglass"
        case .socialize: "person.2.fill"
        case .bookings: "ticket.fill"
        case .profile: "person.crop.circle.fill"
        }
    }
}

struct BottomNavigationView: View {
    @Binding var selection: AppTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.rawValue) { tab in
                let isSelected = tab == selection
                let isSocialize = tab == .socialize

                Button {
                    selection = tab
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: tab.systemImage)
                            .font(.system(size: 20, weight: .semibold))
                        Text(tab.title)
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundStyle(tint(isSelected: isSelected, isSocialize: isSocialize))
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, 12)
        .padding(.horizontal, 8)
        .background(
            DistrictTheme.Palette.surface
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(DistrictTheme.Palette.border)
                        .frame(height: 1)
                }
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private func tint(isSelected: Bool, isSocialize: Bool) -> Color {
        if isSelected {
            return isSocialize ? DistrictTheme.Palette.accent : DistrictTheme.Palette.textPrimary
        }
        return isSocialize
            ? DistrictTheme.Palette.accent.opacity(0.6)
            : DistrictTheme.Palette.textTertiary
    }
}
