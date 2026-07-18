import SwiftUI

struct SocializeListingDetailView: View {
    @EnvironmentObject private var store: SocializeStore
    @Binding var path: NavigationPath
    let listingID: UUID

    @State private var showingBookedAlert = false

    var body: some View {
        Group {
            if let listing = store.listing(id: listingID) {
                ZStack(alignment: .bottom) {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 0) {
                            header(listing)

                            VStack(alignment: .leading, spacing: 22) {
                                venueDetails(listing)
                                priceCard(listing)
                                if store.socializeModeEnabled {
                                    whySocialize
                                }
                            }
                            .padding(.horizontal, DistrictTheme.Space.screenH)
                            .padding(.top, 20)
                            .padding(.bottom, 180)
                        }
                    }

                    primaryButton(listing)
                        .padding(.horizontal, DistrictTheme.Space.screenH)
                        .padding(.bottom, 78)
                }
                .background(DistrictTheme.Palette.background.ignoresSafeArea())
                .alert("Booking confirmed", isPresented: $showingBookedAlert) {
                    Button("Done", role: .cancel) {}
                } message: {
                    Text("Your regular booking for \(listing.title) has been added.")
                }
            } else {
                Text("Plan unavailable")
            }
        }
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(DistrictTheme.Palette.background, for: .navigationBar)
        #endif
    }

    private func header(_ listing: SocializeListing) -> some View {
        ZStack {
            LinearGradient(
                colors: [
                    listing.category.tint.opacity(0.75),
                    DistrictTheme.Palette.surface
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Image(systemName: listing.systemImage)
                .font(.system(size: 88, weight: .semibold))
                .foregroundStyle(.white.opacity(0.16))
                .offset(x: 92, y: -20)

            VStack(alignment: .leading, spacing: 7) {
                Spacer()
                Text(listing.category.title.uppercased())
                    .font(.system(size: 11, weight: .heavy))
                    .tracking(1)
                    .foregroundStyle(.white.opacity(0.7))
                Text(listing.title)
                    .font(.system(size: 27, weight: .heavy))
                    .foregroundStyle(.white)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
        }
        .frame(height: 230)
    }

    private func venueDetails(_ listing: SocializeListing) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Label(listing.venueName, systemImage: "mappin.and.ellipse")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(DistrictTheme.Palette.textPrimary)
            Text(listing.venueArea)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(DistrictTheme.Palette.textSecondary)
            Text(listing.detail)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(DistrictTheme.Palette.textSecondary)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            DistrictTheme.Palette.surface,
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
    }

    private func priceCard(_ listing: SocializeListing) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(store.socializeModeEnabled ? "Together price" : "Price per person")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(DistrictTheme.Palette.textSecondary)

                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(
                        store.socializeModeEnabled
                            ? listing.socializePrice
                            : listing.pricePerPerson,
                        format: .currency(code: "INR").precision(.fractionLength(0))
                    )
                    .font(.system(size: 28, weight: .heavy))
                    .foregroundStyle(DistrictTheme.Palette.textPrimary)

                    if store.socializeModeEnabled {
                        Text(
                            listing.pricePerPerson,
                            format: .currency(code: "INR").precision(.fractionLength(0))
                        )
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(DistrictTheme.Palette.textSecondary)
                        .strikethrough()
                    }
                }
            }

            Spacer()

            if store.socializeModeEnabled {
                Text("20% OFF")
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 11)
                    .padding(.vertical, 7)
                    .background(DistrictTheme.Palette.accent, in: Capsule())
            }
        }
        .padding(18)
        .background(
            DistrictTheme.Palette.surface,
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
    }

    private var whySocialize: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Going together, without the awkward part")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(DistrictTheme.Palette.textPrimary)
            Text(
                "We find someone compatible using mocked interests, District activity and "
                    + "Zomato/Blinkit preference signals. You only chat after both people agree."
            )
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(DistrictTheme.Palette.textSecondary)
            .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func primaryButton(_ listing: SocializeListing) -> some View {
        Button {
            if store.socializeModeEnabled {
                path.append(AppRoute.matchListing(listing.id))
            } else {
                store.bookNormally(listingID: listing.id)
                showingBookedAlert = true
            }
        } label: {
            Label(
                store.socializeModeEnabled
                    ? "Find someone & save 20%"
                    : "Book now — "
                        + listing.pricePerPerson.formatted(
                            .currency(code: "INR").precision(.fractionLength(0))
                        ),
                systemImage: store.socializeModeEnabled ? "person.2.fill" : "ticket.fill"
            )
            .font(.system(size: 16, weight: .bold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                store.socializeModeEnabled
                    ? DistrictTheme.Palette.accent
                    : listing.category.tint,
                in: RoundedRectangle(cornerRadius: 17, style: .continuous)
            )
        }
        .buttonStyle(PressableButtonStyle())
    }
}

#Preview {
    @Previewable @State var path = NavigationPath()
    let store = SocializeStore()
    return SocializeListingDetailView(
        path: $path,
        listingID: store.listings[0].id
    )
    .environmentObject(store)
}
