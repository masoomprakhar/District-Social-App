import SwiftUI

struct CategoryGridView: View {
    let categories: [HomeCategory]

    private let columns = [
        GridItem(.flexible(), spacing: DistrictSpacing.gridItem),
        GridItem(.flexible(), spacing: DistrictSpacing.gridItem),
        GridItem(.flexible(), spacing: DistrictSpacing.gridItem)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: DistrictSpacing.gridItem) {
            ForEach(categories) { category in
                CategoryCardView(category: category)
            }
        }
    }
}

#Preview {
    CategoryGridView(categories: MockDataService.shared.homeCategories)
        .padding(DistrictSpacing.pageInset)
        .background(Color.districtBackground)
}
