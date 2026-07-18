import SwiftUI

struct GroupRequestSentView: View {
    let title: String
    let hostName: String
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: 22) {
            Spacer()

            Circle()
                .fill(DistrictTheme.Palette.accentSoft)
                .frame(width: 92, height: 92)
                .overlay {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(DistrictTheme.Palette.accent)
                }

            VStack(spacing: 8) {
                Text("Request sent")
                    .font(.system(size: 30, weight: .heavy))
                    .foregroundStyle(DistrictTheme.Palette.textPrimary)

                Text("Your request to join \(hostName)’s group for \(title) is pending.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(DistrictTheme.Palette.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Label(
                "You’ll be notified when the host responds. You won’t be charged until you’re accepted.",
                systemImage: "bell.badge"
            )
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(DistrictTheme.Palette.textSecondary)
            .padding(16)
            .background(
                DistrictTheme.Palette.surface,
                in: RoundedRectangle(cornerRadius: 18)
            )

            Spacer()

            Button("Done", action: onDone)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    DistrictTheme.Palette.accent,
                    in: RoundedRectangle(cornerRadius: 17)
                )
        }
        .padding(20)
        .background(DistrictTheme.Palette.background.ignoresSafeArea())
        .preferredColorScheme(.dark)
    }
}

