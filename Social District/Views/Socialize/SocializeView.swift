import SwiftUI

/// Compatibility entry point retained for the existing app navigation.
struct SocializeView: View {
    @Binding var path: NavigationPath

    var body: some View {
        SocializeHomeView(path: $path)
    }
}

struct SocializeHomeView: View {
    @EnvironmentObject private var store: SocializeStore
    @Binding var path: NavigationPath
    @State private var selectedFilter: SocializeFilter = .all
    @State private var showingCreateRoom = false

    private var filteredRooms: [SocializeRoom] {
        store.rooms.filter(selectedFilter.includes)
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 26) {
                    VStack(alignment: .leading, spacing: 7) {
                        Text("Socialize")
                            .font(.system(size: 32, weight: .heavy))
                            .foregroundStyle(DistrictTheme.Palette.textPrimary)

                        Text("Go out together. Meet someone new. Save on the plan.")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(DistrictTheme.Palette.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    SocializeModeToggleView(isOn: $store.socializeModeEnabled)

                    if store.socializeModeEnabled {
                        HStack(spacing: 11) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(DistrictTheme.Palette.accent)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Together price is active")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(DistrictTheme.Palette.textPrimary)
                                Text("Choose a plan to find a compatible person and save 20%.")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(DistrictTheme.Palette.textSecondary)
                            }
                        }
                        .padding(14)
                        .background(
                            DistrictTheme.Palette.accentSoft,
                            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                        )
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        Text("What do you want to do?")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(DistrictTheme.Palette.textPrimary)

                        CategoryGridView(items: HomeSampleData.categories) { item in
                            guard let category = SocializeCategory.allCases.first(
                                where: { $0.title == item.title }
                            ) else {
                                return
                            }
                            path.append(AppRoute.socializeCategory(category))
                        }
                    }

                    // Discounted group rooms only appear when Socialize Mode is on.
                    if store.socializeModeEnabled {
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text("Open group rooms")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundStyle(DistrictTheme.Palette.textPrimary)
                                    Text("Join an existing group and unlock up to 30% off")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundStyle(DistrictTheme.Palette.textSecondary)
                                }

                                Spacer()

                                Button {
                                    showingCreateRoom = true
                                } label: {
                                    Image(systemName: "plus")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundStyle(.white)
                                        .frame(width: 36, height: 36)
                                        .background(DistrictTheme.Palette.accent, in: Circle())
                                }
                                .buttonStyle(PressableButtonStyle())
                            }

                            filterPicker

                            LazyVStack(spacing: 14) {
                                ForEach(filteredRooms) { room in
                                    Button {
                                        path.append(AppRoute.roomDetail(room.id))
                                    } label: {
                                        RoomCardView(room: room)
                                    }
                                    .buttonStyle(PressableButtonStyle())
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, DistrictTheme.Space.screenH)
                .padding(.top, 10)
                .padding(.bottom, 116)
            }
        }
        .background(DistrictTheme.Palette.background.ignoresSafeArea())
        .sheet(isPresented: $showingCreateRoom) {
            CreateRoomView { room in
                showingCreateRoom = false
                DispatchQueue.main.async {
                    path.append(AppRoute.roomDetail(room.id))
                }
            }
            .environmentObject(store)
        }
        #if os(iOS)
        .toolbar(.hidden, for: .navigationBar)
        #endif
    }

    private var filterPicker: some View {
        HStack(spacing: 6) {
            ForEach(SocializeFilter.allCases) { filter in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedFilter = filter
                    }
                } label: {
                    Text(filter.rawValue)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(
                            selectedFilter == filter
                                ? Color.white
                                : DistrictTheme.Palette.textSecondary
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            selectedFilter == filter
                                ? DistrictTheme.Palette.accent
                                : Color.clear,
                            in: Capsule()
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(5)
        .background(DistrictTheme.Palette.surface, in: Capsule())
        .overlay(Capsule().stroke(DistrictTheme.Palette.border, lineWidth: 1))
    }
}

#Preview {
    @Previewable @State var path = NavigationPath()
    SocializeHomeView(path: $path)
        .environmentObject(SocializeStore())
}
