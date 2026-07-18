import SwiftUI

struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    var iconName: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let iconName {
                    Image(systemName: iconName)
                        .font(.system(size: 12, weight: .semibold))
                }
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundStyle(isSelected ? Color.white : AppTheme.primaryText)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(isSelected ? AppTheme.socializePurple : Color.white)
            )
            .overlay {
                Capsule()
                    .stroke(
                        isSelected ? AppTheme.socializePurple : AppTheme.divider,
                        lineWidth: 1
                    )
            }
        }
        .buttonStyle(.plain)
    }
}
