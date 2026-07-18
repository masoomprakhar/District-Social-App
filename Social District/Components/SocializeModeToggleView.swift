import SwiftUI

struct SocializeModeToggleView: View {
    @Binding var isOn: Bool
    var compact = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isOn ? "person.2.fill" : "person.2")
                .font(.system(size: compact ? 16 : 19, weight: .semibold))
                .foregroundStyle(isOn ? Color.white : DistrictTheme.Palette.accent)
                .frame(width: compact ? 34 : 42, height: compact ? 34 : 42)
                .background(
                    isOn
                        ? DistrictTheme.Palette.accent
                        : DistrictTheme.Palette.accentSoft,
                    in: RoundedRectangle(cornerRadius: compact ? 10 : 13)
                )

            if !compact {
                VStack(alignment: .leading, spacing: 2) {
                    Text(isOn ? "Best offers applied" : "Socialize Mode")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(DistrictTheme.Palette.textPrimary)
                    Text(
                        isOn
                            ? "Make new friends and enjoy going out together"
                            : "Turn on Socialize to enjoy up to 20% off"
                    )
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(DistrictTheme.Palette.textSecondary)
                }
            } else {
                Text(isOn ? "Offers on" : "Socialize")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(DistrictTheme.Palette.textPrimary)
            }

            Spacer(minLength: 6)

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(DistrictTheme.Palette.accent)
        }
        .padding(compact ? 10 : 14)
        .background(
            DistrictTheme.Palette.surface,
            in: RoundedRectangle(cornerRadius: compact ? 16 : 20, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: compact ? 16 : 20, style: .continuous)
                .stroke(
                    isOn
                        ? DistrictTheme.Palette.accent.opacity(0.4)
                        : DistrictTheme.Palette.border,
                    lineWidth: 1
                )
        }
        .animation(.easeInOut(duration: 0.2), value: isOn)
    }
}

#Preview {
    SocializeModeToggleView(isOn: .constant(true))
        .padding()
        .background(DistrictTheme.Palette.background)
}
