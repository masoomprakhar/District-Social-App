import SwiftUI

struct TrustSafetyView: View {
    @AppStorage("womenOnlyGroups") private var womenOnlyGroups = false
    @AppStorage("shareMeetupStatus") private var shareMeetupStatus = true
    @AppStorage("verifiedProfilesOnly") private var verifiedProfilesOnly = false

    @State private var identityVerified = true
    @State private var phoneVerified = true
    @State private var emergencyContactAdded = false
    @State private var showingSafetyAlert = false

    private var safetyScore: Int {
        [identityVerified, phoneVerified, emergencyContactAdded]
            .filter { $0 }
            .count * 33 + (emergencyContactAdded ? 1 : 0)
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                header
                scoreCard
                verificationCard
                meetupPreferences
                emergencyCard
            }
            .padding(.horizontal, DistrictTheme.Space.screenH)
            .padding(.top, 10)
            .padding(.bottom, 40)
        }
        .background(DistrictTheme.Palette.background.ignoresSafeArea())
        .navigationTitle("Trust & safety")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Safety check-in sent", isPresented: $showingSafetyAlert) {
            Button("Done", role: .cancel) {}
        } message: {
            Text("Your mock emergency contact received your venue and meetup status.")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Meet with confidence")
                .font(.system(size: 28, weight: .heavy))
                .foregroundStyle(DistrictTheme.Palette.textPrimary)
            Text("Controls that help every Socialize meetup stay intentional and public.")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(DistrictTheme.Palette.textSecondary)
        }
    }

    private var scoreCard: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(DistrictTheme.Palette.surfaceRaised, lineWidth: 8)
                Circle()
                    .trim(from: 0, to: Double(safetyScore) / 100)
                    .stroke(
                        DistrictTheme.Palette.accent,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                Text("\(safetyScore)%")
                    .font(.system(size: 17, weight: .heavy))
                    .foregroundStyle(DistrictTheme.Palette.textPrimary)
            }
            .frame(width: 76, height: 76)

            VStack(alignment: .leading, spacing: 4) {
                Text("Safety profile")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(DistrictTheme.Palette.textPrimary)
                Text(
                    emergencyContactAdded
                        ? "Your core safety setup is complete."
                        : "Add an emergency contact to complete your setup."
                )
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(DistrictTheme.Palette.textSecondary)
            }
        }
        .padding(18)
        .background(
            DistrictTheme.Palette.surface,
            in: RoundedRectangle(cornerRadius: 22)
        )
    }

    private var verificationCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionTitle("Verification")
            verificationRow(
                title: "Government ID",
                subtitle: "Identity verified",
                symbol: "person.text.rectangle.fill",
                isComplete: identityVerified
            )
            divider
            verificationRow(
                title: "Phone number",
                subtitle: "Mobile verified",
                symbol: "phone.fill",
                isComplete: phoneVerified
            )
        }
        .background(
            DistrictTheme.Palette.surface,
            in: RoundedRectangle(cornerRadius: 20)
        )
    }

    private var meetupPreferences: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionTitle("Meetup preferences")
            safetyToggle(
                "Verified profiles only",
                symbol: "checkmark.seal.fill",
                isOn: $verifiedProfilesOnly
            )
            divider
            safetyToggle(
                "Women-only groups",
                symbol: "person.2.fill",
                isOn: $womenOnlyGroups
            )
            divider
            safetyToggle(
                "Share meetup status",
                symbol: "location.fill",
                isOn: $shareMeetupStatus
            )
        }
        .background(
            DistrictTheme.Palette.surface,
            in: RoundedRectangle(cornerRadius: 20)
        )
    }

    private var emergencyCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Emergency contact", systemImage: "cross.case.fill")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(DistrictTheme.Palette.textPrimary)

            Text(
                emergencyContactAdded
                    ? "Riya · +91 ••••• 4821"
                    : "Add someone who can receive your venue and check-in status."
            )
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(DistrictTheme.Palette.textSecondary)

            HStack(spacing: 10) {
                Button(emergencyContactAdded ? "Contact added" : "Add contact") {
                    withAnimation {
                        emergencyContactAdded = true
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(DistrictTheme.Palette.accent)

                if emergencyContactAdded {
                    Button("Test check-in") {
                        showingSafetyAlert = true
                    }
                    .buttonStyle(.bordered)
                    .tint(DistrictTheme.Palette.textPrimary)
                }
            }
        }
        .padding(18)
        .background(
            DistrictTheme.Palette.surface,
            in: RoundedRectangle(cornerRadius: 20)
        )
    }

    private func verificationRow(
        title: String,
        subtitle: String,
        symbol: String,
        isComplete: Bool
    ) -> some View {
        HStack(spacing: 13) {
            Image(systemName: symbol)
                .foregroundStyle(DistrictTheme.Palette.accent)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(DistrictTheme.Palette.textPrimary)
                Text(subtitle)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(DistrictTheme.Palette.textSecondary)
            }
            Spacer()
            Image(systemName: isComplete ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(
                    isComplete
                        ? DistrictTheme.Palette.accent
                        : DistrictTheme.Palette.textTertiary
                )
        }
        .padding(16)
    }

    private func safetyToggle(
        _ title: String,
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

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(DistrictTheme.Palette.textSecondary)
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 5)
    }

    private var divider: some View {
        Rectangle()
            .fill(DistrictTheme.Palette.border)
            .frame(height: 1)
            .padding(.leading, 52)
    }
}

