import SwiftUI

struct LocationHeaderView: View {
    let locationName: String
    let locationSubtitle: String
    var onTapBookmarks: () -> Void = {}
    var onTapProfile: () -> Void = {}

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: "mappin.and.ellipse")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.districtTextPrimary)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(locationName)
                        .font(.districtLocationPrimary)
                        .foregroundStyle(Color.districtTextPrimary)

                    Image(systemName: "chevron.down")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color.districtTextSecondary)
                }

                Text(locationSubtitle)
                    .font(.districtLocationSecondary)
                    .foregroundStyle(Color.districtTextSecondary)
            }
            .lineLimit(1)

            Spacer(minLength: 12)

            circularButton(symbolName: "bookmark", action: onTapBookmarks)
            circularButton(symbolName: "person.crop.circle.fill", action: onTapProfile)
        }
    }

    private func circularButton(symbolName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Circle()
                .fill(Color.districtSurface)
                .frame(width: 42, height: 42)
                .overlay {
                    Image(systemName: symbolName)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(Color.districtTextSecondary)
                }
                .overlay {
                    Circle()
                        .stroke(Color.districtStroke, lineWidth: 1)
                }
        }
        .buttonStyle(.districtPress)
    }
}

#Preview {
    LocationHeaderView(
        locationName: "Delhi NCR",
        locationSubtitle: "New Delhi, India"
    )
    .padding(DistrictSpacing.pageInset)
    .background(Color.districtBackground)
}
