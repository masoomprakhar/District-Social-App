import SwiftUI

struct ConfirmJoinView: View {
    @EnvironmentObject private var store: SocializeStore

    let roomID: UUID
    let onViewBookings: () -> Void
    let onDone: () -> Void

    @State private var receipt: JoinReceipt?

    var body: some View {
        Group {
            if let receipt {
                JoinSuccessView(
                    receipt: receipt,
                    onViewBookings: onViewBookings,
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
        .presentationDetents(receipt == nil ? [.medium, .large] : [.large])
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
                    Text("Confirm your spot")
                        .font(.system(size: 26, weight: .heavy))
                        .foregroundStyle(DistrictTheme.Palette.textPrimary)
                    Text("Your price updates with the group size.")
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
                        title: "\(projectedCount) of \(room.capacity) people after you join"
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
                        Text("Your final price")
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
                    "You’ll see who’s going. Meet at the venue.",
                    systemImage: "shield.checkered"
                )
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(DistrictTheme.Palette.textSecondary)

                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        receipt = store.join(roomID: room.id)
                    }
                } label: {
                    Text(
                        "Confirm & pay "
                            + projectedPrice.formatted(
                                .currency(code: "INR").precision(.fractionLength(0))
                            )
                    )
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
        onViewBookings: {},
        onDone: {}
    )
    .environmentObject(store)
}
