import SwiftUI

struct PlanDetailView: View {
    @State private var viewModel: PlanDetailViewModel

    init(plan: GroupPlan) {
        _viewModel = State(initialValue: PlanDetailViewModel(plan: plan))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    headerVisual
                    content
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 140)
                }
            }

            StickyJoinButton(
                state: viewModel.joinState,
                action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        viewModel.requestToJoin()
                    }
                },
                onSimulateApproval: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        viewModel.simulateApproval()
                    }
                }
            )
        }
        .background(AppTheme.background.ignoresSafeArea())
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(viewModel.plan.category.rawValue)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppTheme.primaryText)
            }
        }
        .overlay(alignment: .top) {
            if viewModel.showApprovalToast {
                approvalToast
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.top, 8)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                            withAnimation {
                                viewModel.showApprovalToast = false
                            }
                        }
                    }
            }
        }
    }

    private var headerVisual: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: viewModel.plan.headerGradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 220)
            .overlay {
                Image(systemName: viewModel.plan.headerSymbolName)
                    .font(.system(size: 72, weight: .light))
                    .foregroundStyle(.white.opacity(0.22))
                    .offset(x: 90, y: -20)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.plan.category.rawValue.uppercased())
                    .font(.system(size: 12, weight: .bold))
                    .tracking(0.8)
                    .foregroundStyle(.white.opacity(0.85))

                Text(viewModel.plan.title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 1)
            }
            .padding(20)
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 22) {
            infoRow
            hostSection
            participantsSection
            tagsSection
            VenueSafetyIndicator(isPublicVenue: viewModel.plan.isPublicVenue)
            descriptionSection
        }
    }

    private var infoRow: some View {
        VStack(spacing: 12) {
            detailInfoLine(icon: "mappin.and.ellipse", title: "Location", value: viewModel.plan.location)
            detailInfoLine(icon: "calendar", title: "When", value: "\(viewModel.plan.dateLabel), \(viewModel.plan.timeLabel)")
            detailInfoLine(icon: "person.2.fill", title: "Group", value: viewModel.plan.joinedLabel)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white)
                .shadow(color: AppTheme.cardShadow, radius: 10, x: 0, y: 3)
        )
    }

    private func detailInfoLine(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AppTheme.socializePurple)
                .frame(width: 32, height: 32)
                .background(AppTheme.socializePurpleSoft)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(AppTheme.tertiaryText)
                Text(value)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppTheme.primaryText)
            }

            Spacer()
        }
    }

    private var hostSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Host")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(AppTheme.primaryText)

            HStack(spacing: 12) {
                ProfileAvatarView(
                    profile: viewModel.plan.host,
                    size: 52,
                    showVerifiedBadge: true
                )

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(viewModel.plan.host.name)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(AppTheme.primaryText)

                        if viewModel.plan.host.isVerified {
                            VerifiedBadge(compact: false)
                        }
                    }

                    Text(viewModel.plan.host.handle)
                        .font(.system(size: 13))
                        .foregroundStyle(AppTheme.secondaryText)

                    if !viewModel.plan.host.bio.isEmpty {
                        Text(viewModel.plan.host.bio)
                            .font(.system(size: 13))
                            .foregroundStyle(AppTheme.tertiaryText)
                            .lineLimit(2)
                    }
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: AppTheme.cardShadow, radius: 8, x: 0, y: 3)
            )
        }
    }

    private var participantsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Participants")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(AppTheme.primaryText)

                Spacer()

                Text("\(viewModel.plan.spotsRemaining) spots left")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(AppTheme.secondaryText)
            }

            VStack(spacing: 0) {
                ForEach(Array(viewModel.plan.participants.enumerated()), id: \.element.id) { index, profile in
                    HStack(spacing: 12) {
                        ProfileAvatarView(profile: profile, size: 40)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(profile.name)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(AppTheme.primaryText)
                            Text(profile.handle)
                                .font(.system(size: 12))
                                .foregroundStyle(AppTheme.secondaryText)
                        }

                        Spacer()

                        if profile.id == viewModel.plan.host.id {
                            Text("Host")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(AppTheme.socializePurple)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(AppTheme.socializePurpleSoft)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.vertical, 10)

                    if index < viewModel.plan.participants.count - 1 {
                        Divider()
                            .foregroundStyle(AppTheme.divider)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: AppTheme.cardShadow, radius: 8, x: 0, y: 3)
            )
        }
    }

    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Interests")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(AppTheme.primaryText)

            FlowLayout(spacing: 8) {
                ForEach(viewModel.plan.interestTags, id: \.self) { tag in
                    InterestTagView(text: tag, isAccent: true)
                }
            }
        }
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("About this plan")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(AppTheme.primaryText)

            Text(viewModel.plan.description)
                .font(.system(size: 15))
                .foregroundStyle(AppTheme.secondaryText)
                .lineSpacing(4)
        }
    }

    private var approvalToast: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.white)
            Text("You're in the group")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(AppTheme.success)
        .clipShape(Capsule())
        .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 4)
    }
}

/// Simple wrapping layout for interest tags.
private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, frame) in result.frames.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY),
                proposal: ProposedViewSize(frame.size)
            )
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, frames: [CGRect]) {
        let maxWidth = proposal.width ?? .infinity
        var frames: [CGRect] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            frames.append(CGRect(origin: CGPoint(x: x, y: y), size: size))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }

        let height = y + rowHeight
        return (CGSize(width: maxWidth, height: height), frames)
    }
}
