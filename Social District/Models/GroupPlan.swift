import Foundation
import SwiftUI

struct GroupPlan: Identifiable, Hashable {
    let id: UUID
    let title: String
    let category: PlanCategory
    let location: String
    let cityArea: String
    let dateLabel: String
    let timeLabel: String
    let joinedCount: Int
    let maxGroupSize: Int
    let interestTags: [String]
    let description: String
    let host: UserProfile
    let participants: [UserProfile]
    let isPublicVenue: Bool
    let headerSymbolName: String
    let headerGradientColors: [Color]

    var spotsRemaining: Int {
        max(0, maxGroupSize - joinedCount)
    }

    var joinedLabel: String {
        "\(joinedCount) of \(maxGroupSize) joined"
    }

    init(
        id: UUID = UUID(),
        title: String,
        category: PlanCategory,
        location: String,
        cityArea: String,
        dateLabel: String,
        timeLabel: String,
        joinedCount: Int,
        maxGroupSize: Int,
        interestTags: [String],
        description: String,
        host: UserProfile,
        participants: [UserProfile],
        isPublicVenue: Bool = true,
        headerSymbolName: String,
        headerGradientColors: [Color]
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.location = location
        self.cityArea = cityArea
        self.dateLabel = dateLabel
        self.timeLabel = timeLabel
        self.joinedCount = joinedCount
        self.maxGroupSize = maxGroupSize
        self.interestTags = interestTags
        self.description = description
        self.host = host
        self.participants = participants
        self.isPublicVenue = isPublicVenue
        self.headerSymbolName = headerSymbolName
        self.headerGradientColors = headerGradientColors
    }
}
