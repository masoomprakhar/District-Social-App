import SwiftUI

struct GroupExperienceBookingView: View {
    @EnvironmentObject private var store: SocializeStore
    @Environment(\.openBookings) private var openBookings
    @Binding var path: NavigationPath
    let listingID: UUID

    @State private var selectedOption = ""
    @State private var receipt: JoinReceipt?

    var body: some View {
        Group {
            if
                let listing = store.listing(id: listingID),
                let suggestion = store.experienceSuggestion(for: listing)
            {
                ZStack(alignment: .bottom) {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 22) {
                            header(listing, suggestion: suggestion)
                            groupCard(listing, suggestion: suggestion)
                            optionPicker(listing, suggestion: suggestion)
                            priceCard(listing, suggestion: suggestion)
                            reassurance(listing)
                        }
                        .padding(.horizontal, DistrictTheme.Space.screenH)
                        .padding(.top, 10)
                        .padding(.bottom, 190)
                    }

                    joinButton(listing, suggestion: suggestion)
                        .padding(.horizontal, DistrictTheme.Space.screenH)
                        .padding(.bottom, 78)
                }
                .background(DistrictTheme.Palette.background.ignoresSafeArea())
                .onAppear {
                    if selectedOption.isEmpty {
                        selectedOption = suggestion.bookingOptions.first ?? ""
                    }
                }
                .sheet(item: $receipt) { receipt in
                    JoinSuccessView(
                        receipt: receipt,
                        onViewBookings: {
                            self.receipt = nil
                            DispatchQueue.main.async {
                                openBookings()
                            }
                        },
                        onDone: {
                            self.receipt = nil
                        }
                    )
                }
            } else {
                Text("Group suggestion unavailable")
                    .foregroundStyle(DistrictTheme.Palette.textSecondary)
            }
        }
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(DistrictTheme.Palette.background, for: .navigationBar)
        #endif
    }

    private func header(
        _ listing: SocializeListing,
        suggestion: ExperienceGroupSuggestion
    ) -> some View {
        HStack(spacing: 14) {
            Image(systemName: listing.category.symbolName)
                .font(.system(size: 25, weight: .semibold))
                .foregroundStyle(listing.category.tint)
                .frame(width: 56, height: 56)
                .background(
                    listing.category.tint.opacity(0.16),
                    in: RoundedRectangle(cornerRadius: 17)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(listing.title)
                    .font(.system(size: 23, weight: .heavy))
                    .foregroundStyle(DistrictTheme.Palette.textPrimary)
                    .lineLimit(2)
                Text("\(listing.venueName) · \(listing.venueArea)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(DistrictTheme.Palette.textSecondary)
            }
        }
    }

    private func groupCard(
        _ listing: SocializeListing,
        suggestion: ExperienceGroupSuggestion
    ) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(suggestion.cardTitle)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(DistrictTheme.Palette.textPrimary)
                    Text(suggestion.cardSubtitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(DistrictTheme.Palette.textSecondary)
                }

                Spacer()

                Text("\(suggestion.spotsLeft) spots")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(listing.category.tint)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 6)
                    .background(listing.category.tint.opacity(0.14), in: Capsule())
            }

            HStack(spacing: 12) {
                AvatarStackView(
                    members: suggestion.members,
                    maxVisible: 5,
                    size: 40
                )

                Text("\(suggestion.joinedCount) people already going")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(DistrictTheme.Palette.textSecondary)
            }
        }
        .padding(17)
        .background(
            DistrictTheme.Palette.surface,
            in: RoundedRectangle(cornerRadius: 22, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(listing.category.tint.opacity(0.28), lineWidth: 1)
        }
    }

    private func optionPicker(
        _ listing: SocializeListing,
        suggestion: ExperienceGroupSuggestion
    ) -> some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack(spacing: 8) {
                Image(systemName: selectionSymbol(listing.category))
                    .foregroundStyle(listing.category.tint)
                Text(suggestion.selectionTitle)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(DistrictTheme.Palette.textPrimary)
            }

            ForEach(suggestion.bookingOptions, id: \.self) { option in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedOption = option
                    }
                } label: {
                    HStack {
                        Text(option)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(DistrictTheme.Palette.textPrimary)

                        Spacer()

                        Image(
                            systemName: selectedOption == option
                                ? "checkmark.circle.fill"
                                : "circle"
                        )
                        .foregroundStyle(
                            selectedOption == option
                                ? listing.category.tint
                                : DistrictTheme.Palette.textTertiary
                        )
                    }
                    .padding(14)
                    .background(
                        selectedOption == option
                            ? listing.category.tint.opacity(0.13)
                            : DistrictTheme.Palette.surface,
                        in: RoundedRectangle(cornerRadius: 15)
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(
                                selectedOption == option
                                    ? listing.category.tint.opacity(0.5)
                                    : DistrictTheme.Palette.border,
                                lineWidth: 1
                            )
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func priceCard(
        _ listing: SocializeListing,
        suggestion: ExperienceGroupSuggestion
    ) -> some View {
        let finalPrice = listing.pricePerPerson
            * (1 - Double(suggestion.discountPercent) / 100)
        let savings = listing.pricePerPerson - finalPrice

        return HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Group price per person")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(DistrictTheme.Palette.textSecondary)
                HStack(alignment: .firstTextBaseline, spacing: 7) {
                    Text(
                        finalPrice,
                        format: .currency(code: "INR").precision(.fractionLength(0))
                    )
                    .font(.system(size: 26, weight: .heavy))
                    .foregroundStyle(DistrictTheme.Palette.textPrimary)
                    Text(
                        listing.pricePerPerson,
                        format: .currency(code: "INR").precision(.fractionLength(0))
                    )
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(DistrictTheme.Palette.textSecondary)
                    .strikethrough()
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text("\(suggestion.discountPercent)% OFF")
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundStyle(listing.category.tint)
                Text(
                    "Save "
                        + savings.formatted(
                            .currency(code: "INR").precision(.fractionLength(0))
                        )
                )
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(DistrictTheme.Palette.textSecondary)
            }
        }
        .padding(17)
        .background(
            DistrictTheme.Palette.surface,
            in: RoundedRectangle(cornerRadius: 20)
        )
    }

    private func reassurance(_ listing: SocializeListing) -> some View {
        Label(reassuranceText(listing.category), systemImage: "message.fill")
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(DistrictTheme.Palette.textSecondary)
            .padding(.horizontal, 4)
    }

    private func joinButton(
        _ listing: SocializeListing,
        suggestion: ExperienceGroupSuggestion
    ) -> some View {
        let alreadyJoined = store.joinedExperienceIDs.contains(listing.id)
        let finalPrice = listing.pricePerPerson
            * (1 - Double(suggestion.discountPercent) / 100)

        return Button {
            receipt = store.joinExperience(listingID: listing.id)
        } label: {
            Text(
                alreadyJoined
                    ? "Already joined"
                    : "Join group — "
                        + finalPrice.formatted(
                            .currency(code: "INR").precision(.fractionLength(0))
                        )
            )
            .font(.system(size: 16, weight: .bold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                alreadyJoined
                    ? DistrictTheme.Palette.surfaceRaised
                    : listing.category.tint,
                in: RoundedRectangle(cornerRadius: 17)
            )
        }
        .buttonStyle(PressableButtonStyle())
        .disabled(alreadyJoined || selectedOption.isEmpty)
    }

    private func selectionSymbol(_ category: SocializeCategory) -> String {
        switch category {
        case .events: "chair.lounge.fill"
        case .stores: "clock.fill"
        case .activities: "calendar"
        case .play: "sportscourt.fill"
        case .dining: "fork.knife"
        case .movies: "film.fill"
        }
    }

    private func reassuranceText(_ category: SocializeCategory) -> String {
        switch category {
        case .events:
            "Your tickets stay together. Group chat opens after joining."
        case .stores:
            "Coordinate where to meet and what stores to explore in group chat."
        case .activities:
            "You’ll enter the same session and meet at the venue."
        case .play:
            "Your court or team slot is reserved with the group."
        case .dining:
            "Meet the group at the restaurant."
        case .movies:
            "Your seats are reserved together."
        }
    }
}

#Preview {
    @Previewable @State var path = NavigationPath()
    let store = SocializeStore()
    let listing = store.listings.first { $0.category == .events }!
    return GroupExperienceBookingView(path: $path, listingID: listing.id)
        .environmentObject(store)
}
