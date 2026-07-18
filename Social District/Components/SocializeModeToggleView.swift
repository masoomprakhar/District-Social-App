import SwiftUI

struct SocializeModeToggleView: View {
    @Binding var isOn: Bool
    var compact = false

    private var titleColor: Color {
        isOn ? DistrictTheme.Palette.textPrimary : Color(red: 0.12, green: 0.12, blue: 0.14)
    }

    private var subtitleColor: Color {
        isOn
            ? DistrictTheme.Palette.textSecondary
            : Color(red: 0.32, green: 0.32, blue: 0.36)
    }

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
                        .foregroundStyle(titleColor)
                    Text(
                        isOn
                            ? "Make new friends and enjoy going out together"
                            : "Turn on Socialize to enjoy up to 20% off"
                    )
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(subtitleColor)
                }
            } else {
                Text(isOn ? "Offers on" : "Socialize")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(titleColor)
            }

            Spacer(minLength: 6)

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(DistrictTheme.Palette.accent)
        }
        .padding(compact ? 10 : 14)
        .glassEffect(
            isOn
                ? .regular.tint(DistrictTheme.Palette.accent.opacity(0.2)).interactive()
                : .regular.interactive(),
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
    VStack(spacing: 16) {
        SocializeModeToggleView(isOn: .constant(false))
        SocializeModeToggleView(isOn: .constant(true))
    }
    .padding()
    .background(DistrictTheme.Palette.background)
}
