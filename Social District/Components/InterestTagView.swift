import SwiftUI

struct InterestTagView: View {
    let text: String
    var isAccent: Bool = false

    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(isAccent ? AppTheme.socializePurple : AppTheme.secondaryText)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(isAccent ? AppTheme.socializePurpleSoft : AppTheme.background)
            )
    }
}
