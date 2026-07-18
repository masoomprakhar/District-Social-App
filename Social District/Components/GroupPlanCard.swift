import SwiftUI

struct GroupPlanCard: View {
    let plan: GroupPlan

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text(plan.category.rawValue.uppercased())
                            .font(.system(size: 11, weight: .bold))
                            .tracking(0.6)
                            .foregroundStyle(AppTheme.socializePurple)

                        if plan.host.isVerified {
                            VerifiedBadge(compact: true)
                        }
                    }

                    Text(plan.title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(AppTheme.primaryText)
                        .lineLimit(2)
                }

                Spacer(minLength: 8)

                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: plan.headerGradientColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)

                    Image(systemName: plan.headerSymbolName)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }

            HStack(spacing: 16) {
                Label(plan.location, systemImage: "mappin.and.ellipse")
                Label("\(plan.dateLabel), \(plan.timeLabel)", systemImage: "clock")
            }
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(AppTheme.secondaryText)
            .lineLimit(1)

            HStack(spacing: 12) {
                AvatarStackView(profiles: plan.participants, maxVisible: 4, size: 28)

                Text(plan.joinedLabel)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppTheme.primaryText)

                Spacer(minLength: 0)

                Text("\(plan.spotsRemaining) spots left")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(AppTheme.tertiaryText)
            }

            if !plan.interestTags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(plan.interestTags, id: \.self) { tag in
                            InterestTagView(text: tag)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous)
                .fill(AppTheme.cardBackground)
                .shadow(color: AppTheme.cardShadow, radius: 12, x: 0, y: 4)
        )
    }
}
