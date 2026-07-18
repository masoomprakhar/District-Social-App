import SwiftUI

struct SearchView: View {
    @EnvironmentObject private var store: SocializeStore
    @Binding var selectedCategory: SocializeCategory?
    var onOpenListing: (UUID) -> Void

    @State private var query = ""

    private var normalizedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isBrowsing: Bool {
        normalizedQuery.isEmpty
    }

    private var results: [SocializeListing] {
        let filtered = store.listings.filter { listing in
            let matchesCategory = selectedCategory == nil || listing.category == selectedCategory
            guard matchesCategory else { return false }

            if isBrowsing {
                return true
            }

            return [
                listing.title,
                listing.venueName,
                listing.venueArea,
                listing.category.title,
                listing.detail
            ]
            .joined(separator: " ")
            .localizedCaseInsensitiveContains(normalizedQuery)
        }

        if isBrowsing {
            return Array(filtered.sorted { $0.rating > $1.rating }.prefix(6))
        }
        return filtered
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                Text("Search")
                    .font(.system(size: 30, weight: .heavy))
                    .foregroundStyle(DistrictTheme.Palette.textPrimary)

                HStack(spacing: 11) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(DistrictTheme.Palette.textSecondary)

                    TextField(
                        "Events, movies, restaurants...",
                        text: $query
                    )
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .foregroundStyle(DistrictTheme.Palette.textPrimary)

                    if !query.isEmpty {
                        Button {
                            query = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(DistrictTheme.Palette.textSecondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .frame(height: 54)
                .background(
                    DistrictTheme.Palette.surfaceRaised,
                    in: RoundedRectangle(cornerRadius: DistrictTheme.Radius.search)
                )

                categoryFilters

                if results.isEmpty {
                    emptyState
                } else {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(isBrowsing ? "Trending near you" : "Results")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(DistrictTheme.Palette.textPrimary)

                        LazyVStack(spacing: 12) {
                            ForEach(results) { listing in
                                Button {
                                    onOpenListing(listing.id)
                                } label: {
                                    SocializeListingCardView(
                                        listing: listing,
                                        socializeModeEnabled: store.socializeModeEnabled
                                    )
                                }
                                .buttonStyle(PressableButtonStyle())
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, DistrictTheme.Space.screenH)
            .padding(.top, 10)
            .padding(.bottom, 110)
        }
        .background(DistrictTheme.Palette.background.ignoresSafeArea())
        #if os(iOS)
        .toolbar(.hidden, for: .navigationBar)
        #endif
    }

    private var categoryFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 9) {
                filterButton(title: "All", category: nil)
                ForEach(SocializeCategory.allCases) { category in
                    filterButton(title: category.title, category: category)
                }
            }
        }
    }

    private func filterButton(
        title: String,
        category: SocializeCategory?
    ) -> some View {
        let isSelected = selectedCategory == category

        return Button {
            withAnimation(.easeOut(duration: 0.2)) {
                selectedCategory = category
            }
        } label: {
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(
                    isSelected ? Color.white : DistrictTheme.Palette.textSecondary
                )
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(
                    isSelected
                        ? DistrictTheme.Palette.accent
                        : DistrictTheme.Palette.surface,
                    in: Capsule()
                )
        }
        .buttonStyle(.plain)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 32, weight: .semibold))
                .foregroundStyle(DistrictTheme.Palette.accent)
            Text("No plans found")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(DistrictTheme.Palette.textPrimary)
            Text("Try another search or category.")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(DistrictTheme.Palette.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 64)
    }
}

#Preview {
    @Previewable @State var category: SocializeCategory?
    SearchView(selectedCategory: $category, onOpenListing: { _ in })
        .environmentObject(SocializeStore())
}
