import SwiftUI

struct RoomDetailView: View {
    @EnvironmentObject private var store: SocializeStore
    @Binding var path: NavigationPath
    let roomID: UUID

    @State private var showingConfirmation = false

    var body: some View {
        Group {
            if let room = store.room(id: roomID) {
                ZStack(alignment: .bottom) {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 0) {
                            header(for: room)

                            VStack(alignment: .leading, spacing: 24) {
                                roomInformation(room)
                                whoIsGoing(room)
                                DiscountProgressView(room: room)
                                priceSummary(room)
                            }
                            .padding(.horizontal, DistrictTheme.Space.screenH)
                            .padding(.top, 22)
                            .padding(.bottom, 190)
                        }
                    }

                    joinButton(room)
                        .padding(.horizontal, DistrictTheme.Space.screenH)
                        .padding(.bottom, 78)
                }
                .background(DistrictTheme.Palette.background.ignoresSafeArea())
                .sheet(isPresented: $showingConfirmation) {
                    ConfirmJoinView(
                        roomID: room.id,
                        onDone: {
                            showingConfirmation = false
                        }
                    )
                    .environmentObject(store)
                }
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(DistrictTheme.Palette.background, for: .navigationBar)
                #endif
            } else {
                unavailableState
            }
        }
    }

    private func header(for room: SocializeRoom) -> some View {
        ZStack {
            LinearGradient(
                colors: headerColors(for: room.activityType),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Image(systemName: room.activityType.symbolName)
                .font(.system(size: 90, weight: .semibold))
                .foregroundStyle(.white.opacity(0.18))
                .offset(x: 90, y: -10)

            VStack(alignment: .leading, spacing: 8) {
                Spacer()
                Text(room.activityType.singularTitle.uppercased())
                    .font(.system(size: 11, weight: .heavy))
                    .tracking(1.1)
                    .foregroundStyle(.white.opacity(0.7))
                Text(room.title)
                    .font(.system(size: 28, weight: .heavy))
                    .foregroundStyle(.white)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
        }
        .frame(height: 238)
    }

    private func roomInformation(_ room: SocializeRoom) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            informationRow(
                icon: "mappin.and.ellipse",
                title: room.venueName,
                subtitle: room.venueArea
            )
            informationRow(
                icon: "calendar",
                title: room.dateTime.formatted(date: .complete, time: .omitted),
                subtitle: room.dateTime.formatted(date: .omitted, time: .shortened)
            )
        }
        .padding(16)
        .background(
            DistrictTheme.Palette.surface,
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(DistrictTheme.Palette.border, lineWidth: 1)
        }
    }

    private func informationRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(DistrictTheme.Palette.accent)
                .frame(width: 38, height: 38)
                .background(DistrictTheme.Palette.accentSoft, in: RoundedRectangle(cornerRadius: 11))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(DistrictTheme.Palette.textPrimary)
                Text(subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(DistrictTheme.Palette.textSecondary)
            }
        }
    }

    private func whoIsGoing(_ room: SocializeRoom) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Who’s going")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(DistrictTheme.Palette.textPrimary)
                Spacer()
                Text("\(room.joinedCount) of \(room.capacity) spots filled")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(DistrictTheme.Palette.textSecondary)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(Array(room.members.enumerated()), id: \.element.id) { index, member in
                        VStack(spacing: 7) {
                            Circle()
                                .fill(avatarColor(index).opacity(0.2))
                                .frame(width: 50, height: 50)
                                .overlay {
                                    Image(systemName: member.avatarSystemImage)
                                        .font(.system(size: 22, weight: .semibold))
                                        .foregroundStyle(avatarColor(index))
                                }
                                .overlay {
                                    Circle().stroke(DistrictTheme.Palette.border, lineWidth: 1)
                                }

                            Text(member.name)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(DistrictTheme.Palette.textPrimary)
                                .lineLimit(1)

                            if index == 0 {
                                Text("HOST")
                                    .font(.system(size: 8, weight: .heavy))
                                    .tracking(0.5)
                                    .foregroundStyle(DistrictTheme.Palette.accent)
                            }
                        }
                        .frame(width: 58)
                    }
                }
            }
        }
    }

    private func priceSummary(_ room: SocializeRoom) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Price summary")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(DistrictTheme.Palette.textPrimary)

            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(room.basePrice, format: .currency(code: "INR").precision(.fractionLength(0)))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(DistrictTheme.Palette.textSecondary)
                        .strikethrough()
                    Text(room.currentPrice, format: .currency(code: "INR").precision(.fractionLength(0)))
                        .font(.system(size: 28, weight: .heavy))
                        .foregroundStyle(DistrictTheme.Palette.textPrimary)
                }

                Spacer()

                Text(
                    "You save "
                        + room.savings(for: room.joinedCount)
                            .formatted(.currency(code: "INR").precision(.fractionLength(0)))
                )
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(DistrictTheme.Palette.accent)
            }
        }
        .padding(18)
        .background(
            DistrictTheme.Palette.surface,
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
    }

    private func joinButton(_ room: SocializeRoom) -> some View {
        let alreadyJoined = store.joinedRoomIDs.contains(room.id)
        let requestPending = store.requestedRoomIDs.contains(room.id)

        return Button {
            if alreadyJoined {
                path.append(AppRoute.groupChat(.room(room.id)))
            } else {
                showingConfirmation = true
            }
        } label: {
            Text(
                buttonTitle(
                    room,
                    alreadyJoined: alreadyJoined,
                    requestPending: requestPending
                )
            )
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    room.isFull && !alreadyJoined
                        ? DistrictTheme.Palette.surfaceRaised
                        : DistrictTheme.Palette.accent,
                    in: RoundedRectangle(cornerRadius: 17, style: .continuous)
                )
        }
        .buttonStyle(PressableButtonStyle())
        .disabled((room.isFull && !alreadyJoined) || requestPending)
    }

    private func buttonTitle(
        _ room: SocializeRoom,
        alreadyJoined: Bool,
        requestPending: Bool
    ) -> String {
        if alreadyJoined { return "Open group chat" }
        if requestPending { return "Request sent" }
        if room.isFull { return "Room full" }
        return "Request to join group"
    }

    private func headerColors(for type: SocializeActivityType) -> [Color] {
        switch type {
        case .movie:
            [
                Color(red: 0.20, green: 0.16, blue: 0.44),
                Color(red: 0.50, green: 0.28, blue: 0.68)
            ]
        case .dining:
            [
                Color(red: 0.40, green: 0.14, blue: 0.16),
                Color(red: 0.78, green: 0.34, blue: 0.24)
            ]
        case .event:
            [
                Color(red: 0.42, green: 0.25, blue: 0.08),
                Color(red: 0.88, green: 0.54, blue: 0.14)
            ]
        case .activity:
            [
                Color(red: 0.08, green: 0.30, blue: 0.44),
                Color(red: 0.18, green: 0.62, blue: 0.78)
            ]
        }
    }

    private func avatarColor(_ index: Int) -> Color {
        let colors = [
            DistrictTheme.CategoryTint.movies,
            DistrictTheme.CategoryTint.dining,
            DistrictTheme.CategoryTint.stores,
            DistrictTheme.CategoryTint.play
        ]
        return colors[index % colors.count]
    }

    private var unavailableState: some View {
        ZStack {
            DistrictTheme.Palette.background.ignoresSafeArea()
            ContentUnavailableView(
                "Room unavailable",
                systemImage: "person.2.slash",
                description: Text("This room may have been removed.")
            )
            .foregroundStyle(DistrictTheme.Palette.textPrimary)
        }
    }
}

#Preview {
    @Previewable @State var path = NavigationPath()
    let store = SocializeStore()
    return NavigationStack {
        RoomDetailView(path: $path, roomID: store.rooms[0].id)
            .environmentObject(store)
    }
}
