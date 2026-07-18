import SwiftUI

struct MovieSeatSelectionView: View {
    @EnvironmentObject private var store: SocializeStore
    @Binding var path: NavigationPath
    let listingID: UUID
    let roomID: UUID

    @State private var selectedSeatCode = ""
    @State private var receipt: JoinReceipt?

    private let rows = ["A", "B", "C", "D", "E", "F"]
    private let occupiedSeatCodes: Set<String> = [
        "A2", "A7", "B1", "B6", "C2", "C7", "E1", "E5", "F3", "F8"
    ]

    var body: some View {
        Group {
            if
                let listing = store.listing(id: listingID),
                let room = store.room(id: roomID)
            {
                ZStack(alignment: .bottom) {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 24) {
                            header(listing, room: room)
                            screenIndicator
                            seatMap(room: room)
                            legend
                            groupSummary(room)
                        }
                        .padding(.horizontal, 18)
                        .padding(.top, 10)
                        .padding(.bottom, 190)
                    }

                    bookingButton(room)
                        .padding(.horizontal, DistrictTheme.Space.screenH)
                        .padding(.bottom, 78)
                }
                .background(DistrictTheme.Palette.background.ignoresSafeArea())
                .onAppear {
                    if selectedSeatCode.isEmpty {
                        selectedSeatCode = recommendedSeatCode(for: room)
                    }
                }
                .sheet(item: $receipt) { receipt in
                    JoinSuccessView(
                        receipt: receipt,
                        onViewBookings: {
                            self.receipt = nil
                            DispatchQueue.main.async {
                                path.append(AppRoute.myRooms)
                            }
                        },
                        onDone: {
                            self.receipt = nil
                        }
                    )
                }
            } else {
                Text("Show or group unavailable")
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
        room: SocializeRoom
    ) -> some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                Image(systemName: "movieclapper.fill")
                    .font(.system(size: 21, weight: .semibold))
                    .foregroundStyle(DistrictTheme.CategoryTint.movies)
                    .frame(width: 46, height: 46)
                    .background(
                        DistrictTheme.CategoryTint.movies.opacity(0.16),
                        in: RoundedRectangle(cornerRadius: 14)
                    )

