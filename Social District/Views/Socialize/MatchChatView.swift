import SwiftUI

struct MatchChatView: View {
    @EnvironmentObject private var store: SocializeStore
    let listingID: UUID

    @State private var messageText = ""

    private var session: DirectMatchSession? {
        store.session(for: listingID)
    }

    private var listing: SocializeListing? {
        store.listing(id: listingID)
    }

    var body: some View {
        Group {
            if
                let session,
                let listing,
                session.state == .accepted
            {
                VStack(spacing: 0) {
                    matchHeader(session.profile, listing: listing)
                    messages(session.messages, profile: session.profile)
                    suggestions
                    composer
                        .padding(.bottom, 70)
                }
                .background(DistrictTheme.Palette.background.ignoresSafeArea())
            } else {
                ZStack {
                    DistrictTheme.Palette.background.ignoresSafeArea()
                    Text("Chat becomes available after a mutual match.")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(DistrictTheme.Palette.textSecondary)
                }
            }
        }
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(DistrictTheme.Palette.background, for: .navigationBar)
        #endif
    }

    private func matchHeader(
        _ profile: MatchProfile,
        listing: SocializeListing
    ) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(DistrictTheme.Palette.accentSoft)
                .frame(width: 44, height: 44)
                .overlay {
                    Image(systemName: profile.avatarSystemImage)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(DistrictTheme.Palette.accent)
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(profile.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(DistrictTheme.Palette.textPrimary)
                Text("\(listing.title) · 20% together discount")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(DistrictTheme.Palette.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            Image(systemName: "shield.checkered")
                .foregroundStyle(DistrictTheme.Palette.accent)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(DistrictTheme.Palette.surface)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(DistrictTheme.Palette.border)
                .frame(height: 1)
        }
    }

    private func messages(
        _ messages: [ChatMessage],
        profile: MatchProfile
    ) -> some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 12) {
                    ForEach(messages) { message in
                        messageBubble(message, profile: profile)
                            .id(message.id)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .onChange(of: messages.count) {
                if let lastID = messages.last?.id {
                    withAnimation {
                        proxy.scrollTo(lastID, anchor: .bottom)
                    }
                }
            }
        }
        .frame(maxHeight: .infinity)
    }

    private func messageBubble(
        _ message: ChatMessage,
        profile: MatchProfile
    ) -> some View {
        Group {
            if message.sender == .system {
                Text(message.text)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(DistrictTheme.Palette.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 9)
                    .background(DistrictTheme.Palette.surface, in: Capsule())
            } else {
                HStack(alignment: .bottom, spacing: 8) {
                    if message.sender == .currentUser {
                        Spacer(minLength: 48)
                    } else {
                        Circle()
                            .fill(DistrictTheme.Palette.accentSoft)
                            .frame(width: 26, height: 26)
                            .overlay {
                                Image(systemName: profile.avatarSystemImage)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(DistrictTheme.Palette.accent)
                            }
                    }

                    Text(message.text)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(DistrictTheme.Palette.textPrimary)
                        .padding(.horizontal, 13)
                        .padding(.vertical, 10)
                        .background(
                            message.sender == .currentUser
                                ? DistrictTheme.Palette.accent
                                : DistrictTheme.Palette.surface,
                            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                        )

                    if message.sender != .currentUser {
                        Spacer(minLength: 48)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var suggestions: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                suggestion("Friday, 8 PM?")
                suggestion("Saturday afternoon?")
                suggestion("Meet at the entrance?")
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 9)
    }

    private func suggestion(_ text: String) -> some View {
        Button {
            store.sendMessage(text, for: listingID)
        } label: {
            Text(text)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(DistrictTheme.Palette.accent)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(DistrictTheme.Palette.accentSoft, in: Capsule())
        }
        .buttonStyle(.plain)
    }

    private var composer: some View {
        HStack(spacing: 10) {
            TextField(
                "",
                text: $messageText,
                prompt: Text("Plan when to go…")
                    .foregroundStyle(DistrictTheme.Palette.textTertiary)
            )
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(DistrictTheme.Palette.textPrimary)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                DistrictTheme.Palette.surfaceRaised,
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
            .onSubmit(sendMessage)

            Button(action: sendMessage) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .background(DistrictTheme.Palette.accent, in: Circle())
            }
            .buttonStyle(PressableButtonStyle())
            .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal, 14)
        .padding(.top, 10)
        .background(DistrictTheme.Palette.surface)
    }

    private func sendMessage() {
        store.sendMessage(messageText, for: listingID)
        messageText = ""
    }
}

#Preview {
    let store = SocializeStore()
    let listing = store.listings[0]
    store.beginMatch(for: listing.id)
    store.sendMatchRequest(for: listing.id)
    store.acceptMatchRequest(for: listing.id)
    return MatchChatView(listingID: listing.id)
        .environmentObject(store)
}
