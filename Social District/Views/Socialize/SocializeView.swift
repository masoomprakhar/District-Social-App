import SwiftUI

/// Compatibility entry point retained for the existing app navigation.
struct SocializeView: View {
    @Binding var path: NavigationPath

    var body: some View {
        SocializeHomeView(path: $path)
    }
}

/// The Socialize tab: a hub for your matches, group rooms, and mode status.
/// Browsing plans and toggling Socialize Mode happen on the Home tab.
struct SocializeHomeView: View {
    @EnvironmentObject private var store: SocializeStore
    @Environment(\.openHome) private var openHome
    @Binding var path: NavigationPath

    private var sessions: [DirectMatchSession] {
        store.matchSessions.values.sorted { lhs, rhs in
            lhs.profile.name < rhs.profile.name
        }
    }

    private var myRooms: [SocializeRoom] {
        store.rooms.filter { store.joinedRoomIDs.contains($0.id) }
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 26) {
                VStack(alignment: .leading, spacing: 7) {
                    Text("Socialize")
                        .font(.system(size: 32, weight: .heavy))
                        .foregroundStyle(DistrictTheme.Palette.textPrimary)

                    Text("Your matches, groups, and together plans in one place.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(DistrictTheme.Palette.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                modeStatusCard

                if !sessions.isEmpty {
                    matchesSection
                }

                if !myRooms.isEmpty {
                    roomsSection
                }

                if sessions.isEmpty && myRooms.isEmpty {
                    emptyState
                }
            }
            .padding(.horizontal, DistrictTheme.Space.screenH)
            .padding(.top, 10)
            .padding(.bottom, 116)
        }
        .background(DistrictTheme.Palette.background.ignoresSafeArea())
        #if os(iOS)
        .toolbar(.hidden, for: .navigationBar)
        #endif
    }

    private var modeStatusCard: some View {
        HStack(spacing: 12) {
            Image(systemName: store.socializeModeEnabled ? "sparkles" : "person.2")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(
                    store.socializeModeEnabled ? .white : DistrictTheme.Palette.accent
                )
                .frame(width: 42, height: 42)
                .background(
                    store.socializeModeEnabled
                        ? DistrictTheme.Palette.accent
                        : DistrictTheme.Palette.accentSoft,
                    in: RoundedRectangle(cornerRadius: 13)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(
                    store.socializeModeEnabled
                        ? "Socialize Mode is on"
                        : "Socialize Mode is off"
                )
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(DistrictTheme.Palette.textPrimary)

                Text(
                    store.socializeModeEnabled
                        ? "Plans on Home show together prices and Match me."
                        : "Turn it on from the Home screen to unlock together pricing."
                )
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(DistrictTheme.Palette.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 6)

            Toggle("", isOn: $store.socializeModeEnabled)
                .labelsHidden()
                .tint(DistrictTheme.Palette.accent)
        }
        .padding(14)
        .background(
            store.socializeModeEnabled
                ? DistrictTheme.Palette.accentSoft
                : DistrictTheme.Palette.surface,
            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(
                    store.socializeModeEnabled
                        ? DistrictTheme.Palette.accent.opacity(0.35)
                        : DistrictTheme.Palette.border,
                    lineWidth: 1
                )
        }
        .animation(.easeInOut(duration: 0.2), value: store.socializeModeEnabled)
    }

    private var matchesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your matches")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(DistrictTheme.Palette.textPrimary)

            LazyVStack(spacing: 12) {
                ForEach(sessions) { session in
                    Button {
                        path.append(
                            session.state == .accepted
                                ? AppRoute.matchChat(session.listingID)
                                : AppRoute.matchListing(session.listingID)
                        )
                    } label: {
                        matchCard(session)
                    }
                    .buttonStyle(PressableButtonStyle())
                }
            }
        }
    }

    private func matchCard(_ session: DirectMatchSession) -> some View {
        HStack(spacing: 13) {
            Circle()
                .fill(DistrictTheme.Palette.accentSoft)
                .frame(width: 46, height: 46)
                .overlay {
                    Image(systemName: session.profile.avatarSystemImage)
                        .font(.system(size: 21, weight: .semibold))
                        .foregroundStyle(DistrictTheme.Palette.accent)
                }

            VStack(alignment: .leading, spacing: 3) {
                Text(session.profile.name)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(DistrictTheme.Palette.textPrimary)

                Text(store.listing(id: session.listingID)?.title ?? "Plan")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(DistrictTheme.Palette.textSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 6)

            Text(statusLabel(for: session.state))
                .font(.system(size: 10, weight: .heavy))
                .foregroundStyle(
                    session.state == .accepted
                        ? .white
                        : DistrictTheme.Palette.accent
                )
                .padding(.horizontal, 9)
                .padding(.vertical, 5)
                .background(
                    session.state == .accepted
                        ? AnyShapeStyle(DistrictTheme.Palette.accent)
                        : AnyShapeStyle(DistrictTheme.Palette.accentSoft),
                    in: Capsule()
                )
        }
        .padding(14)
        .background(
            DistrictTheme.Palette.surface,
            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(DistrictTheme.Palette.border, lineWidth: 1)
        }
    }

    private func statusLabel(for state: MatchRequestState) -> String {
        switch state {
        case .searching: "MATCHING"
        case .requestSent: "REQUESTED"
        case .accepted: "CHAT OPEN"
        }
    }

    private var roomsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your group rooms")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(DistrictTheme.Palette.textPrimary)

            LazyVStack(spacing: 14) {
                ForEach(myRooms) { room in
                    Button {
                        path.append(AppRoute.roomDetail(room.id))
                    } label: {
                        RoomCardView(room: room)
                    }
                    .buttonStyle(PressableButtonStyle())
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "person.2.wave.2")
                .font(.system(size: 36, weight: .semibold))
                .foregroundStyle(DistrictTheme.Palette.accent)

            Text("Nothing here yet")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(DistrictTheme.Palette.textPrimary)

            Text("Browse plans on Home, tap Match me on one you like, and your matches will show up here.")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(DistrictTheme.Palette.textSecondary)
                .multilineTextAlignment(.center)

            Button("Browse plans") {
                openHome()
            }
            .font(.system(size: 14, weight: .bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(DistrictTheme.Palette.accent, in: Capsule())
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 56)
        .padding(.horizontal, 24)
        .background(
            DistrictTheme.Palette.surface,
            in: RoundedRectangle(cornerRadius: 22, style: .continuous)
        )
    }
}

#Preview {
    @Previewable @State var path = NavigationPath()
    SocializeHomeView(path: $path)
        .environmentObject(SocializeStore())
}
