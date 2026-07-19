import SwiftUI

struct HostDashboardView: View {
    @EnvironmentObject private var store: SocializeStore
    @Binding var path: NavigationPath
    @State private var showingCreateEvent = false

    private var pendingRequests: [HostJoinRequest] {
        store.hostJoinRequests.filter { $0.status == .pending }
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Host dashboard")
                        .font(.system(size: 30, weight: .heavy))
                        .foregroundStyle(DistrictTheme.Palette.textPrimary)
                    Text("Review requests and manage your groups.")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(DistrictTheme.Palette.textSecondary)
                }

                stats
                createEventButton

                VStack(alignment: .leading, spacing: 12) {
                    Text("Join requests")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(DistrictTheme.Palette.textPrimary)

                    if pendingRequests.isEmpty {
                        Text("All requests have been reviewed.")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(DistrictTheme.Palette.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 30)
                            .background(
                                DistrictTheme.Palette.surface,
                                in: RoundedRectangle(cornerRadius: 18)
                            )
                    } else {
                        ForEach(pendingRequests) { request in
                            requestCard(request)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Your groups")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(DistrictTheme.Palette.textPrimary)

                    ForEach(store.hostedRooms) { room in
                        Button {
                            path.append(AppRoute.roomDetail(room.id))
                        } label: {
                            RoomCardView(room: room)
                        }
                        .buttonStyle(PressableButtonStyle())
                    }
                }
            }
            .padding(.horizontal, DistrictTheme.Space.screenH)
            .padding(.top, 10)
            .padding(.bottom, 110)
        }
        .background(DistrictTheme.Palette.background.ignoresSafeArea())
        .sheet(isPresented: $showingCreateEvent) {
            CreateRoomView { room in
                DispatchQueue.main.async {
                    path.append(AppRoute.roomDetail(room.id))
                }
            }
            .environmentObject(store)
        }
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(DistrictTheme.Palette.background, for: .navigationBar)
        #endif
    }

    private var createEventButton: some View {
        Button {
            showingCreateEvent = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 19, weight: .semibold))
                    .frame(width: 42, height: 42)
                    .background(.white.opacity(0.16), in: RoundedRectangle(cornerRadius: 13))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Host a new event")
                        .font(.system(size: 15, weight: .bold))
                    Text("Set the venue, date, group size, and price")
                        .font(.system(size: 11, weight: .medium))
                        .opacity(0.75)
                }

                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
            }
            .foregroundStyle(.white)
            .padding(15)
            .background(
                DistrictTheme.Palette.accent,
                in: RoundedRectangle(cornerRadius: 18, style: .continuous)
            )
        }
        .buttonStyle(PressableButtonStyle())
    }

    private var stats: some View {
        HStack(spacing: 0) {
            stat("\(store.hostedRooms.count)", "Groups")
            Divider().frame(height: 32).overlay(DistrictTheme.Palette.border)
            stat("\(pendingRequests.count)", "Pending")
            Divider().frame(height: 32).overlay(DistrictTheme.Palette.border)
            stat(
                "\(store.hostedRooms.reduce(0) { $0 + $1.joinedCount })",
                "Members"
            )
        }
        .padding(.vertical, 16)
        .background(
            DistrictTheme.Palette.surface,
            in: RoundedRectangle(cornerRadius: 20)
        )
    }

    private func stat(_ value: String, _ label: String) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 21, weight: .heavy))
                .foregroundStyle(DistrictTheme.Palette.textPrimary)
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(DistrictTheme.Palette.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    private func requestCard(_ request: HostJoinRequest) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Circle()
                    .fill(DistrictTheme.Palette.accentSoft)
                    .frame(width: 46, height: 46)
                    .overlay {
                        Image(systemName: request.member.avatarSystemImage)
                            .foregroundStyle(DistrictTheme.Palette.accent)
                    }

                VStack(alignment: .leading, spacing: 3) {
                    Text(request.member.name)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(DistrictTheme.Palette.textPrimary)
                    Text("Wants to join your group")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(DistrictTheme.Palette.textSecondary)
                }
            }

            Text("“\(request.note)”")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(DistrictTheme.Palette.textSecondary)

            HStack(spacing: 10) {
                Button {
                    withAnimation {
                        store.declineHostRequest(request.id)
                    }
                } label: {
                    Text("Decline")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(DistrictTheme.Palette.textSecondary)

                Button {
                    withAnimation {
                        store.approveHostRequest(request.id)
                    }
                } label: {
                    Text("Accept")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(DistrictTheme.Palette.accent)
            }
        }
        .padding(16)
        .background(
            DistrictTheme.Palette.surface,
            in: RoundedRectangle(cornerRadius: 20)
        )
    }
}

