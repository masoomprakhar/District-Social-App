import SwiftUI

struct CreateRoomView: View {
    @EnvironmentObject private var store: SocializeStore
    @Environment(\.dismiss) private var dismiss

    let onCreated: (SocializeRoom) -> Void

    @State private var activityType: SocializeActivityType = .movie
    @State private var title = ""
    @State private var venueName = ""
    @State private var venueArea = "Delhi NCR"
    @State private var dateTime = Date().addingTimeInterval(86_400)
    @State private var capacity = 4
    @State private var basePrice = 500.0

    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !venueName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !venueArea.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && basePrice > 0
    }

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 7) {
                        Text("Create a room")
                            .font(.system(size: 28, weight: .heavy))
                            .foregroundStyle(DistrictTheme.Palette.textPrimary)
                        Text("Choose the plan. We’ll grow the discount as people join.")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(DistrictTheme.Palette.textSecondary)
                    }

                    fieldSection("Activity") {
                        Picker("Activity", selection: $activityType) {
                            ForEach(SocializeActivityType.allCases) { type in
                                Label(type.title, systemImage: type.symbolName)
                                    .tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    fieldSection("Plan details") {
                        VStack(spacing: 12) {
                            darkTextField(
                                activityType == .movie ? "Movie title" : "Dinner theme",
                                text: $title
                            )
                            darkTextField("Venue", text: $venueName)
                            darkTextField("Area", text: $venueArea)
                        }
                    }

                    fieldSection("Date & time") {
                        DatePicker(
                            "When",
                            selection: $dateTime,
                            in: Date()...,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .datePickerStyle(.compact)
                        .foregroundStyle(DistrictTheme.Palette.textPrimary)
                        .tint(DistrictTheme.Palette.accent)
                    }

                    fieldSection("Group and price") {
                        VStack(spacing: 16) {
                            Stepper(value: $capacity, in: 2...8) {
                                HStack {
                                    Text("Capacity")
                                    Spacer()
                                    Text("\(capacity) people")
                                        .foregroundStyle(DistrictTheme.Palette.accent)
                                }
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(DistrictTheme.Palette.textPrimary)
                            }

                            Divider().overlay(DistrictTheme.Palette.border)

                            HStack {
                                Text("Base price")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(DistrictTheme.Palette.textPrimary)
                                Spacer()
                                TextField(
                                    "₹500",
                                    value: $basePrice,
                                    format: .number.precision(.fractionLength(0))
                                )
                                .multilineTextAlignment(.trailing)
                                .frame(width: 100)
                                #if os(iOS)
                                .keyboardType(.decimalPad)
                                #endif
                                .foregroundStyle(DistrictTheme.Palette.textPrimary)
                            }
                        }
                    }

                    discountPreview

                    Button {
                        let room = store.createRoom(
                            activityType: activityType,
                            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                            venueName: venueName.trimmingCharacters(in: .whitespacesAndNewlines),
                            venueArea: venueArea.trimmingCharacters(in: .whitespacesAndNewlines),
                            dateTime: dateTime,
                            capacity: capacity,
                            basePrice: basePrice
                        )
                        onCreated(room)
                        dismiss()
                    } label: {
                        Text("Create room")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                isValid
                                    ? DistrictTheme.Palette.accent
                                    : DistrictTheme.Palette.surfaceRaised,
                                in: RoundedRectangle(cornerRadius: 17, style: .continuous)
                            )
                    }
                    .buttonStyle(PressableButtonStyle())
                    .disabled(!isValid)
                }
                .padding(20)
                .padding(.bottom, 20)
            }
            .background(DistrictTheme.Palette.background.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(DistrictTheme.Palette.textSecondary)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var discountPreview: some View {
        VStack(alignment: .leading, spacing: 13) {
            Text("Automatic discount tiers")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(DistrictTheme.Palette.textPrimary)

            HStack(spacing: 8) {
                ForEach(SocializeStore.discountTiers(for: capacity)) { tier in
                    VStack(spacing: 4) {
                        Text("\(tier.discountPercent)%")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(DistrictTheme.Palette.accent)
                        Text("\(tier.minMembers) people")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(DistrictTheme.Palette.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(DistrictTheme.Palette.accentSoft, in: RoundedRectangle(cornerRadius: 12))
                }
            }

            Text("Discounts increase linearly and are capped at 30%.")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(DistrictTheme.Palette.textSecondary)
        }
        .padding(16)
        .background(
            DistrictTheme.Palette.surface,
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
    }

    private func fieldSection<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(DistrictTheme.Palette.textSecondary)
            content()
        }
        .padding(16)
        .background(
            DistrictTheme.Palette.surface,
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(DistrictTheme.Palette.border, lineWidth: 1)
        }
    }

    private func darkTextField(_ prompt: String, text: Binding<String>) -> some View {
        TextField(
            "",
            text: text,
            prompt: Text(prompt).foregroundStyle(DistrictTheme.Palette.textTertiary)
        )
        .font(.system(size: 15, weight: .medium))
        .foregroundStyle(DistrictTheme.Palette.textPrimary)
        .padding(.horizontal, 14)
        .padding(.vertical, 13)
        .background(
            DistrictTheme.Palette.surfaceRaised,
            in: RoundedRectangle(cornerRadius: 14, style: .continuous)
        )
    }
}

#Preview {
    CreateRoomView { _ in }
        .environmentObject(SocializeStore())
}
