import SwiftUI

struct MatchMakingView: View {
    @EnvironmentObject private var store: SocializeStore
    @Binding var path: NavigationPath
    let listingID: UUID

    @State private var revealMatch = false

    var body: some View {
        ZStack {
            DistrictTheme.Palette.background.ignoresSafeArea()

            if
                let listing = store.listing(id: listingID),
                let session = store.session(for: listingID)
            {
                if !revealMatch && session.state == .searching {
                    searchingState(listing)
                } else {
                    matchResult(listing, session: session)
                }
            } else {
                ProgressView()
                    .tint(DistrictTheme.Palette.accent)
            }
        }
        .task(id: listingID) {
            let session = store.beginMatch(for: listingID)
            if session?.state == .searching {
                try? await Task.sleep(for: .milliseconds(1200))
                guard !Task.isCancelled else { return }
                store.sendMatchRequest(for: listingID)
            }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                revealMatch = true
            }
        }
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(DistrictTheme.Palette.background, for: .navigationBar)
        #endif
    }

    private func searchingState(_ listing: SocializeListing) -> some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .stroke(DistrictTheme.Palette.accent.opacity(0.18), lineWidth: 12)
                    .frame(width: 130, height: 130)

                ProgressView()
                    .controlSize(.large)
                    .tint(DistrictTheme.Palette.accent)

                Image(systemName: "person.2.fill")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(DistrictTheme.Palette.accent)
                    .offset(y: 42)
            }

            VStack(spacing: 8) {
                Text(
                    listing.category == .movies
                        ? "Finding a solo moviegoer…"
                        : "Finding your person…"
                )
                    .font(.system(size: 25, weight: .heavy))
                    .foregroundStyle(DistrictTheme.Palette.textPrimary)
                Text("Matching interests, order history and availability for \(listing.title).")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(DistrictTheme.Palette.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
            }
        }
    }

    private func matchResult(
        _ listing: SocializeListing,
        session: DirectMatchSession
    ) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                VStack(spacing: 6) {
                    Text(
                        session.state == .accepted
                            ? "You matched!"
                            : listing.category == .movies
                                ? "Solo moviegoer found"
                                : "We found someone"
                    )
                        .font(.system(size: 28, weight: .heavy))
                        .foregroundStyle(DistrictTheme.Palette.textPrimary)
                    Text(
                        session.state == .accepted
                            ? "Your together price is locked in."
                            : "A request has been sent. They choose whether to connect."
                    )
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(DistrictTheme.Palette.textSecondary)
                    .multilineTextAlignment(.center)
                }

                profileCard(session.profile)
                if listing.category == .movies {
                    soloTicketCard(listing, profile: session.profile)
                }
                compatibilityCard(session.profile)
                planRecap(listing)

                if session.state == .accepted {
                    acceptedActions(listing, profile: session.profile)
                } else {
                    waitingActions(profile: session.profile)
                }

                Label(
                    "Only mutual matches can chat. Meet at the public venue.",
                    systemImage: "shield.checkered"
                )
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(DistrictTheme.Palette.textSecondary)
            }
            .padding(.horizontal, DistrictTheme.Space.screenH)
            .padding(.top, 14)
            .padding(.bottom, 110)
        }
    }

    private func profileCard(_ profile: MatchProfile) -> some View {
        VStack(spacing: 14) {
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                DistrictTheme.Palette.accent.opacity(0.5),
                                DistrictTheme.CategoryTint.play.opacity(0.28)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 104, height: 104)
                    .overlay {
                        Image(systemName: profile.avatarSystemImage)
                            .font(.system(size: 47, weight: .semibold))
                            .foregroundStyle(.white)
                    }

                Text("\(profile.matchScore)%")
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(DistrictTheme.Palette.accent, in: Capsule())
            }

            Text("\(profile.name), \(profile.age)")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(DistrictTheme.Palette.textPrimary)

            HStack(spacing: 7) {
                ForEach(profile.interests, id: \.self) { interest in
                    Text(interest)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(DistrictTheme.Palette.textPrimary)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 6)
                        .background(DistrictTheme.Palette.surfaceRaised, in: Capsule())
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            DistrictTheme.Palette.surface,
            in: RoundedRectangle(cornerRadius: 24, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(DistrictTheme.Palette.accent.opacity(0.3), lineWidth: 1)
        }
    }

    private func compatibilityCard(_ profile: MatchProfile) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Why you match", systemImage: "sparkles")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(DistrictTheme.Palette.accent)

            Text(profile.matchReason)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(DistrictTheme.Palette.textPrimary)

            ForEach(profile.ecosystemSignals, id: \.self) { signal in
                Label(signal, systemImage: "checkmark.circle.fill")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(DistrictTheme.Palette.textSecondary)
            }

            Text("Demo uses local mock signals only.")
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(DistrictTheme.Palette.textTertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            DistrictTheme.Palette.surface,
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
    }

    private func soloTicketCard(
        _ listing: SocializeListing,
        profile: MatchProfile
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "ticket.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(DistrictTheme.CategoryTint.movies)
                .frame(width: 42, height: 42)
                .background(
                    DistrictTheme.CategoryTint.movies.opacity(0.16),
                    in: RoundedRectangle(cornerRadius: 13)
                )

            VStack(alignment: .leading, spacing: 3) {
                Text("\(profile.name) booked one ticket")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(DistrictTheme.Palette.textPrimary)
                Text(
                    "For \(listing.title). If they accept, you can discuss the showtime "
                        + "and replace it with a discounted together booking."
                )
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(DistrictTheme.Palette.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .background(
            DistrictTheme.Palette.surface,
            in: RoundedRectangle(cornerRadius: 18)
        )
    }

    private func planRecap(_ listing: SocializeListing) -> some View {
        HStack(spacing: 13) {
            Image(systemName: listing.systemImage)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(listing.category.tint)
                .frame(width: 44, height: 44)
                .background(listing.category.tint.opacity(0.16), in: RoundedRectangle(cornerRadius: 13))

            VStack(alignment: .leading, spacing: 3) {
                Text(listing.title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(DistrictTheme.Palette.textPrimary)
                Text(listing.venueName)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(DistrictTheme.Palette.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(
                    listing.socializePrice,
                    format: .currency(code: "INR").precision(.fractionLength(0))
                )
                .font(.system(size: 17, weight: .heavy))
                .foregroundStyle(DistrictTheme.Palette.textPrimary)
                Text("20% off")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(DistrictTheme.Palette.accent)
            }
        }
        .padding(15)
        .background(
            DistrictTheme.Palette.surface,
            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
        )
    }

    private func waitingActions(profile: MatchProfile) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                ProgressView()
                    .tint(DistrictTheme.Palette.accent)
                Text("Waiting for \(profile.name) to accept")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(DistrictTheme.Palette.textPrimary)
            }

            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    store.acceptMatchRequest(for: listingID)
                }
            } label: {
                Text("Demo: \(profile.name) accepts")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(
                        DistrictTheme.Palette.accent,
                        in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                    )
            }
            .buttonStyle(PressableButtonStyle())
        }
    }

    private func acceptedActions(
        _ listing: SocializeListing,
        profile: MatchProfile
    ) -> some View {
        VStack(spacing: 12) {
            Label(
                "\(profile.name) accepted · You both save "
                    + listing.socializeSavings.formatted(
                        .currency(code: "INR").precision(.fractionLength(0))
                    ),
                systemImage: "checkmark.circle.fill"
            )
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(DistrictTheme.Palette.accent)

            Button {
                path.append(AppRoute.matchChat(listing.id))
            } label: {
                Label("Open private chat", systemImage: "message.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        DistrictTheme.Palette.accent,
                        in: RoundedRectangle(cornerRadius: 17, style: .continuous)
                    )
            }
            .buttonStyle(PressableButtonStyle())
        }
    }
}

#Preview {
    @Previewable @State var path = NavigationPath()
    let store = SocializeStore()
    return MatchMakingView(path: $path, listingID: store.listings[0].id)
        .environmentObject(store)
}
