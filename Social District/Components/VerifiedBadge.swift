import SwiftUI

struct VerifiedBadge: View {
    var compact: Bool = false

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: compact ? 11 : 13, weight: .semibold))
            if !compact {
                Text("Verified Host")
                    .font(.system(size: 12, weight: .semibold))
            }
        }
        .foregroundStyle(AppTheme.socializePurple)
        .padding(.horizontal, compact ? 0 : 8)
        .padding(.vertical, compact ? 0 : 4)
        .background {
            if !compact {
                Capsule()
                    .fill(AppTheme.socializePurpleSoft)
            }
        }
    }
}
