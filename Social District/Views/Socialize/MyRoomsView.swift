import SwiftUI

struct MyRoomsView: View {
    @EnvironmentObject private var store: SocializeStore
    @Environment(\.openSocialize) private var openSocialize
    @StateObject private var liveActivity = LiveActivityManager()
    var onOpenRoom: (UUID) -> Void = { _ in }
    var onOpenExperience: (UUID) -> Void = { _ in }

    private var myRooms: [SocializeRoom] {
        store.rooms.filter { store.joinedRoomIDs.contains($0.id) }
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("My bookings")
                        .font(.system(size: 30, weight: .heavy))
                        .foregroundStyle(DistrictTheme.Palette.textPrimary)
                    Text("Tickets, reservations, and upcoming plans")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(DistrictTheme.Palette.textSecondary)
                }

                if let upcomingRoom = myRooms.first {
                    liveActivityCard(upcomingRoom)
                }

                if myRooms.isEmpty
                    && store.joinedExperienceListings.isEmpty
                    && store.standardBookingListings.isEmpty {
                    emptyState
                } else {
                    if !store.standardBookingListings.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Regular bookings")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(DistrictTheme.Palette.textPrimary)

                            LazyVStack(spacing: 12) {
                                ForEach(store.standardBookingListings) { listing in
                                    Button {
                                        onOpenExperience(listing.id)
                                    } label: {
                                        SocializeListingCardView(
                                            listing: listing,
                                            socializeModeEnabled: false
                                        )
                                    }
                                    .buttonStyle(PressableButtonStyle())
                                }
                            }
                        }
                    }

                    if !store.joinedExperienceListings.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Together bookings")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(DistrictTheme.Palette.textPrimary)

                            LazyVStack(spacing: 12) {
                                ForEach(store.joinedExperienceListings) { listing in
                                    Button {
                                        onOpenExperience(listing.id)
                                    } label: {
                                        SocializeListingCardView(
                                            listing: listing,
                                            socializeModeEnabled: true
                                        )
                                    }
                                    .buttonStyle(PressableButtonStyle())
                                }
                            }
                        }
                    }

                    if !myRooms.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Group rooms")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(DistrictTheme.Palette.textPrimary)

                            LazyVStack(spacing: 14) {
                                ForEach(myRooms) { room in
                                    Button {
                                        onOpenRoom(room.id)
                                    } label: {
                                        RoomCardView(room: room)
                                    }
                                    .buttonStyle(PressableButtonStyle())
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
        .toolbar(.hidden, for: .navigationBar)
        #endif
    }

    private func liveActivityCard(_ room: SocializeRoom) -> some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack(spacing: 11) {
                Image(systemName: "wave.3.right.circle.fill")
                    .font(.system(size: 25))
                    .foregroundStyle(DistrictTheme.Palette.accent)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Live Activity")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(DistrictTheme.Palette.textPrimary)
                    Text("Follow your meetup from the Lock Screen and Dynamic Island.")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(DistrictTheme.Palette.textSecondary)
                }
            }

            if let message = liveActivity.message {
                Text(message)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(DistrictTheme.Palette.textSecondary)
            }

            Button {
                Task {
                    if liveActivity.activeRoomID == room.id {
                        await liveActivity.endAll()
                    } else {
                        await liveActivity.start(for: room)
                    }
                }
            } label: {
                Label(
                    liveActivity.activeRoomID == room.id
                        ? "End Live Activity"
                        : "Start for \(room.title)",
                    systemImage:
                        liveActivity.activeRoomID == room.id
                            ? "stop.circle.fill"
                            : "play.circle.fill"
                )
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background(
                    DistrictTheme.Palette.accent,
                    in: RoundedRectangle(cornerRadius: 14)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(
            DistrictTheme.Palette.surface,
            in: RoundedRectangle(cornerRadius: 20)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(DistrictTheme.Palette.accent.opacity(0.3), lineWidth: 1)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "ticket")
                .font(.system(size: 38, weight: .semibold))
                .foregroundStyle(DistrictTheme.Palette.accent)
            Text("No bookings yet")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(DistrictTheme.Palette.textPrimary)
            Text("Book a plan or join a group and it will appear here.")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(DistrictTheme.Palette.textSecondary)
                .multilineTextAlignment(.center)

            Button("Discover Socialize") {
                openSocialize()
            }
            .font(.system(size: 14, weight: .bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(DistrictTheme.Palette.accent, in: Capsule())
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 70)
        .padding(.horizontal, 24)
        .background(
            DistrictTheme.Palette.surface,
            in: RoundedRectangle(cornerRadius: 22, style: .continuous)
        )
    }
}

#Preview {
    MyRoomsView()
        .environmentObject(SocializeStore())
}
