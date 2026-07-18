import SwiftUI

struct GroupRequestReviewView: View {
    @EnvironmentObject private var store: SocializeStore
    @Environment(\.openBookings) private var openBookings
    @Binding var path: NavigationPath
    let target: GroupRequestTarget

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            if let context = store.groupContext(for: target) {
                VStack(alignment: .leading, spacing: 22) {
                    header(context)
                    planCard(context)

                    switch store.requestStatus(for: target) {
                    case .pending:
                        pendingReview(context)
                    case .accepted:
                        acceptedState(context)
                    case .declined:
                        declinedState
                    case nil:
                        unavailableState
                    }
                }
                .padding(.horizontal, DistrictTheme.Space.screenH)
                .padding(.top, 12)
                .padding(.bottom, 110)
            }
        }
        .background(DistrictTheme.Palette.background.ignoresSafeArea())
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(DistrictTheme.Palette.background, for: .navigationBar)
        #endif
    }

    private func header(_ context: GroupChatContext) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text("Host review")
                .font(.system(size: 30, weight: .heavy))
                .foregroundStyle(DistrictTheme.Palette.textPrimary)
            Text("Demo how \(context.hostName) responds to your request.")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(DistrictTheme.Palette.textSecondary)
        }
    }

    private func planCard(_ context: GroupChatContext) -> some View {
        HStack(spacing: 13) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(DistrictTheme.Palette.accent)
                .frame(width: 50, height: 50)
                .background(
                    DistrictTheme.Palette.accentSoft,
                    in: RoundedRectangle(cornerRadius: 15)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(context.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(DistrictTheme.Palette.textPrimary)
                Text("\(context.venueName) · Hosted by \(context.hostName)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(DistrictTheme.Palette.textSecondary)
                    .lineLimit(1)
            }

            Spacer()
        }
        .padding(16)
        .background(
            DistrictTheme.Palette.surface,
            in: RoundedRectangle(cornerRadius: 20)
        )
    }

    private func pendingReview(_ context: GroupChatContext) -> some View {
        VStack(spacing: 16) {
            statusIcon(
                symbol: "clock.fill",
                color: DistrictTheme.CategoryTint.events
            )

            Text("Request awaiting approval")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(DistrictTheme.Palette.textPrimary)

            Text(
                "\(context.hostName) can review your public profile and accept or decline. "
                    + "Chat and booking unlock only after acceptance."
            )
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(DistrictTheme.Palette.textSecondary)
            .multilineTextAlignment(.center)

            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                    _ = store.approveRequest(for: target)
                }
            } label: {
                Label(
                    "Demo: \(context.hostName) accepts",
                    systemImage: "checkmark.circle.fill"
                )
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(
                    DistrictTheme.Palette.accent,
                    in: RoundedRectangle(cornerRadius: 16)
                )
            }
            .buttonStyle(PressableButtonStyle())

            Button(role: .destructive) {
                withAnimation(.easeInOut(duration: 0.25)) {
                    store.declineRequest(for: target)
                }
            } label: {
                Text("Demo: Decline request")
                    .font(.system(size: 14, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.bordered)
            .tint(DistrictTheme.Palette.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            DistrictTheme.Palette.surface,
            in: RoundedRectangle(cornerRadius: 22)
        )
    }

    private func acceptedState(_ context: GroupChatContext) -> some View {
        VStack(spacing: 16) {
            statusIcon(symbol: "checkmark", color: DistrictTheme.Palette.accent)

            Text("You’re approved")
                .font(.system(size: 24, weight: .heavy))
                .foregroundStyle(DistrictTheme.Palette.textPrimary)

            Text(
                "Your discounted booking is confirmed and "
                    + "\(context.hostName)’s group chat is now open."
            )
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(DistrictTheme.Palette.textSecondary)
            .multilineTextAlignment(.center)

            Button {
                path.append(AppRoute.groupChat(target))
            } label: {
                Label("Open group chat", systemImage: "message.fill")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(
                        DistrictTheme.Palette.accent,
                        in: RoundedRectangle(cornerRadius: 16)
                    )
            }
            .buttonStyle(PressableButtonStyle())

            Button("View confirmed booking", action: openBookings)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(DistrictTheme.Palette.accent)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            DistrictTheme.Palette.surface,
            in: RoundedRectangle(cornerRadius: 22)
        )
    }

    private var declinedState: some View {
        VStack(spacing: 14) {
            statusIcon(
                symbol: "xmark",
                color: DistrictTheme.Palette.textSecondary
            )
            Text("Request declined")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(DistrictTheme.Palette.textPrimary)
            Text("No booking was made and you were not charged.")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(DistrictTheme.Palette.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(
            DistrictTheme.Palette.surface,
            in: RoundedRectangle(cornerRadius: 22)
        )
    }

    private var unavailableState: some View {
        Text("This request is no longer available.")
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(DistrictTheme.Palette.textSecondary)
    }

    private func statusIcon(symbol: String, color: Color) -> some View {
        Circle()
            .fill(color.opacity(0.16))
            .frame(width: 76, height: 76)
            .overlay {
                Image(systemName: symbol)
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(color)
            }
    }
}

