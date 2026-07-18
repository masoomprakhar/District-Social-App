import SwiftUI

/// Custom dark bottom navigation bar with a top hairline.
struct BottomNavigationView: View {
    @Binding var selectedTab: HomeTab
    var onTapSocialize: () -> Void

    var body: some View {
        HStack {
            ForEach(HomeTab.allCases) { tab in
                Button {
                    if tab == .socialize {
                        onTapSocialize()
                    } else {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: tab.symbolName)
                            .font(.system(size: 20, weight: .medium))
                        Text(tab.rawValue)
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundStyle(color(for: tab))
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(
            Rectangle()
                .fill(Color.districtSurface.opacity(0.98))
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(Color.districtStroke)
                        .frame(height: 1)
                }
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private func color(for tab: HomeTab) -> Color {
        if tab == .socialize {
            return selectedTab == .socialize
                ? Color.districtPurple
                : Color.districtPurple.opacity(0.8)
        }
        return selectedTab == tab
            ? Color.districtTextPrimary
            : Color.districtTextSecondary
    }
}

#Preview {
    VStack {
        Spacer()
        BottomNavigationView(selectedTab: .constant(.home)) {}
    }
    .background(Color.districtBackground)
}
