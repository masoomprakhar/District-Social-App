import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    @Binding var path: NavigationPath

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DistrictSpacing.section) {
                LocationHeaderView(
                    locationName: viewModel.locationName,
                    locationSubtitle: viewModel.locationSubtitle
                )
                .padding(.horizontal, DistrictSpacing.pageInset)

                SearchBarView(text: $viewModel.searchText)
                    .padding(.horizontal, DistrictSpacing.pageInset)

                CategoryGridView(categories: viewModel.categories)
                    .padding(.horizontal, DistrictSpacing.pageInset)

                SocializeBannerView {
                    path.append(AppRoute.socialize)
                }
                .padding(.horizontal, DistrictSpacing.pageInset)

                SpotlightSectionView(items: viewModel.spotlightItems)
            }
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(Color.districtBackground.ignoresSafeArea())
        .safeAreaInset(edge: .bottom, spacing: 0) {
            BottomNavigationView(selectedTab: $viewModel.selectedTab) {
                path.append(AppRoute.socialize)
            }
        }
        #if os(iOS)
        .toolbar(.hidden, for: .navigationBar)
        #endif
    }
}

#Preview {
    @Previewable @State var path = NavigationPath()
    HomeView(path: $path)
}
