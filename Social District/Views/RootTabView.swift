import SwiftUI

/// Hosts the redesigned HomeView plus the custom bottom navigation.
/// A hidden system TabView keeps each tab in its own NavigationStack while
/// BottomNavigationView renders the visible bar.
struct RootTabView: View {
    @State private var selection: AppTab = .home
    @State private var homePath = NavigationPath()
    @State private var searchPath = NavigationPath()
    @State private var searchCategory: SocializeCategory?
    @State private var socializePath = NavigationPath()
    @State private var bookingsPath = NavigationPath()
    @StateObject private var socializeStore = SocializeStore()

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selection) {
                // HOME — browse plans; Socialize Mode toggle lives here.
                NavigationStack(path: $homePath) {
                    HomeView(
                        onOpenSocialize: { selection = .socialize },
                        onOpenSearch: { category in
                            searchCategory = category
                            selection = .search
                        },
                        onOpenProfile: { selection = .profile },
                        onOpenCategory: { category in
                            homePath.append(AppRoute.socializeCategory(category))
                        },
                        onOpenListing: { id in
                            homePath.append(AppRoute.socializeListing(id))
                        }
                    )
                    #if os(iOS)
                    .toolbar(.hidden, for: .navigationBar)
                    #endif
                    .navigationDestination(for: AppRoute.self) { route in
                        destination(for: route, path: $homePath)
                    }
                }
                .tag(AppTab.home)

                // SEARCH
                NavigationStack(path: $searchPath) {
                    SearchView(
                        selectedCategory: $searchCategory,
                        onOpenListing: { id in
                            searchPath.append(AppRoute.socializeListing(id))
                        },
                        onOpenMap: {
                            searchPath.append(AppRoute.venueMap)
                        }
                    )
                    .navigationDestination(for: AppRoute.self) { route in
                        destination(for: route, path: $searchPath)
                    }
                }
                .tag(AppTab.search)

                // SOCIALIZE — hub for matches and group rooms.
                NavigationStack(path: $socializePath) {
                    SocializeHomeView(path: $socializePath)
                        .navigationDestination(for: AppRoute.self) { route in
                            destination(for: route, path: $socializePath)
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
                            openExperience(id, path: $bookingsPath)
                        }
                    )
                    .navigationDestination(for: AppRoute.self) { route in
                        destination(for: route, path: $bookingsPath)
                    }
                }
                .tag(AppTab.bookings)

                // PROFILE
                NavigationStack {
                    ProfileView(
                        onOpenBookings: { selection = .bookings },
                        onOpenSocialize: { selection = .socialize }
                    )
                }
                .tag(AppTab.profile)
            }
            #if os(iOS)
            .toolbar(.hidden, for: .tabBar)
            #endif

            BottomNavigationView(selection: $selection)
        }
        .environmentObject(socializeStore)
        .environment(\.openBookings) {
            homePath = NavigationPath()
            socializePath = NavigationPath()
            bookingsPath = NavigationPath()
            selection = .bookings
        }
        .environment(\.openSocialize) {
            selection = .socialize
        }
        .environment(\.openHome) {
            homePath = NavigationPath()
            selection = .home
        }
    }

    /// Shared route table used by every tab's NavigationStack.
    @ViewBuilder
    private func destination(
        for route: AppRoute,
        path: Binding<NavigationPath>
    ) -> some View {
        switch route {
        case .socialize:
            SocializeHomeView(path: path)
        case .planDetail(let id):
            if let plan = MockDataService.shared.plan(withId: id) {
                PlanDetailView(plan: plan)
            } else {
                Text("Plan not found")
                    .foregroundStyle(AppTheme.secondaryText)
            }
        case .roomDetail(let id):
            RoomDetailView(path: path, roomID: id)
        case .myRooms:
            MyRoomsView(
                onOpenRoom: { id in
                    path.wrappedValue.append(AppRoute.roomDetail(id))
                },
                onOpenExperience: { id in
                    openExperience(id, path: path)
                }
            )
        case .socializeCategory(let category):
            SocializeCategoryView(path: path, category: category)
        case .socializeListing(let id):
            SocializeListingDetailView(path: path, listingID: id)
        case .matchListing(let id):
            MatchMakingView(path: path, listingID: id)
        case .matchChat(let id):
            MatchChatView(path: path, listingID: id)
        case .movieSeats(let listingID, let roomID):
            MovieSeatSelectionView(
                path: path,
                listingID: listingID,
                roomID: roomID
            )
        case .groupExperience(let listingID):
            GroupExperienceBookingView(path: path, listingID: listingID)
        case .reviewGroupRequest(let target):
            GroupRequestReviewView(path: path, target: target)
        case .groupChat(let target):
            GroupChatView(target: target)
        case .venueMap:
            VenueMapView { id in
                path.wrappedValue.append(AppRoute.socializeListing(id))
            }
        case .hostDashboard:
            HostDashboardView(path: path)
        }
    }

    private func openExperience(_ id: UUID, path: Binding<NavigationPath>) {
        if
            socializeStore.joinedExperienceIDs.contains(id),
            !socializeStore.matchedBookingIDs.contains(id)
        {
            path.wrappedValue.append(
                AppRoute.groupChat(.experience(id))
            )
            return
        }

        path.wrappedValue.append(
            socializeStore.matchedBookingIDs.contains(id)
                || socializeStore.standardBookingIDs.contains(id)
                ? AppRoute.socializeListing(id)
                : AppRoute.groupExperience(id)
        )
    }
}

#Preview {
    RootTabView()
}
