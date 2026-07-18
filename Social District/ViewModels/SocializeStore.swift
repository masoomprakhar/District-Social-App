import Combine
import Foundation

@MainActor
final class SocializeStore: ObservableObject {
    @Published private(set) var rooms: [SocializeRoom]
    @Published private(set) var joinedRoomIDs: Set<UUID> = []
    @Published var socializeModeEnabled = false
    @Published private(set) var listings: [SocializeListing]
    @Published private(set) var matchSessions: [UUID: DirectMatchSession] = [:]
    @Published private(set) var standardBookingIDs: Set<UUID> = []
    @Published private(set) var joinedExperienceIDs: Set<UUID> = []

    private let experienceSuggestions: [UUID: ExperienceGroupSuggestion]

    let currentUser = RoomMember(
        name: "You",
        avatarSystemImage: "person.crop.circle.fill"
    )

    init(rooms: [SocializeRoom], listings: [SocializeListing]) {
        self.rooms = rooms
        self.listings = listings
        self.experienceSuggestions = Self.makeExperienceSuggestions(listings: listings)
    }

    convenience init() {
        self.init(rooms: Self.mockRooms, listings: Self.mockListings)
    }

    func listings(for category: SocializeCategory) -> [SocializeListing] {
        listings.filter { $0.category == category }
    }

    func listing(id: UUID) -> SocializeListing? {
        listings.first { $0.id == id }
    }

    func suggestedRoom(for listing: SocializeListing) -> SocializeRoom? {
        let activityType: SocializeActivityType
        switch listing.category {
        case .dining:
            activityType = .dining
        case .movies:
            activityType = .movie
        default:
            return nil
        }

        return rooms.first {
            $0.activityType == activityType
                && $0.venueName.localizedCaseInsensitiveCompare(listing.venueName) == .orderedSame
                && !$0.isFull
        }
    }

    func experienceSuggestion(
        for listing: SocializeListing
    ) -> ExperienceGroupSuggestion? {
        experienceSuggestions[listing.id]
    }

    var joinedExperienceListings: [SocializeListing] {
        listings.filter { joinedExperienceIDs.contains($0.id) }
    }

    func joinExperience(listingID: UUID) -> JoinReceipt? {
        guard
            let listing = listing(id: listingID),
            let suggestion = experienceSuggestions[listingID],
            !joinedExperienceIDs.contains(listingID),
            suggestion.spotsLeft > 0
        else {
            return nil
        }

        joinedExperienceIDs.insert(listingID)
        let discount = Double(suggestion.discountPercent) / 100
        let finalPrice = listing.pricePerPerson * (1 - discount)

        return JoinReceipt(
            roomID: listingID,
            title: listing.title,
            venueName: listing.venueName,
            groupSize: suggestion.joinedCount + 1,
            finalPrice: finalPrice,
            discountPercent: suggestion.discountPercent,
            amountSaved: listing.pricePerPerson - finalPrice
        )
    }

    func session(for listingID: UUID) -> DirectMatchSession? {
        matchSessions[listingID]
    }

    @discardableResult
    func beginMatch(for listingID: UUID) -> DirectMatchSession? {
        guard let listing = listing(id: listingID) else { return nil }
        if let existing = matchSessions[listingID] {
            return existing
        }

        let session = DirectMatchSession(
            listingID: listingID,
            profile: Self.profile(for: listing.category)
        )
        matchSessions[listingID] = session
        return session
    }

    func sendMatchRequest(for listingID: UUID) {
        guard var session = matchSessions[listingID] else { return }
        session.state = .requestSent
        matchSessions[listingID] = session
    }

    func acceptMatchRequest(for listingID: UUID) {
        guard
            var session = matchSessions[listingID],
            let listing = listing(id: listingID)
        else {
            return
        }

        session.state = .accepted
        session.messages = [
            ChatMessage(
                sender: .system,
                text: "You matched for \(listing.title). Your 20% together discount is locked in."
            ),
            ChatMessage(
                sender: .match,
                text: "Hey! I’d love to go together. What day and time works for you?"
            )
        ]
        matchSessions[listingID] = session
    }

