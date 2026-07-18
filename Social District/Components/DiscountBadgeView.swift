import SwiftUI

struct DiscountBadgeView: View {
    let room: SocializeRoom

    var body: some View {
        Text(label)
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(DistrictTheme.Palette.accent, in: Capsule())
    }

    private var label: String {
        if room.currentDiscountPercent > 0 {
            "\(room.currentDiscountPercent)% off now"
        } else {
            "Up to \(room.maximumDiscountPercent)% off"
        }
    }
}

#Preview {
    DiscountBadgeView(room: SocializeStore().rooms[0])
        .padding()
        .background(DistrictTheme.Palette.background)
}
