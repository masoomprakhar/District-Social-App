import SwiftUI

struct MyRoomsView: View {
    @EnvironmentObject private var store: SocializeStore
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
                    Text("Your upcoming Socialize plans")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(DistrictTheme.Palette.textSecondary)
                }

                if myRooms.isEmpty && store.joinedExperienceListings.isEmpty {
                    emptyState
                } else {
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

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "ticket")
                .font(.system(size: 38, weight: .semibold))
                .foregroundStyle(DistrictTheme.Palette.accent)
            Text("No Socialize bookings yet")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(DistrictTheme.Palette.textPrimary)
            Text("Join a movie or dining room and it will appear here.")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(DistrictTheme.Palette.textSecondary)
                .multilineTextAlignment(.center)
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
