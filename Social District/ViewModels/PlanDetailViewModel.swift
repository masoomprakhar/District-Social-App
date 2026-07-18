import Foundation
import Observation

@Observable
final class PlanDetailViewModel {
    let plan: GroupPlan
    var joinState: JoinRequestState = .none
    var showApprovalToast: Bool = false

    init(plan: GroupPlan) {
        self.plan = plan
    }

    func requestToJoin() {
        guard joinState == .none else { return }
        joinState = .requested
    }

    func simulateApproval() {
        guard joinState == .requested else { return }
        joinState = .approved
        showApprovalToast = true
    }
}
