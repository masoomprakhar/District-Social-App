import ActivityKit
import Combine
import Foundation

@MainActor
final class LiveActivityManager: ObservableObject {
    @Published private(set) var activeRoomID: UUID?
    @Published private(set) var message: String?

    func start(for room: SocializeRoom) async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            message = "Live Activities are disabled for this device."
            return
        }

        await endAll()

        let attributes = SocialPlanActivityAttributes(
            title: room.title,
            venueName: room.venueName,
            startDate: room.dateTime,
            symbolName: room.activityType.symbolName
        )
        let state = SocialPlanActivityAttributes.ContentState(
            status: "Group confirmed",
            groupSize: room.joinedCount,
            spotsLeft: room.spotsLeft
        )

        do {
            _ = try Activity.request(
                attributes: attributes,
                content: ActivityContent(
                    state: state,
                    staleDate: room.dateTime
                ),
                pushType: nil
            )
            activeRoomID = room.id
            message = "Live Activity started on the Lock Screen."
        } catch {
            message = "Couldn’t start the Live Activity: \(error.localizedDescription)"
        }
    }

    func endAll() async {
        for activity in Activity<SocialPlanActivityAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
        activeRoomID = nil
    }
}
