import SwiftUI

struct SocializeView: View {
    @State private var viewModel = SocializeViewModel()
    @Binding var path: NavigationPath

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 16)

            SearchBar(
                text: $viewModel.searchText,
                placeholder: "Search plans, places, tags"
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 14)

            filterBar
                .padding(.bottom, 8)

            plansList
        }
        .background(AppTheme.background.ignoresSafeArea())
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppTheme.background, for: .navigationBar)
        #endif
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Socialize")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(AppTheme.primaryText)

            Text("Real plans. Real people.")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(AppTheme.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(viewModel.filters) { filter in
                    CategoryChip(
                        title: filter.rawValue,
                        isSelected: viewModel.selectedFilter == filter,
                        iconName: filter == .forYou ? filter.iconName : nil
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.selectedFilter = filter
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 4)
        }
    }

    private var plansList: some View {
        ScrollView {
            LazyVStack(spacing: 14) {
                if viewModel.filteredPlans.isEmpty {
                    emptyState
                        .padding(.top, 48)
                } else {
                    ForEach(viewModel.filteredPlans) { plan in
                        Button {
                            path.append(AppRoute.planDetail(plan.id))
                        } label: {
                            GroupPlanCard(plan: plan)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.3")
                .font(.system(size: 36, weight: .medium))
                .foregroundStyle(AppTheme.socializePurple.opacity(0.6))

            Text("No plans match")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(AppTheme.primaryText)

            Text("Try another category or clear your search.")
                .font(.system(size: 14))
                .foregroundStyle(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}