    func sendMessage(_ text: String, for listingID: UUID) {
        let cleanText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard
            !cleanText.isEmpty,
            var session = matchSessions[listingID],
            session.state == .accepted
        else {
            return
        }

        session.messages.append(
            ChatMessage(sender: .currentUser, text: cleanText)
        )
        matchSessions[listingID] = session
    }

    func bookNormally(listingID: UUID) {
        standardBookingIDs.insert(listingID)
    }

    func room(id: UUID) -> SocializeRoom? {
        rooms.first { $0.id == id }
    }

    func join(roomID: UUID) -> JoinReceipt? {
        guard
            let index = rooms.firstIndex(where: { $0.id == roomID }),
            !rooms[index].isFull,
            !joinedRoomIDs.contains(roomID)
        else {
            return nil
        }

        rooms[index].members.append(currentUser)
        rooms[index].joinedCount += 1
        joinedRoomIDs.insert(roomID)

        let room = rooms[index]
        return JoinReceipt(
            roomID: room.id,
            title: room.title,
            venueName: room.venueName,
            groupSize: room.joinedCount,
            finalPrice: room.currentPrice,
            discountPercent: room.currentDiscountPercent,
            amountSaved: room.basePrice - room.currentPrice
        )
    }

    @discardableResult
    func createRoom(
        activityType: SocializeActivityType,
        title: String,
        venueName: String,
        venueArea: String,
        dateTime: Date,
        capacity: Int,
        basePrice: Double
    ) -> SocializeRoom {
        let room = SocializeRoom(
            activityType: activityType,
            title: title,
            venueName: venueName,
            venueArea: venueArea,
            dateTime: dateTime,
            hostName: currentUser.name,
            hostAvatarSystemImage: currentUser.avatarSystemImage,
            capacity: capacity,
            joinedCount: 1,
            members: [currentUser],
            basePrice: basePrice,
            discountTiers: Self.discountTiers(for: capacity)
        )

        rooms.insert(room, at: 0)
        joinedRoomIDs.insert(room.id)
        return room
    }

    static func discountTiers(for capacity: Int) -> [DiscountTier] {
        guard capacity >= 2 else { return [] }
        return (2...capacity).map { memberCount in
            DiscountTier(
                minMembers: memberCount,
                discountPercent: min(30, (memberCount - 1) * 10)
            )
        }
    }
}

// MARK: - Local seed data

