import SwiftUI

struct GroupChatView: View {
    @EnvironmentObject private var store: SocializeStore
    let target: GroupRequestTarget

    @State private var messageText = ""

    private var context: GroupChatContext? {
        store.groupContext(for: target)
    }

    private var messages: [ChatMessage] {
        store.messages(for: target)
    }

    var body: some View {
        Group {
            if
                let context,
                store.requestStatus(for: target) == .accepted
            {
                VStack(spacing: 0) {
                    header(context)
                    meetupCard(context)
                    messageList(context)
                    suggestions
                    composer
                        .padding(.bottom, 70)
                }
                .background(DistrictTheme.Palette.background.ignoresSafeArea())
                .onAppear {
                    store.prepareGroupChat(for: target)
                }
            } else {
                unavailableState
            }
        }
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(DistrictTheme.Palette.background, for: .navigationBar)
        #endif
    }

    private func header(_ context: GroupChatContext) -> some View {
        HStack(spacing: 12) {
            AvatarStackView(members: context.members, maxVisible: 3)

            VStack(alignment: .leading, spacing: 2) {
                Text(context.title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(DistrictTheme.Palette.textPrimary)
                    .lineLimit(1)
                Text("\(context.members.count) members · Public venue")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(DistrictTheme.Palette.textSecondary)
            }

            Spacer()

            Menu {
                Button("Share meetup details", systemImage: "square.and.arrow.up") {}
                Button("Leave group", systemImage: "rectangle.portrait.and.arrow.right") {}
                Button(
                    "Report a safety concern",
                    systemImage: "exclamationmark.shield",
                    role: .destructive
                ) {}
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(DistrictTheme.Palette.textPrimary)
                    .frame(width: 38, height: 38)
                    .background(DistrictTheme.Palette.surfaceRaised, in: Circle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 11)
        .background(DistrictTheme.Palette.surface)
    }

    private func meetupCard(_ context: GroupChatContext) -> some View {
        HStack(spacing: 11) {
            Image(systemName: "mappin.and.ellipse")
                .foregroundStyle(DistrictTheme.Palette.accent)

            VStack(alignment: .leading, spacing: 2) {
                Text("Meet at \(context.venueName)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(DistrictTheme.Palette.textPrimary)
                Text("Coordinate arrival details in this chat.")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(DistrictTheme.Palette.textSecondary)
            }

            Spacer()

            Image(systemName: "shield.checkered")
                .foregroundStyle(DistrictTheme.Palette.accent)
        }
        .padding(12)
        .background(DistrictTheme.Palette.accentSoft)
    }

    private func messageList(_ context: GroupChatContext) -> some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 12) {
                    ForEach(messages) { message in
                        messageBubble(message, hostName: context.hostName)
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
        hostName: String
    ) -> some View {
        Group {
            if message.sender == .system {
                Text(message.text)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(DistrictTheme.Palette.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 9)
                    .background(DistrictTheme.Palette.surface, in: Capsule())
            } else {
                HStack(alignment: .bottom, spacing: 8) {
                    if message.sender == .currentUser {
                        Spacer(minLength: 48)
                    } else {
                        Circle()
                            .fill(DistrictTheme.Palette.accentSoft)
                            .frame(width: 27, height: 27)
                            .overlay {
                                Text(String(hostName.prefix(1)))
                                    .font(.system(size: 11, weight: .heavy))
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
                            in: RoundedRectangle(cornerRadius: 16)
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
                suggestion("I’ll be there 10 min early")
                suggestion("Where should we meet?")
                suggestion("Excited to join!")
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 9)
    }

    private func suggestion(_ text: String) -> some View {
        Button(text) {
            store.sendGroupMessage(text, for: target)
        }
        .font(.system(size: 11, weight: .semibold))
        .foregroundStyle(DistrictTheme.Palette.textPrimary)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(DistrictTheme.Palette.surfaceRaised, in: Capsule())
        .buttonStyle(.plain)
    }

    private var composer: some View {
        HStack(spacing: 10) {
            TextField("Message the group", text: $messageText)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(DistrictTheme.Palette.textPrimary)
                .padding(.horizontal, 14)
                .frame(height: 43)
                .background(
                    DistrictTheme.Palette.surfaceRaised,
                    in: RoundedRectangle(cornerRadius: 16)
                )
                .onSubmit(sendMessage)

            Button(action: sendMessage) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .background(DistrictTheme.Palette.accent, in: Circle())
            }
            .buttonStyle(.plain)
            .disabled(
                messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            )
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(DistrictTheme.Palette.surface)
    }

    private func sendMessage() {
        store.sendGroupMessage(messageText, for: target)
        messageText = ""
    }

    private var unavailableState: some View {
        ZStack {
            DistrictTheme.Palette.background.ignoresSafeArea()
            Text("Group chat unlocks after the host accepts your request.")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(DistrictTheme.Palette.textSecondary)
                .multilineTextAlignment(.center)
                .padding(30)
        }
    }
}

