import SwiftUI

struct CategoryCardView: View {
    let category: HomeCategory
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                Spacer(minLength: 0)

                Image(systemName: category.symbolName)
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(category.tint)
                    .shadow(color: category.tint.opacity(0.35), radius: 12, x: 0, y: 5)
                    .frame(maxHeight: .infinity)

                Text(category.name)
                    .font(.districtCardLabel)
                    .foregroundStyle(Color.districtTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .padding(.bottom, 14)
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(1.05, contentMode: .fit)
            .background(
                RoundedRectangle(cornerRadius: DistrictRadius.categoryCard, style: .continuous)
                    .fill(Color.districtSurface)
            )
            .overlay {
                RoundedRectangle(cornerRadius: DistrictRadius.categoryCard, style: .continuous)
                    .stroke(Color.districtStroke, lineWidth: 1)
            }
        }
        .buttonStyle(.districtPress)
    }
}

#Preview {
    CategoryCardView(
        category: HomeCategory(name: "Dining", symbolName: "fork.knife", tint: .districtCoral)
    )
    .frame(width: 120)
    .padding(DistrictSpacing.pageInset)
    .background(Color.districtBackground)
}
