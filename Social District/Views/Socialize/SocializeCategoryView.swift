import SwiftUI

struct SocializeCategoryView: View {
    @EnvironmentObject private var store: SocializeStore
    @Binding var path: NavigationPath
    let category: SocializeCategory

    private var listings: [SocializeListing] {
        store.listings(for: category)
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: category.symbolName)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(category.tint)
                        .frame(width: 52, height: 52)
                        .background(category.tint.opacity(0.16), in: RoundedRectangle(cornerRadius: 16))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(category.title)
                            .font(.system(size: 28, weight: .heavy))
                            .foregroundStyle(DistrictTheme.Palette.textPrimary)
                        Text(category.subtitle)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(DistrictTheme.Palette.textSecondary)
                    }
                }

                LazyVStack(spacing: 12) {
                    ForEach(listings) { listing in
                        VStack(spacing: 7) {
                            Button {
                                path.append(AppRoute.socializeListing(listing.id))
                            } label: {
                                SocializeListingCardView(
                                    listing: listing,
                                    socializeModeEnabled: store.socializeModeEnabled
                                )
                            }
                            .buttonStyle(PressableButtonStyle())

                            // Group suggestions only appear when Socialize Mode is on.
                            if store.socializeModeEnabled {
                                if let suggestedRoom = store.suggestedRoom(for: listing) {
                                    if category == .dining {
                                        Button {
                                            path.append(AppRoute.roomDetail(suggestedRoom.id))
                                        } label: {
                                            DiningGroupSuggestionView(room: suggestedRoom)
                                        }
                                        .buttonStyle(PressableButtonStyle())
                                    } else if category == .movies {
                                        Button {
                                            path.append(
                                                AppRoute.movieSeats(
                                                    listingID: listing.id,
                                                    roomID: suggestedRoom.id
                                                )
                                            )
                                        } label: {
                                            MovieGroupSuggestionView(room: suggestedRoom)
                                        }
                                        .buttonStyle(PressableButtonStyle())
                                    }
                                }

                                if let suggestion = store.experienceSuggestion(for: listing) {
                                    Button {
                                        path.append(AppRoute.groupExperience(listing.id))
                                    } label: {
                                        ExperienceGroupSuggestionView(
                                            listing: listing,
                                            suggestion: suggestion,
                                            isJoined: store.joinedExperienceIDs.contains(listing.id)
                                        )
                                    }
                                    .buttonStyle(PressableButtonStyle())
                                    .disabled(store.joinedExperienceIDs.contains(listing.id))
                                }
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
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(DistrictTheme.Palette.background, for: .navigationBar)
        #endif
    }
}

#Preview {
    @Previewable @State var path = NavigationPath()
    SocializeCategoryView(path: $path, category: .dining)
        .environmentObject(SocializeStore())
}