                VStack(alignment: .leading, spacing: 3) {
                    Text(listing.title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(DistrictTheme.Palette.textPrimary)
                    Text("\(listing.venueName) · \(listing.venueArea)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(DistrictTheme.Palette.textSecondary)
                }

                Spacer()
            }

            HStack(spacing: 10) {
                AvatarStackView(members: room.members, maxVisible: 4, size: 32)

                Text("\(room.hostName)’s group is seated in Row D")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(DistrictTheme.Palette.textPrimary)

                Spacer()
            }
            .padding(12)
            .background(
                DistrictTheme.CategoryTint.movies.opacity(0.12),
                in: RoundedRectangle(cornerRadius: 15)
            )
        }
    }

    private var screenIndicator: some View {
        VStack(spacing: 8) {
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.55),
                            Color.white.opacity(0.04)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 8)
                .padding(.horizontal, 32)

            Text("SCREEN THIS WAY")
                .font(.system(size: 9, weight: .bold))
                .tracking(1)
                .foregroundStyle(DistrictTheme.Palette.textTertiary)
        }
        .padding(.top, 8)
    }

    private func seatMap(room: SocializeRoom) -> some View {
        VStack(spacing: 11) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: 6) {
                    Text(row)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(DistrictTheme.Palette.textTertiary)
                        .frame(width: 14)

                    ForEach(1...8, id: \.self) { number in
                        seatButton(
                            code: "\(row)\(number)",
                            room: room
                        )
                    }
                }
            }
        }
        .padding(14)
        .background(
            DistrictTheme.Palette.surface,
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
    }

    private func seatButton(
        code: String,
        room: SocializeRoom
    ) -> some View {
        let state = seatState(code, room: room)

        return Button {
            guard state == .available || state == .recommended || state == .selected else {
                return
            }
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                selectedSeatCode = code
            }
        } label: {
            Image(systemName: "chair.lounge.fill")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(seatForeground(state))
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .background(seatBackground(state), in: RoundedRectangle(cornerRadius: 6))
                .overlay {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(seatStroke(state), lineWidth: state == .recommended ? 1.5 : 1)
                }
        }
        .buttonStyle(.plain)
        .disabled(state == .occupied || state == .group)
        .accessibilityLabel(accessibilityLabel(code: code, state: state))
    }

    private var legend: some View {
        HStack(spacing: 16) {
            legendItem(color: DistrictTheme.Palette.surfaceRaised, title: "Available")
            legendItem(color: DistrictTheme.Palette.accent, title: "Your group")
            legendItem(color: .white, title: "Selected")
        }
        .frame(maxWidth: .infinity)
    }

    private func legendItem(color: Color, title: String) -> some View {
        HStack(spacing: 5) {
            RoundedRectangle(cornerRadius: 3)
                .fill(color)
                .frame(width: 11, height: 11)
            Text(title)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(DistrictTheme.Palette.textSecondary)
        }
    }

    private func groupSummary(_ room: SocializeRoom) -> some View {
        let projectedCount = min(room.capacity, room.joinedCount + 1)
        let discount = room.discountPercent(for: projectedCount)
        let savings = room.savings(for: projectedCount)

        return HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(selectedSeatCode.isEmpty ? "Choose a seat" : "Seat \(selectedSeatCode)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(DistrictTheme.Palette.textPrimary)
                Text("Next to the group in Row D")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(DistrictTheme.Palette.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text("Save \(savings.formatted(.currency(code: "INR").precision(.fractionLength(0))))")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(DistrictTheme.Palette.accent)
                Text("\(discount)% group discount")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(DistrictTheme.Palette.textSecondary)
            }
        }
        .padding(16)
        .background(
            DistrictTheme.Palette.accentSoft,
            in: RoundedRectangle(cornerRadius: 18)
        )
    }

    private func bookingButton(_ room: SocializeRoom) -> some View {
        let alreadyJoined = store.joinedRoomIDs.contains(room.id)
        let projectedCount = min(room.capacity, room.joinedCount + 1)
        let price = room.price(for: projectedCount)

        return Button {
            receipt = store.join(roomID: room.id)
        } label: {
            Text(
                alreadyJoined
                    ? "Seat already booked"
                    : "Book \(selectedSeatCode) beside the group — "
                        + price.formatted(
                            .currency(code: "INR").precision(.fractionLength(0))
                        )
            )
            .font(.system(size: 15, weight: .bold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                alreadyJoined || selectedSeatCode.isEmpty
                    ? DistrictTheme.Palette.surfaceRaised
                    : DistrictTheme.Palette.accent,
                in: RoundedRectangle(cornerRadius: 17, style: .continuous)
            )
        }
        .buttonStyle(PressableButtonStyle())
        .disabled(alreadyJoined || selectedSeatCode.isEmpty)
    }

    private func groupSeatCodes(for room: SocializeRoom) -> Set<String> {
        let groupSeats = (0..<room.joinedCount).map { "D\(3 + $0)" }
        return Set(groupSeats)
    }

    private func recommendedSeatCode(for room: SocializeRoom) -> String {
        let rightSide = 3 + room.joinedCount
        if rightSide <= 8 {
            return "D\(rightSide)"
        }
        return "D2"
    }

    private func seatState(
        _ code: String,
        room: SocializeRoom
    ) -> SeatState {
        if selectedSeatCode == code { return .selected }
        if groupSeatCodes(for: room).contains(code) { return .group }
        if occupiedSeatCodes.contains(code) { return .occupied }
        if recommendedSeatCode(for: room) == code { return .recommended }
        return .available
    }

    private func seatBackground(_ state: SeatState) -> Color {
        switch state {
        case .available, .recommended:
            DistrictTheme.Palette.surfaceRaised
        case .group:
            DistrictTheme.Palette.accent
        case .selected:
            .white
        case .occupied:
            DistrictTheme.Palette.background
        }
    }

    private func seatForeground(_ state: SeatState) -> Color {
        switch state {
        case .available, .recommended:
            DistrictTheme.Palette.textSecondary
        case .group:
            .white
        case .selected:
            DistrictTheme.Palette.accent
        case .occupied:
            DistrictTheme.Palette.textTertiary.opacity(0.35)
        }
    }

    private func seatStroke(_ state: SeatState) -> Color {
        switch state {
        case .recommended:
            DistrictTheme.Palette.accent
        case .selected:
            .white
        default:
            DistrictTheme.Palette.border
        }
    }

    private func accessibilityLabel(code: String, state: SeatState) -> String {
        switch state {
        case .available: "Seat \(code), available"
        case .recommended: "Seat \(code), recommended beside the group"
        case .group: "Seat \(code), occupied by your group"
        case .selected: "Seat \(code), selected"
        case .occupied: "Seat \(code), unavailable"
        }
    }
}

private enum SeatState: Equatable {
    case available
    case recommended
    case group
    case selected
    case occupied
}

#Preview {
    @Previewable @State var path = NavigationPath()
    let store = SocializeStore()
    let listing = store.listings.first { $0.category == .movies }!
    let room = store.suggestedRoom(for: listing)!
    return MovieSeatSelectionView(
        path: $path,
        listingID: listing.id,
        roomID: room.id
    )
    .environmentObject(store)
}
