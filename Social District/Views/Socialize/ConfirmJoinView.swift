import SwiftUI

struct ConfirmJoinView: View {
    @EnvironmentObject private var store: SocializeStore

    let roomID: UUID
    let onDone: () -> Void

    @State private var requestSent = false

    var body: some View {
        Group {
            if requestSent, let room = store.room(id: roomID) {
                GroupRequestSentView(
                    title: room.title,
                    hostName: room.hostName,
                    onDone: onDone
                )
            } else if let room = store.room(id: roomID) {
                confirmation(room)
            } else {
                Text("Room unavailable")
                    .foregroundStyle(DistrictTheme.Palette.textPrimary)
            }
        }
        .background(DistrictTheme.Palette.background.ignoresSafeArea())
        .presentationDetents(requestSent ? [.large] : [.medium, .large])
        .presentationDragIndicator(.visible)
        .preferredColorScheme(.dark)
    }

    private func confirmation(_ room: SocializeRoom) -> some View {
        let projectedCount = min(room.capacity, room.joinedCount + 1)
        let projectedDiscount = room.discountPercent(for: projectedCount)
        let projectedPrice = room.price(for: projectedCount)

        return ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 7) {
                    Text("Request to join")
                        .font(.system(size: 26, weight: .heavy))
                        .foregroundStyle(DistrictTheme.Palette.textPrimary)
                    Text("\(room.hostName) will review your request.")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(DistrictTheme.Palette.textSecondary)
                }

                VStack(spacing: 14) {
                    recapRow(icon: room.activityType.symbolName, title: room.title)
                    recapRow(icon: "mappin.and.ellipse", title: "\(room.venueName), \(room.venueArea)")
                    recapRow(
                        icon: "calendar",
                        title: room.dateTime.formatted(date: .abbreviated, time: .shortened)
                    )
                    recapRow(
                        icon: "person.2.fill",
                        title: "\(room.joinedCount) of \(room.capacity) people currently going"
                    )
                }
                .padding(16)
                .background(
                    DistrictTheme.Palette.surface,
                    in: RoundedRectangle(cornerRadius: 20, style: .continuous)
                )

                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("\(projectedDiscount)% group discount")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(DistrictTheme.Palette.accent)
                        Text("Estimated price if accepted")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(DistrictTheme.Palette.textSecondary)
                    }

                    Spacer()

                    Text(
                        projectedPrice,
                        format: .currency(code: "INR").precision(.fractionLength(0))
                    )
                    .font(.system(size: 27, weight: .heavy))
                    .foregroundStyle(DistrictTheme.Palette.textPrimary)
                }

                Label(
                    "No charge now. Booking happens only after the host accepts.",
                    systemImage: "shield.checkered"
                )
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(DistrictTheme.Palette.textSecondary)

                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        requestSent = store.requestToJoin(roomID: room.id)
                    }
                } label: {
                    Text("Send join request")
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
            .padding(20)
        }
    }

    private func recapRow(icon: String, title: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(DistrictTheme.Palette.accent)
                .frame(width: 24)

            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(DistrictTheme.Palette.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    let store = SocializeStore()
    ConfirmJoinView(
        roomID: store.rooms[0].id,
        onDone: {}
    )
    .environmentObject(store)
}
