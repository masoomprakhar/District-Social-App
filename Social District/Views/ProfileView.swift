import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var store: SocializeStore
    var onOpenBookings: () -> Void
    var onOpenSocialize: () -> Void

    @AppStorage("profileName") private var profileName = "Prakhar"
    @AppStorage("profileBio") private var profileBio = "Movies, good food, and meeting new people."
    @AppStorage("bookingNotifications") private var bookingNotifications = true
    @AppStorage("matchNotifications") private var matchNotifications = true
    @AppStorage("publicSocialProfile") private var publicSocialProfile = true

    @State private var showingEditProfile = false
    @State private var showingHelp = false
    @State private var showingPrivacy = false

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                header
                stats
                actions
                preferences
                support
            }
            .padding(.horizontal, DistrictTheme.Space.screenH)
            .padding(.top, 10)
            .padding(.bottom, 110)
        }
        .background(DistrictTheme.Palette.background.ignoresSafeArea())
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView(name: $profileName, bio: $profileBio)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .alert("Help & support", isPresented: $showingHelp) {
            Button("Done", role: .cancel) {}
        } message: {
            Text("For this MVP, support is available at support@socialdistrict.app.")
        }
        .alert("Privacy", isPresented: $showingPrivacy) {
            Button("Done", role: .cancel) {}
        } message: {
            Text("All prototype data stays locally on this device. No personal data is uploaded.")
        }
        #if os(iOS)
        .toolbar(.hidden, for: .navigationBar)
        #endif
    }

    private var header: some View {
        VStack(spacing: 13) {
            Circle()
                .fill(DistrictTheme.Palette.accentSoft)
                .frame(width: 94, height: 94)
                .overlay {
                    Image(systemName: "person.fill")
                        .font(.system(size: 40, weight: .semibold))
                        .foregroundStyle(DistrictTheme.Palette.accent)
                }

            VStack(spacing: 4) {
                Text(profileName)
                    .font(.system(size: 25, weight: .heavy))
                    .foregroundStyle(DistrictTheme.Palette.textPrimary)
                Text(profileBio)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(DistrictTheme.Palette.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }

            Button("Edit profile") {
                showingEditProfile = true
            }
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(DistrictTheme.Palette.textPrimary)
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background(DistrictTheme.Palette.surfaceRaised, in: Capsule())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }

    private var stats: some View {
        HStack(spacing: 0) {
            stat(value: store.totalBookingCount, label: "Bookings")
            divider
            stat(value: store.matchSessions.count, label: "Matches")
            divider
            stat(value: store.joinedRoomIDs.count, label: "Group rooms")
        }
        .padding(.vertical, 17)
        .background(
            DistrictTheme.Palette.surface,
            in: RoundedRectangle(cornerRadius: 20)
        )
    }

    private func stat(value: Int, label: String) -> some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.system(size: 20, weight: .heavy))
                .foregroundStyle(DistrictTheme.Palette.textPrimary)
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(DistrictTheme.Palette.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var divider: some View {
        Rectangle()
            .fill(DistrictTheme.Palette.border)
            .frame(width: 1, height: 32)
    }

    private var actions: some View {
        VStack(spacing: 0) {
            profileRow(
                title: "My bookings",
                subtitle: "Tickets and upcoming plans",
                symbol: "ticket.fill",
                action: onOpenBookings
            )
            rowDivider
            profileRow(
                title: "Discover Socialize",
                subtitle: "Find people for your next plan",
                symbol: "person.2.fill",
                tint: DistrictTheme.Palette.accent,
                action: onOpenSocialize
            )
        }
        .background(
            DistrictTheme.Palette.surface,
            in: RoundedRectangle(cornerRadius: 20)
        )
    }

    private var preferences: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionTitle("Preferences")
            profileToggle(
                title: "Booking updates",
                symbol: "ticket",
                isOn: $bookingNotifications
            )
            rowDivider
            profileToggle(
                title: "Match notifications",
                symbol: "bubble.left.and.bubble.right",
                isOn: $matchNotifications
            )
            rowDivider
            profileToggle(
                title: "Public Socialize profile",
                symbol: "person.crop.circle.badge.checkmark",
                isOn: $publicSocialProfile
            )
        }
        .background(
            DistrictTheme.Palette.surface,
            in: RoundedRectangle(cornerRadius: 20)
        )
    }

    private var support: some View {
        VStack(spacing: 0) {
            profileRow(
                title: "Privacy",
                subtitle: "How your local data is used",
                symbol: "hand.raised.fill"
            ) {
                showingPrivacy = true
            }
            rowDivider
            profileRow(
                title: "Help & support",
                subtitle: "Get assistance",
                symbol: "questionmark.circle.fill"
            ) {
                showingHelp = true
            }
        }
        .background(
            DistrictTheme.Palette.surface,
            in: RoundedRectangle(cornerRadius: 20)
        )
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(DistrictTheme.Palette.textSecondary)
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 6)
    }

    private func profileRow(
        title: String,
        subtitle: String,
        symbol: String,
        tint: Color = DistrictTheme.Palette.textPrimary,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 13) {
                Image(systemName: symbol)
                    .foregroundStyle(tint)
                    .frame(width: 24)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(DistrictTheme.Palette.textPrimary)
                    Text(subtitle)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(DistrictTheme.Palette.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(DistrictTheme.Palette.textTertiary)
            }
            .padding(16)
        }
        .buttonStyle(.plain)
    }

    private func profileToggle(
        title: String,
        symbol: String,
        isOn: Binding<Bool>
    ) -> some View {
        Toggle(isOn: isOn) {
            Label(title, systemImage: symbol)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(DistrictTheme.Palette.textPrimary)
        }
        .tint(DistrictTheme.Palette.accent)
        .padding(16)
    }

    private var rowDivider: some View {
        Rectangle()
            .fill(DistrictTheme.Palette.border)
            .frame(height: 1)
            .padding(.leading, 52)
    }
}

private struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var name: String
    @Binding var bio: String

    var body: some View {
        NavigationStack {
            Form {
                Section("Profile") {
                    TextField("Name", text: $name)
                    TextField("Bio", text: $bio, axis: .vertical)
                        .lineLimit(2...4)
                }
            }
            .scrollContentBackground(.hidden)
            .background(DistrictTheme.Palette.background)
            .navigationTitle("Edit profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ProfileView(onOpenBookings: {}, onOpenSocialize: {})
        .environmentObject(SocializeStore())
}
