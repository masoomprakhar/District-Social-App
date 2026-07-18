import ActivityKit
import Foundation

struct SocialPlanActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var status: String
        var groupSize: Int
        var spotsLeft: Int
    }

    let title: String
    let venueName: String
    let startDate: Date
    let symbolName: String
}
