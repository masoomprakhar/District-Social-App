import SwiftUI

/// Hosts the redesigned HomeView plus the custom bottom navigation.
/// A hidden system TabView keeps each tab in its own NavigationStack while
/// BottomNavigationView renders the visible bar.
struct RootTabView: View {
    @State private var selection: AppTab = .home
    @State private var socializePath = NavigationPath()
    @State private var bookingsPath = NavigationPath()
    @StateObject private var socializeStore = SocializeStore()

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selection) {
                // HOME
                NavigationStack {
                    HomeView(
                        onOpenSocialize: { selection = .socialize },
                        onSelectCategory: { category in
                            selection = .socialize
                            socializePath.append(AppRoute.socializeCategory(category))
                        }
                    )
                    #if os(iOS)
                    .toolbar(.hidden, for: .navigationBar)
                    #endif
                }
                .tag(AppTab.home)

                // SEARCH
                NavigationStack { PlaceholderScreen(title: "Search") }
                    .tag(AppTab.search)

                // SOCIALIZE — existing flow (discovery → plan detail)
                NavigationStack(path: $socializePath) {
                    SocializeHomeView(path: $socializePath)
                        .navigationDestination(for: AppRoute.self) { route in
                            switch route {
                            case .socialize:
                                SocializeHomeView(path: $socializePath)
                            case .planDetail(let id):
                                if let plan = MockDataService.shared.plan(withId: id) {
                                    PlanDetailView(plan: plan)
                                } else {
                                    Text("Plan not found")
                                        .foregroundStyle(AppTheme.secondaryText)
                                }
                            case .roomDetail(let id):
                                RoomDetailView(path: $socializePath, roomID: id)
                            case .myRooms:
                                MyRoomsView(
                                    onOpenRoom: { id in
                                        socializePath.append(AppRoute.roomDetail(id))
                                    },
                                    onOpenExperience: { id in
                                        socializePath.append(AppRoute.groupExperience(id))
                                    }
                                )
                            case .socializeCategory(let category):
                                SocializeCategoryView(
                                    path: $socializePath,
                                    category: category
                                )
                            case .socializeListing(let id):
                                SocializeListingDetailView(
                                    path: $socializePath,
                                    listingID: id
                                )
                            case .matchListing(let id):
                                MatchMakingView(
                                    path: $socializePath,
                                    listingID: id
                                )
                            case .matchChat(let id):
                                MatchChatView(listingID: id)
                            case .movieSeats(let listingID, let roomID):
                                MovieSeatSelectionView(
                                    path: $socializePath,
                                    listingID: listingID,
                                    roomID: roomID
                                )
                            case .groupExperience(let listingID):
                                GroupExperienceBookingView(
                                    path: $socializePath,
                                    listingID: listingID
                                )
                            }
                        }
                }
                .tag(AppTab.socialize)

                // BOOKINGS
                NavigationStack(path: $bookingsPath) {
                    MyRoomsView(
                        onOpenRoom: { id in
                            bookingsPath.append(AppRoute.roomDetail(id))
                        },
                        onOpenExperience: { id in
                            bookingsPath.append(AppRoute.groupExperience(id))
                        }
                    )
                    .navigationDestination(for: AppRoute.self) { route in
                        switch route {
                        case .roomDetail(let id):
                            RoomDetailView(path: $bookingsPath, roomID: id)
                        case .myRooms:
                            MyRoomsView(
                                onOpenRoom: { id in
                                    bookingsPath.append(AppRoute.roomDetail(id))
                                },
                                onOpenExperience: { id in
                                    bookingsPath.append(AppRoute.groupExperience(id))
                                }
                            )
                        case .socialize:
                            SocializeHomeView(path: $bookingsPath)
                        case .planDetail(let id):
                            if let plan = MockDataService.shared.plan(withId: id) {
                                PlanDetailView(plan: plan)
                            }
                        case .socializeCategory(let category):
                            SocializeCategoryView(
                                path: $bookingsPath,
                                category: category
                            )
                        case .socializeListing(let id):
                            SocializeListingDetailView(
                                path: $bookingsPath,
                                listingID: id
                            )
                        case .matchListing(let id):
                            MatchMakingView(
                                path: $bookingsPath,
                                listingID: id
                            )
                        case .matchChat(let id):
                            MatchChatView(listingID: id)
                        case .movieSeats(let listingID, let roomID):
                            MovieSeatSelectionView(
                                path: $bookingsPath,
                                listingID: listingID,
                                roomID: roomID
                            )
                        case .groupExperience(let listingID):
                            GroupExperienceBookingView(
                                path: $bookingsPath,
                                listingID: listingID
                            )
                        }
                    }
                }
                    .tag(AppTab.bookings)

                // PROFILE
                NavigationStack { PlaceholderScreen(title: "Profile") }
                    .tag(AppTab.profile)
            }
            #if os(iOS)
            .toolbar(.hidden, for: .tabBar)
            #endif

            BottomNavigationView(selection: $selection)
        }
        .environmentObject(socializeStore)
    }
}

// MARK: - Placeholders for tabs that don't have real screens yet

private struct PlaceholderScreen: View {
    let title: String

    var body: some View {
        ZStack {
            DistrictTheme.Palette.background.ignoresSafeArea()
            Text(title)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(DistrictTheme.Palette.textPrimary)
        }
        #if os(iOS)
        .toolbar(.hidden, for: .navigationBar)
        #endif
    }
}

#Preview {
    RootTabView()
}
