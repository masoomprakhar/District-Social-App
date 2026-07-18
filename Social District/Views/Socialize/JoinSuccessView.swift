import SwiftUI

struct JoinSuccessView: View {
    let receipt: JoinReceipt
    let onViewBookings: () -> Void
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Circle()
                .fill(DistrictTheme.Palette.accentSoft)
                .frame(width: 96, height: 96)
                .overlay {
                    Image(systemName: "checkmark")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundStyle(DistrictTheme.Palette.accent)
                }

            VStack(spacing: 8) {
                Text("You’re in!")
                    .font(.system(size: 32, weight: .heavy))
                    .foregroundStyle(DistrictTheme.Palette.textPrimary)

                Text("\(receipt.groupSize) people are now going to \(receipt.title).")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(DistrictTheme.Palette.textSecondary)
                    .multilineTextAlignment(.center)
            }

            HStack(spacing: 0) {
                successMetric(
                    title: "Final price",
                    value: receipt.finalPrice.formatted(
                        .currency(code: "INR").precision(.fractionLength(0))
                    )
                )

                Divider()
                    .frame(height: 44)
                    .overlay(DistrictTheme.Palette.border)

                successMetric(
                    title: "You saved",
                    value: receipt.amountSaved.formatted(
                        .currency(code: "INR").precision(.fractionLength(0))
                    )
                )

                Divider()
                    .frame(height: 44)
                    .overlay(DistrictTheme.Palette.border)

                successMetric(
                    title: "Discount",
                    value: "\(receipt.discountPercent)%"
                )
            }
            .padding(.vertical, 18)
            .background(
                DistrictTheme.Palette.surface,
                in: RoundedRectangle(cornerRadius: 20, style: .continuous)
            )

            Spacer()

            Button(action: onViewBookings) {
                Text("View my bookings")
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

            Button(action: onDone) {
                Text("Done")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(DistrictTheme.Palette.textSecondary)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .background(DistrictTheme.Palette.background.ignoresSafeArea())
    }

    private func successMetric(title: String, value: String) -> some View {
        VStack(spacing: 5) {
            Text(value)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(DistrictTheme.Palette.textPrimary)
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(DistrictTheme.Palette.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    JoinSuccessView(
        receipt: JoinReceipt(
            roomID: UUID(),
            title: "Dune: Part Three",
            venueName: "PVR Saket",
            groupSize: 4,
            finalPrice: 364,
            discountPercent: 30,
            amountSaved: 156
        ),
        onViewBookings: {},
        onDone: {}
    )
}
