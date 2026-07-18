import SwiftUI

struct SpotlightCardView: View {
    let item: SpotlightItem
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: DistrictRadius.spotlightCard, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: item.gradientColors,
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                Image(systemName: item.symbolName)
                    .font(.system(size: 120, weight: .light))
                    .foregroundStyle(.white.opacity(0.16))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                Text(item.badge)
                    .font(.districtBadge)
                    .tracking(0.3)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.black.opacity(0.45))
                    .clipShape(Capsule())
                    .padding(14)

                VStack(alignment: .leading, spacing: 5) {
                    Spacer()

                    Text(item.title)
                        .font(.districtSpotlightTitle)
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .minimumScaleFactor(0.7)

                    Text(item.metadata)
                        .font(.districtMetadata)
                        .tracking(0.3)
                        .foregroundStyle(.white.opacity(0.75))
                        .lineLimit(1)
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.55)],
                        startPoint: .center,
                        endPoint: .bottom
                    )
                )
            }
            .frame(width: 280, height: 360)
            .clipShape(RoundedRectangle(cornerRadius: DistrictRadius.spotlightCard, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: DistrictRadius.spotlightCard, style: .continuous)
                    .stroke(Color.districtStroke, lineWidth: 1)
            }
        }
        .buttonStyle(.districtPress)
    }
}

#Preview {
    SpotlightCardView(item: MockDataService.shared.spotlightItems[0])
        .padding(DistrictSpacing.pageInset)
        .background(Color.districtBackground)
}
