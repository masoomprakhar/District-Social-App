import Foundation
import SwiftUI

enum SocializeCategory: String, Codable, CaseIterable, Identifiable, Hashable {
    case dining
    case movies
    case events
    case stores
    case activities
    case play

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dining: "Dining"
        case .movies: "Movies"
        case .events: "Events"
        case .stores: "Stores"
        case .activities: "Activities"
        case .play: "Play"
        }
    }

    var symbolName: String {
        switch self {
        case .dining: "fork.knife"
        case .movies: "movieclapper.fill"
        case .events: "music.mic"
        case .stores: "bag.fill"
        case .activities: "figure.hiking"
        case .play: "sportscourt.fill"
        }
    }

    var subtitle: String {
        switch self {
        case .dining: "Restaurants & shared tables"
        case .movies: "Cinema experiences"
        case .events: "Shows, comedy & music"
        case .stores: "Shopping experiences"
        case .activities: "Outdoors & workshops"
        case .play: "Sports & game nights"
        }
    }

    var tint: Color {
        switch self {
        case .dining: DistrictTheme.CategoryTint.dining
        case .movies: DistrictTheme.CategoryTint.movies
        case .events: DistrictTheme.CategoryTint.events
        case .stores: DistrictTheme.CategoryTint.stores
        case .activities: DistrictTheme.CategoryTint.activities
        case .play: DistrictTheme.CategoryTint.play
        }
    }
}

struct SocializeListing: Identifiable, Codable, Hashable {
    let id: UUID
    let category: SocializeCategory
    let title: String
    let venueName: String
    let venueArea: String
    let detail: String
    let pricePerPerson: Double
    let rating: Double
    let systemImage: String

    init(
        id: UUID = UUID(),
        category: SocializeCategory,
        title: String,
        venueName: String,
        venueArea: String,
        detail: String,
        pricePerPerson: Double,
        rating: Double,
        systemImage: String
    ) {
        self.id = id
        self.category = category
        self.title = title
        self.venueName = venueName
        self.venueArea = venueArea
        self.detail = detail
        self.pricePerPerson = pricePerPerson
        self.rating = rating
        self.systemImage = systemImage
    }

    var socializePrice: Double {
        pricePerPerson * 0.8
    }

    var socializeSavings: Double {
        pricePerPerson - socializePrice
    }
}

struct MatchProfile: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let age: Int
    let avatarSystemImage: String
    let matchScore: Int
    let interests: [String]
    let matchReason: String
    let ecosystemSignals: [String]

    init(
        id: UUID = UUID(),
        name: String,
        age: Int,
        avatarSystemImage: String = "person.crop.circle.fill",
        matchScore: Int,
        interests: [String],
        matchReason: String,
        ecosystemSignals: [String]
    ) {
        self.id = id
        self.name = name
        self.age = age
        self.avatarSystemImage = avatarSystemImage
        self.matchScore = matchScore
        self.interests = interests
        self.matchReason = matchReason
        self.ecosystemSignals = ecosystemSignals
    }
}

enum MatchRequestState: String, Codable, Hashable {
    case searching
    case requestSent
    case accepted
}

enum ChatSender: String, Codable, Hashable {
    case currentUser
    case match
    case system
}

struct ChatMessage: Identifiable, Codable, Hashable {
    let id: UUID
    let sender: ChatSender
    let text: String
    let sentAt: Date

    init(
        id: UUID = UUID(),
        sender: ChatSender,
        text: String,
        sentAt: Date = Date()
    ) {
        self.id = id
        self.sender = sender
        self.text = text
        self.sentAt = sentAt
    }
}

struct DirectMatchSession: Identifiable, Codable, Hashable {
    let id: UUID
    let listingID: UUID
    let profile: MatchProfile
    var state: MatchRequestState
    var messages: [ChatMessage]

    init(
        id: UUID = UUID(),
        listingID: UUID,
        profile: MatchProfile,
        state: MatchRequestState = .searching,
        messages: [ChatMessage] = []
    ) {
        self.id = id
        self.listingID = listingID
        self.profile = profile
        self.state = state
        self.messages = messages
    }
}

struct ExperienceGroupSuggestion: Identifiable, Codable, Hashable {
    var id: UUID { listingID }
    let listingID: UUID
    let category: SocializeCategory
    let hostName: String
    let members: [RoomMember]
    let capacity: Int
    let cardTitle: String
    let cardSubtitle: String
    let selectionTitle: String
    let bookingOptions: [String]
    let discountPercent: Int

    var joinedCount: Int {
        members.count
    }

    var spotsLeft: Int {
        max(0, capacity - joinedCount)
    }
}
