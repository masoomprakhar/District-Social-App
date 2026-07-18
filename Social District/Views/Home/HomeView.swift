//
//  HomeView.swift
//  The redesigned District-style home screen.
//

import SwiftUI

struct HomeView: View {
    /// Navigation hook: called when the Socialize banner is tapped.
    /// Wired in RootTabView to push/switch to your existing SocializeHomeView.
    var onOpenSocialize: () -> Void = {}

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: DistrictTheme.Space.section) {

                LocationHeaderView(
                    primary: "Delhi NCR",
                    secondary: "New Delhi, India"
                )
                .padding(.horizontal, DistrictTheme.Space.screenH)
                .padding(.top, 8)

                SearchBarView(
                    placeholder: "Search for events, movies, restaurants..."
                )
                .padding(.horizontal, DistrictTheme.Space.screenH)

                CategoryGridView(items: HomeSampleData.categories)
                    .padding(.horizontal, DistrictTheme.Space.screenH)

                SocializeBannerView(onTap: onOpenSocialize)
                    .padding(.horizontal, DistrictTheme.Space.screenH)

                SpotlightSectionView(
                    title: "In the spotlight",
                    items: HomeSampleData.spotlight
                )
                // No horizontal inset here — the carousel manages its own edge padding.

                Spacer(minLength: 8)
            }
            .padding(.bottom, 12)
        }
        .background(DistrictTheme.Palette.background.ignoresSafeArea())
    }
}

#Preview {
    HomeView()
        .preferredColorScheme(.dark)
}
