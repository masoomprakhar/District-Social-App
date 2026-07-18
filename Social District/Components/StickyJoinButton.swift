import SwiftUI

struct StickyJoinButton: View {
    let state: JoinRequestState
    let action: () -> Void
    var onSimulateApproval: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 10) {
            if state == .requested {
                Button {
                    onSimulateApproval?()
                } label: {
                    Text("Demo: Simulate host approval")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(AppTheme.socializePurple)
                }
                .buttonStyle(.plain)
            }

            Button(action: action) {
                HStack(spacing: 8) {
                    Image(systemName: iconName)
                        .font(.system(size: 15, weight: .semibold))
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundStyle(foregroundColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(state != .none)
            .animation(.easeInOut(duration: 0.25), value: state)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(
            Color.white
                .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: -4)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private var title: String {
        switch state {
        case .none: return "Request to Join"
        case .requested: return "Request Sent"
        case .approved: return "You're In"
        }
    }

    private var iconName: String {
        switch state {
        case .none: return "person.badge.plus"
        case .requested: return "paperplane.fill"
        case .approved: return "checkmark.circle.fill"
        }
    }

    private var backgroundColor: Color {
        switch state {
        case .none: return AppTheme.socializePurple
        case .requested: return AppTheme.socializePurpleSoft
        case .approved: return AppTheme.success
        }
    }

    private var foregroundColor: Color {
        switch state {
        case .none: return .white
        case .requested: return AppTheme.socializePurple
        case .approved: return .white
        }
    }
}
