//
//  HomeView.swift
//  The redesigned District-style home screen.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: SocializeStore

    var onOpenSocialize: () -> Void = {}
    var onOpenSearch: (SocializeCategory?) -> Void = { _ in }
    var onOpenProfile: () -> Void = {}
    var onOpenCategory: (SocializeCategory) -> Void = { _ in }
    var onOpenListing: (UUID) -> Void = { _ in }

    @State private var location = "Delhi NCR"
    @State private var locationDetail = "New Delhi, India"
    @State private var showingLocations = false
    @State private var showingSaved = false
    @State private var selectedSpotlight: SpotlightItem?

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: DistrictTheme.Space.section) {

                LocationHeaderView(
                    primary: location,
                    secondary: locationDetail,
                    onLocation: { showingLocations = true },
                    onBookmark: { showingSaved = true },
                    onProfile: onOpenProfile
                )
                .padding(.horizontal, DistrictTheme.Space.screenH)
                .padding(.top, 8)

                SearchBarView(
                    placeholder: "Search for events, movies, restaurants...",
                    onTap: { onOpenSearch(nil) }
                )
                .padding(.horizontal, DistrictTheme.Space.screenH)

                SocializeModeToggleView(isOn: $store.socializeModeEnabled)
                    .padding(.horizontal, DistrictTheme.Space.screenH)

                CategoryGridView(items: HomeSampleData.categories) { item in
                    guard let category = SocializeCategory.allCases.first(
                        where: { $0.title == item.title }
                    ) else {
                        return
                    }
                    onOpenCategory(category)
                }
                .padding(.horizontal, DistrictTheme.Space.screenH)

                PersonalizedRecommendationsView(
                    listings: store.listings.sorted { $0.rating > $1.rating },
                    onSelect: { onOpenListing($0.id) }
                )

                SpotlightSectionView(
                    title: "In the spotlight",
                    items: HomeSampleData.spotlight,
                    onSelect: { selectedSpotlight = $0 }
                )
                // No horizontal inset here — the carousel manages its own edge padding.

                Spacer(minLength: 8)
            }
            .padding(.bottom, 12)
        }
        .background(DistrictTheme.Palette.background.ignoresSafeArea())
        .sheet(isPresented: $showingLocations) {
            LocationPickerView(
                selectedLocation: $location,
                selectedDetail: $locationDetail
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingSaved) {
            SavedHighlightsView(items: HomeSampleData.spotlight)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(item: $selectedSpotlight) { item in
            SpotlightDetailView(item: item)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }
}

private struct LocationPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedLocation: String
    @Binding var selectedDetail: String

    private let locations = [
        ("Delhi NCR", "New Delhi, India"),
        ("Gurugram", "Haryana, India"),
        ("Noida", "Uttar Pradesh, India")
    ]

    var body: some View {
        NavigationStack {
            List(locations, id: \.0) { location in
                Button {
                    selectedLocation = location.0
                    selectedDetail = location.1
                    dismiss()
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(location.0)
                                .foregroundStyle(DistrictTheme.Palette.textPrimary)
                            Text(location.1)
                                .font(.caption)
                                .foregroundStyle(DistrictTheme.Palette.textSecondary)
                        }
                        Spacer()
                        if selectedLocation == location.0 {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(DistrictTheme.Palette.accent)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(DistrictTheme.Palette.background)
            .navigationTitle("Choose location")
            .navigationBarTitleDisplayMode(.inline)
        }
        .preferredColorScheme(.dark)
    }
}

private struct SavedHighlightsView: View {
    let items: [SpotlightItem]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 14) {
                    ForEach(items) { item in
                        SpotlightCardView(item: item)
                    }
                }
                .padding(20)
            }
            .background(DistrictTheme.Palette.background)
            .navigationTitle("Saved")
            .navigationBarTitleDisplayMode(.inline)
        }
        .preferredColorScheme(.dark)
    }
}

private struct SpotlightDetailView: View {
    let item: SpotlightItem

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            ZStack {
                LinearGradient(
                    colors: item.gradient,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                Image(systemName: item.systemImage)
                    .font(.system(size: 70, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.25))
            }
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 22))

            Text(item.badge)
                .font(.system(size: 11, weight: .heavy))
                .foregroundStyle(DistrictTheme.Palette.accent)
            Text(item.title)
                .font(.system(size: 26, weight: .heavy))
                .foregroundStyle(DistrictTheme.Palette.textPrimary)
            Label(item.meta, systemImage: "calendar")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(DistrictTheme.Palette.textSecondary)
            Spacer()
        }
        .padding(20)
        .background(DistrictTheme.Palette.background.ignoresSafeArea())
        .preferredColorScheme(.dark)
    }
}

#Preview {
    HomeView()
        .preferredColorScheme(.dark)
}