private extension SocializeStore {
    static func futureDate(days: Int, hour: Int, minute: Int = 0) -> Date {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        let day = calendar.date(byAdding: .day, value: days, to: start) ?? Date()
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: day) ?? day
    }

    static let mockRooms: [SocializeRoom] = {
        let a = RoomMember(name: "Aarav", avatarSystemImage: "person.crop.circle.fill")
        let m = RoomMember(name: "Meera", avatarSystemImage: "person.crop.circle.fill")
        let k = RoomMember(name: "Kabir", avatarSystemImage: "person.crop.circle.fill")
        let r = RoomMember(name: "Riya", avatarSystemImage: "person.crop.circle.fill")
        let i = RoomMember(name: "Ishaan", avatarSystemImage: "person.crop.circle.fill")
        let s = RoomMember(name: "Sara", avatarSystemImage: "person.crop.circle.fill")
        let n = RoomMember(name: "Naina", avatarSystemImage: "person.crop.circle.fill")
        let v = RoomMember(name: "Vihaan", avatarSystemImage: "person.crop.circle.fill")

        return [
            SocializeRoom(
                activityType: .movie,
                title: "Dune: Part Three",
                venueName: "PVR Select Citywalk",
                venueArea: "Saket, Delhi",
                dateTime: futureDate(days: 1, hour: 19, minute: 30),
                hostName: "Aarav",
                capacity: 4,
                joinedCount: 3,
                members: [a, m, k],
                basePrice: 520,
                discountTiers: discountTiers(for: 4)
            ),
            SocializeRoom(
                activityType: .dining,
                title: "Italian dinner & conversations",
                venueName: "Café Delhi Heights",
                venueArea: "Cyber Hub, Gurugram",
                dateTime: futureDate(days: 0, hour: 20),
                hostName: "Riya",
                capacity: 5,
                joinedCount: 2,
                members: [r, i],
                basePrice: 1200,
                discountTiers: discountTiers(for: 5)
            ),
            SocializeRoom(
                activityType: .movie,
                title: "Interstellar IMAX re-release",
                venueName: "INOX Nehru Place",
                venueArea: "Nehru Place, Delhi",
                dateTime: futureDate(days: 3, hour: 18, minute: 45),
                hostName: "Kabir",
                capacity: 4,
                joinedCount: 2,
                members: [k, s],
                basePrice: 480,
                discountTiers: discountTiers(for: 4)
            ),
            SocializeRoom(
                activityType: .dining,
                title: "Sunday sushi table",
                venueName: "Yum Yum Cha",
                venueArea: "Khan Market, Delhi",
                dateTime: futureDate(days: 4, hour: 13),
                hostName: "Naina",
                capacity: 4,
                joinedCount: 3,
                members: [n, r, m],
                basePrice: 1500,
                discountTiers: discountTiers(for: 4)
            ),
            SocializeRoom(
                activityType: .movie,
                title: "Late-night horror crew",
                venueName: "PVR Ambience Mall",
                venueArea: "Vasant Kunj, Delhi",
                dateTime: futureDate(days: 2, hour: 22, minute: 15),
                hostName: "Vihaan",
                capacity: 5,
                joinedCount: 1,
                members: [v],
                basePrice: 420,
                discountTiers: discountTiers(for: 5)
            ),
            SocializeRoom(
                activityType: .dining,
                title: "North Indian dinner club",
                venueName: "Daryaganj",
                venueArea: "Connaught Place, Delhi",
                dateTime: futureDate(days: 2, hour: 20, minute: 30),
                hostName: "Meera",
                capacity: 6,
                joinedCount: 4,
                members: [m, a, s, i],
                basePrice: 1000,
                discountTiers: discountTiers(for: 6)
            ),
            SocializeRoom(
                activityType: .movie,
                title: "Marvel opening night",
                venueName: "Cinepolis DLF Avenue",
                venueArea: "Saket, Delhi",
                dateTime: futureDate(days: 5, hour: 20),
                hostName: "Ishaan",
                capacity: 6,
                joinedCount: 3,
                members: [i, v, a],
                basePrice: 560,
                discountTiers: discountTiers(for: 6)
            ),
            SocializeRoom(
                activityType: .dining,
                title: "New-in-town brunch",
                venueName: "Olive Bar & Kitchen",
                venueArea: "Mehrauli, Delhi",
                dateTime: futureDate(days: 6, hour: 11, minute: 30),
                hostName: "Sara",
                capacity: 5,
                joinedCount: 2,
                members: [s, n],
                basePrice: 1800,
                discountTiers: discountTiers(for: 5)
            )
        ]
    }()

    static let mockListings: [SocializeListing] = [
        SocializeListing(
            category: .dining,
            title: "Italian dinner for two",
            venueName: "Café Delhi Heights",
            venueArea: "Cyber Hub, Gurugram",
            detail: "Pasta, pizza and easy conversations",
            pricePerPerson: 1200,
            rating: 4.6,
            systemImage: "fork.knife"
        ),
        SocializeListing(
            category: .dining,
            title: "Sushi tasting table",
            venueName: "Yum Yum Cha",
            venueArea: "Khan Market, Delhi",
            detail: "Shared plates and a curated tasting menu",
            pricePerPerson: 1500,
            rating: 4.7,
            systemImage: "fish.fill"
        ),
        SocializeListing(
            category: .dining,
            title: "North Indian dinner",
            venueName: "Daryaganj",
            venueArea: "Connaught Place, Delhi",
            detail: "Comfort food and a relaxed table",
            pricePerPerson: 1000,
            rating: 4.5,
            systemImage: "takeoutbag.and.cup.and.straw.fill"
        ),
        SocializeListing(
            category: .movies,
            title: "Dune: Part Three",
            venueName: "PVR Select Citywalk",
            venueArea: "Saket, Delhi",
            detail: "IMAX · English · U/A",
            pricePerPerson: 520,
            rating: 4.8,
            systemImage: "movieclapper.fill"
        ),
        SocializeListing(
            category: .movies,
            title: "Interstellar re-release",
            venueName: "INOX Nehru Place",
            venueArea: "Nehru Place, Delhi",
            detail: "IMAX · English · U/A",
            pricePerPerson: 480,
            rating: 4.9,
            systemImage: "film.fill"
        ),
        SocializeListing(
            category: .events,
            title: "Stand-up comedy night",
            venueName: "The Laugh Store",
            venueArea: "Vegas Mall, Dwarka",
            detail: "90-minute live comedy showcase",
            pricePerPerson: 799,
            rating: 4.5,
            systemImage: "mic.fill"
        ),
        SocializeListing(
            category: .events,
            title: "Indie music weekend",
            venueName: "The Piano Man",
            venueArea: "Eldeco Centre, Delhi",
            detail: "Live indie set · standing entry",
            pricePerPerson: 999,
            rating: 4.7,
            systemImage: "music.note"
        ),
        SocializeListing(
            category: .stores,
            title: "Streetwear shopping walk",
            venueName: "Select Citywalk",
            venueArea: "Saket, Delhi",
            detail: "Explore new drops and shop together",
            pricePerPerson: 300,
            rating: 4.4,
            systemImage: "bag.fill"
        ),
        SocializeListing(
            category: .stores,
            title: "Bookstore & coffee trail",
            venueName: "Bahrisons Booksellers",
            venueArea: "Khan Market, Delhi",
            detail: "Browse books, then grab coffee",
            pricePerPerson: 450,
            rating: 4.8,
            systemImage: "books.vertical.fill"
        ),
        SocializeListing(
            category: .activities,
            title: "Lodhi art district walk",
            venueName: "Lodhi Colony",
            venueArea: "New Delhi",
            detail: "Guided murals and photography walk",
            pricePerPerson: 650,
            rating: 4.7,
            systemImage: "figure.walk"
        ),
        SocializeListing(
            category: .activities,
            title: "Pottery workshop",
            venueName: "The Clay Company",
            venueArea: "Nehru Place, Delhi",
            detail: "Beginner wheel pottery session",
            pricePerPerson: 1400,
            rating: 4.6,
            systemImage: "paintbrush.fill"
        ),
        SocializeListing(
            category: .play,
            title: "Pickleball social",
            venueName: "Hudle Courts",
            venueArea: "Gurugram",
            detail: "Beginner-friendly doubles session",
            pricePerPerson: 600,
            rating: 4.7,
            systemImage: "figure.pickleball"
        ),
        SocializeListing(
            category: .play,
            title: "Board games evening",
            venueName: "The Board Room",
            venueArea: "Hauz Khas, Delhi",
            detail: "Strategy games, snacks and new people",
            pricePerPerson: 500,
            rating: 4.5,
            systemImage: "dice.fill"
        )
    ]

    static func profile(for category: SocializeCategory) -> MatchProfile {
        switch category {
        case .dining:
            MatchProfile(
                name: "Ananya",
                age: 25,
                matchScore: 92,
                interests: ["Italian food", "Cafés", "Travel"],
                matchReason: "You both try new restaurants and prefer relaxed dinner plans.",
                ecosystemSignals: [
                    "Similar Zomato cuisine history",
                    "Both save café collections on District",
                    "Overlapping Blinkit cooking interests"
                ]
            )
        case .movies:
            MatchProfile(
                name: "Kabir",
                age: 27,
                matchScore: 94,
                interests: ["Sci-fi", "IMAX", "Film scores"],
                matchReason: "You both book opening weekends and rate sci-fi highly.",
                ecosystemSignals: [
                    "Matching District movie history",
                    "Both prefer IMAX evening shows",
                    "Shared sci-fi interest"
                ]
            )
        case .events:
            MatchProfile(
                name: "Riya",
                age: 24,
                matchScore: 89,
                interests: ["Comedy", "Live music", "Nightlife"],
                matchReason: "Your saved event lists and preferred timings overlap.",
                ecosystemSignals: [
                    "Similar District event saves",
                    "Both attend weekend shows",
                    "Shared comedy interest"
                ]
            )
        case .stores:
            MatchProfile(
                name: "Sara",
                age: 26,
                matchScore: 86,
                interests: ["Books", "Streetwear", "Coffee"],
                matchReason: "You share shopping categories and neighbourhood favourites.",
                ecosystemSignals: [
                    "Similar shopping collections",
                    "Both visit Khan Market",
                    "Overlapping Blinkit lifestyle orders"
                ]
            )
        case .activities:
            MatchProfile(
                name: "Arjun",
                age: 28,
                matchScore: 91,
                interests: ["Art walks", "Photography", "Outdoors"],
                matchReason: "You both prefer creative, low-pressure weekend activities.",
                ecosystemSignals: [
                    "Matching District activity saves",
                    "Both explore outdoor experiences",
                    "Shared photography interest"
                ]
            )
        case .play:
            MatchProfile(
                name: "Meera",
                age: 25,
                matchScore: 88,
                interests: ["Pickleball", "Board games", "Fitness"],
                matchReason: "Your game preferences and available times are compatible.",
                ecosystemSignals: [
                    "Similar sports bookings",
                    "Both choose beginner sessions",
                    "Matching weekend availability"
                ]
            )
        }
    }

    static func makeExperienceSuggestions(
        listings: [SocializeListing]
    ) -> [UUID: ExperienceGroupSuggestion] {
        let suggestions = listings.compactMap { listing -> ExperienceGroupSuggestion? in
            let members: [RoomMember]
            let capacity: Int
            let cardTitle: String
            let cardSubtitle: String
            let selectionTitle: String
            let options: [String]

            switch listing.category {
            case .events:
                members = [
                    RoomMember(name: "Riya"),
                    RoomMember(name: "Kabir"),
                    RoomMember(name: "Ananya")
                ]
                capacity = 5
                cardTitle = "Attend with Riya’s crew"
                cardSubtitle = "They’re booking the same show and section"
                selectionTitle = "Choose seats with the group"
                options = [
                    "Middle section · Row C",
                    "Balcony · Row B",
                    "Standing zone · Entry together"
                ]
            case .stores:
                members = [
                    RoomMember(name: "Sara"),
                    RoomMember(name: "Naina")
                ]
                capacity = 4
                cardTitle = "Shop with Sara’s group"
                cardSubtitle = "Browse together and unlock the group offer"
                selectionTitle = "Choose a shopping time"
                options = [
                    "Saturday · 4:00 PM",
                    "Sunday · 12:00 PM",
                    "Sunday · 5:00 PM"
                ]
            case .activities:
                members = [
                    RoomMember(name: "Arjun"),
                    RoomMember(name: "Meera"),
                    RoomMember(name: "Ishaan")
                ]
                capacity = 6
                cardTitle = "Join Arjun’s activity crew"
                cardSubtitle = "They have open spots in the same session"
                selectionTitle = "Choose a session with the group"
                options = [
                    "Saturday · 9:00 AM",
                    "Saturday · 4:30 PM",
                    "Sunday · 10:00 AM"
                ]
            case .play:
                members = [
                    RoomMember(name: "Meera"),
                    RoomMember(name: "Vihaan")
                ]
                capacity = 4
                cardTitle = "Fill Meera’s team"
                cardSubtitle = "They need one more player for this game"
                selectionTitle = "Choose their court or game slot"
                options = [
                    "Court 2 · Saturday 6 PM",
                    "Court 1 · Sunday 9 AM",
                    "Game table · Sunday 5 PM"
                ]
            case .dining, .movies:
                return nil
            }

            return ExperienceGroupSuggestion(
                listingID: listing.id,
                category: listing.category,
                hostName: members[0].name,
                members: members,
                capacity: capacity,
                cardTitle: cardTitle,
                cardSubtitle: cardSubtitle,
                selectionTitle: selectionTitle,
                bookingOptions: options,
                discountPercent: 20
            )
        }

        return Dictionary(uniqueKeysWithValues: suggestions.map { ($0.listingID, $0) })
    }
}
