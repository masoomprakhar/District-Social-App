import Foundation

enum GroupRequestTarget: Hashable {
    case room(UUID)
    case experience(UUID)
}

enum GroupRequestStatus: Hashable {
    case pending
    case accepted
    case declined
}

struct HostJoinRequest: Identifiable, Hashable {
    let id: UUID
    let roomID: UUID
    let member: RoomMember
    let note: String
    var status: GroupRequestStatus

    init(
        id: UUID = UUID(),
        roomID: UUID,
        member: RoomMember,
        note: String,
        status: GroupRequestStatus = .pending
    ) {
        self.id = id
        self.roomID = roomID
        self.member = member
        self.note = note
        self.status = status
    }
}

enum SocializeActivityType: String, Codable, CaseIterable, Identifiable, Hashable {
    case movie
    case dining
    case event
    case activity

    var id: String { rawValue }

    var title: String {
        switch self {
        case .movie: "Movies"
        case .dining: "Dining"
        case .event: "Events"
        case .activity: "Activities"
        }
    }

    var singularTitle: String {
        switch self {
        case .movie: "Movie"
        case .dining: "Dining"
        case .event: "Event"
        case .activity: "Activity"
        }
    }

    var symbolName: String {
        switch self {
        case .movie: "movieclapper.fill"
        case .dining: "fork.knife"
        case .event: "ticket.fill"
        case .activity: "figure.run"
        }
    }
}

struct RoomMember: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let avatarSystemImage: String

    init(
        id: UUID = UUID(),
        name: String,
        avatarSystemImage: String = "person.crop.circle.fill"
    ) {
        self.id = id
        self.name = name
        self.avatarSystemImage = avatarSystemImage
    }
}

struct DiscountTier: Identifiable, Codable, Hashable {
    var id: Int { minMembers }
    let minMembers: Int
    let discountPercent: Int
}

struct SocializeRoom: Identifiable, Codable, Hashable {
    let id: UUID
    var activityType: SocializeActivityType
    var title: String
    var venueName: String
    var venueArea: String
    var dateTime: Date
    var hostName: String
    var hostAvatarSystemImage: String
    var capacity: Int
    var joinedCount: Int
    var members: [RoomMember]
    var basePrice: Double
    var discountTiers: [DiscountTier]

    init(
        id: UUID = UUID(),
        activityType: SocializeActivityType,
        title: String,
        venueName: String,
        venueArea: String,
        dateTime: Date,
        hostName: String,
        hostAvatarSystemImage: String = "person.crop.circle.fill",
        capacity: Int,
        joinedCount: Int,
        members: [RoomMember],
        basePrice: Double,
        discountTiers: [DiscountTier]
    ) {
        self.id = id
        self.activityType = activityType
        self.title = title
        self.venueName = venueName
        self.venueArea = venueArea
        self.dateTime = dateTime
        self.hostName = hostName
        self.hostAvatarSystemImage = hostAvatarSystemImage
        self.capacity = capacity
        self.joinedCount = joinedCount
        self.members = members
        self.basePrice = basePrice
        self.discountTiers = discountTiers.sorted { $0.minMembers < $1.minMembers }
    }

    var currentDiscountPercent: Int {
        discountPercent(for: joinedCount)
    }

    var currentPrice: Double {
        price(for: joinedCount)
    }

    var spotsLeft: Int {
        max(0, capacity - joinedCount)
    }

    var nextDiscountTier: DiscountTier? {
        discountTiers.first { $0.minMembers > joinedCount }
    }

    var nextTierMembersNeeded: Int? {
        nextDiscountTier.map { max(0, $0.minMembers - joinedCount) }
    }

    var maximumDiscountPercent: Int {
        min(30, discountTiers.map(\.discountPercent).max() ?? 0)
    }

    var isFull: Bool {
        joinedCount >= capacity
    }

    func discountPercent(for memberCount: Int) -> Int {
        min(
            30,
            discountTiers
                .filter { memberCount >= $0.minMembers }
                .map(\.discountPercent)
                .max() ?? 0
        )
    }

    func price(for memberCount: Int) -> Double {
        let discount = Double(discountPercent(for: memberCount)) / 100
        return basePrice * (1 - discount)
    }

    func savings(for memberCount: Int) -> Double {
        basePrice - price(for: memberCount)
    }
}

struct JoinReceipt: Identifiable, Hashable {
    let id = UUID()
    let roomID: UUID
    let title: String
    let venueName: String
    let groupSize: Int
    let finalPrice: Double
    let discountPercent: Int
    let amountSaved: Double
}

enum SocializeFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case movies = "Movies"
    case dining = "Dining"

    var id: String { rawValue }

    func includes(_ room: SocializeRoom) -> Bool {
        switch self {
        case .all: true
        case .movies: room.activityType == .movie
        case .dining: room.activityType == .dining
        }
    }
}
