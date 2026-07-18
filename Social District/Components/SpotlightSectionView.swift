import SwiftUI

struct SpotlightSectionView: View {
    let items: [SpotlightItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("In the spotlight")
                .font(.districtSectionTitle)
                .foregroundStyle(Color.districtTextPrimary)
                .padding(.horizontal, DistrictSpacing.pageInset)

            // Edge-to-edge scroll; trailing card peeks past the page inset.
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 14) {
                    ForEach(items) { item in
                        SpotlightCardView(item: item)
                    }
                }
                .padding(.horizontal, DistrictSpacing.pageInset)
            }
        }
    }
}

#Preview {
    SpotlightSectionView(items: MockDataService.shared.spotlightItems)
        .padding(.vertical, DistrictSpacing.pageInset)
        .background(Color.districtBackground)
}
