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
    @Published private(set) var matchedBookingIDs: Set<UUID> = []
    @Published private(set) var requestedRoomIDs: Set<UUID> = []
    @Published private(set) var requestedExperienceIDs: Set<UUID> = []
    @Published private(set) var declinedRoomIDs: Set<UUID> = []
    @Published private(set) var declinedExperienceIDs: Set<UUID> = []
    @Published private(set) var groupMessages: [GroupRequestTarget: [ChatMessage]] = [:]
    @Published private(set) var hostJoinRequests: [HostJoinRequest] = []

    private let experienceSuggestions: [UUID: ExperienceGroupSuggestion]

    let currentUser = RoomMember(
        name: "You",
        avatarSystemImage: "person.crop.circle.fill"
    )

    init(rooms: [SocializeRoom], listings: [SocializeListing]) {
        self.rooms = rooms
        self.listings = listings
        self.experienceSuggestions = Self.makeExperienceSuggestions(listings: listings)
        seedHostedDemo()
        seedDemoBookings()
        seedHostRequests()
    }

    convenience init() {
        self.init(rooms: Self.mockRooms, listings: Self.mockListings)
    }

    /// Unique upcoming bookings across rooms, together experiences, and regular tickets.
    var totalBookingCount: Int {
        joinedRoomIDs.count
            + joinedExperienceIDs.count
            + standardBookingIDs.count
    }

    private func seedDemoBookings() {
        if let dining = listings.first(where: { $0.category == .dining }) {
            standardBookingIDs.insert(dining.id)
        }
        if let movie = listings.first(where: { $0.category == .movies }) {
            joinedExperienceIDs.insert(movie.id)
            matchedBookingIDs.insert(movie.id)
        }
        if let room = rooms.first(where: { !$0.isFull }) {
            joinedRoomIDs.insert(room.id)
            if !room.members.contains(where: { $0.name == currentUser.name }) {
                var updated = room
                updated.joinedCount = min(room.capacity, room.joinedCount + 1)
                updated.members.append(currentUser)
                if let index = rooms.firstIndex(where: { $0.id == room.id }) {
                    rooms[index] = updated
                }
            }
        }
    }

    private func seedHostedDemo() {
        guard !rooms.contains(where: { $0.hostName == currentUser.name }) else {
            return
        }

        let hostedRoom = SocializeRoom(
            activityType: .dining,
            title: "Sunday brunch for newcomers",
            venueName: "Olive Bar & Kitchen",
            venueArea: "Mehrauli, Delhi",
            dateTime: Self.futureDate(days: 5, hour: 11, minute: 30),
            hostName: currentUser.name,
            hostAvatarSystemImage: currentUser.avatarSystemImage,
            capacity: 5,
            joinedCount: 1,
            members: [currentUser],
            basePrice: 1800,
            discountTiers: Self.discountTiers(for: 5)
        )
        rooms.insert(hostedRoom, at: 0)
        joinedRoomIDs.insert(hostedRoom.id)
    }

    private func seedHostRequests() {
        guard
            let room = rooms.first(where: { $0.hostName == currentUser.name }),
            hostJoinRequests.isEmpty
        else {
            return
        }

        hostJoinRequests = [
            HostJoinRequest(
                roomID: room.id,
                member: RoomMember(name: "Naina"),
                note: "New to Delhi and would love to meet people over brunch."
            ),
            HostJoinRequest(
                roomID: room.id,
                member: RoomMember(name: "Kabir"),
                note: "Food explorer. I’ve saved this restaurant for months."
            )
        ]
    }

    var hostedRooms: [SocializeRoom] {
        rooms.filter { $0.hostName == currentUser.name }
    }

    func approveHostRequest(_ requestID: UUID) {
        guard
            let requestIndex = hostJoinRequests.firstIndex(
                where: { $0.id == requestID }
            ),
            hostJoinRequests[requestIndex].status == .pending,
            let roomIndex = rooms.firstIndex(
                where: { $0.id == hostJoinRequests[requestIndex].roomID }
            ),
            !rooms[roomIndex].isFull
        else {
            return
        }

        let member = hostJoinRequests[requestIndex].member
        rooms[roomIndex].members.append(member)
        rooms[roomIndex].joinedCount += 1
        hostJoinRequests[requestIndex].status = .accepted
    }

    func declineHostRequest(_ requestID: UUID) {
        guard
            let index = hostJoinRequests.firstIndex(
                where: { $0.id == requestID }
            ),
            hostJoinRequests[index].status == .pending
        else {
            return
        }
        hostJoinRequests[index].status = .declined
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

    var standardBookingListings: [SocializeListing] {
        listings.filter { standardBookingIDs.contains($0.id) }
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

    func bookMatchedListing(listingID: UUID) -> JoinReceipt? {
        guard
            let listing = listing(id: listingID),
            let session = matchSessions[listingID],
            session.state == .accepted,
            !joinedExperienceIDs.contains(listingID)
        else {
            return nil
        }

        joinedExperienceIDs.insert(listingID)
        matchedBookingIDs.insert(listingID)
        return JoinReceipt(
            roomID: listingID,
            title: listing.title,
            venueName: listing.venueName,
            groupSize: 2,
            finalPrice: listing.socializePrice,
            discountPercent: 20,
            amountSaved: listing.socializeSavings
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

    @discardableResult
    func requestToJoin(roomID: UUID) -> Bool {
        guard
            let room = room(id: roomID),
            !room.isFull,
            !joinedRoomIDs.contains(roomID),
            !requestedRoomIDs.contains(roomID)
        else {
            return false
        }

        requestedRoomIDs.insert(roomID)
        return true
    }

    @discardableResult
    func requestToJoinExperience(listingID: UUID) -> Bool {
        guard
            experienceSuggestions[listingID] != nil,
            !joinedExperienceIDs.contains(listingID),
            !requestedExperienceIDs.contains(listingID)
        else {
            return false
        }

        requestedExperienceIDs.insert(listingID)
        return true
    }

    func requestStatus(for target: GroupRequestTarget) -> GroupRequestStatus? {
        switch target {
        case .room(let id):
            if joinedRoomIDs.contains(id) { return .accepted }
            if requestedRoomIDs.contains(id) { return .pending }
            if declinedRoomIDs.contains(id) { return .declined }
        case .experience(let id):
            if joinedExperienceIDs.contains(id) { return .accepted }
            if requestedExperienceIDs.contains(id) { return .pending }
            if declinedExperienceIDs.contains(id) { return .declined }
        }
        return nil
    }

    @discardableResult
    func approveRequest(for target: GroupRequestTarget) -> Bool {
        let approved: Bool

        switch target {
        case .room(let id):
            guard requestedRoomIDs.contains(id) else { return false }
            approved = join(roomID: id) != nil
            if approved {
                requestedRoomIDs.remove(id)
                declinedRoomIDs.remove(id)
            }
        case .experience(let id):
            guard requestedExperienceIDs.contains(id) else { return false }
            approved = joinExperience(listingID: id) != nil
            if approved {
                requestedExperienceIDs.remove(id)
                declinedExperienceIDs.remove(id)
            }
        }

        if approved {
            seedGroupChat(for: target)
        }
        return approved
    }

    func declineRequest(for target: GroupRequestTarget) {
        switch target {
        case .room(let id):
            guard requestedRoomIDs.remove(id) != nil else { return }
            declinedRoomIDs.insert(id)
        case .experience(let id):
            guard requestedExperienceIDs.remove(id) != nil else { return }
            declinedExperienceIDs.insert(id)
        }
    }

    func groupContext(for target: GroupRequestTarget) -> GroupChatContext? {
        switch target {
        case .room(let id):
            guard let room = room(id: id) else { return nil }
            return GroupChatContext(
                title: room.title,
                venueName: room.venueName,
                hostName: room.hostName,
                members: room.members
            )
        case .experience(let id):
            guard
                let listing = listing(id: id),
                let suggestion = experienceSuggestions[id]
            else {
                return nil
            }
            var members = suggestion.members
            if !members.contains(where: { $0.name == currentUser.name }) {
                members.append(currentUser)
            }
            return GroupChatContext(
                title: listing.title,
                venueName: listing.venueName,
                hostName: suggestion.hostName,
                members: members
            )
        }
    }

    func messages(for target: GroupRequestTarget) -> [ChatMessage] {
        groupMessages[target] ?? []
    }

    func prepareGroupChat(for target: GroupRequestTarget) {
        guard requestStatus(for: target) == .accepted else { return }
        seedGroupChat(for: target)
    }

    func sendGroupMessage(_ text: String, for target: GroupRequestTarget) {
        let cleanText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard
            !cleanText.isEmpty,
            requestStatus(for: target) == .accepted
        else {
            return
        }

        var messages = groupMessages[target] ?? []
        messages.append(
            ChatMessage(sender: .currentUser, text: cleanText)
        )
        groupMessages[target] = messages
    }

    private func seedGroupChat(for target: GroupRequestTarget) {
        guard
            groupMessages[target] == nil,
            let context = groupContext(for: target)
        else {
            return
        }

        groupMessages[target] = [
            ChatMessage(
                sender: .system,
                text: "Your request was accepted. Keep coordination in this group and meet at the public venue."
            ),
            ChatMessage(
                sender: .match,
                text: "Welcome! I’m \(context.hostName). Excited to have you join us for \(context.title)."
            )
        ]
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
                title: "Avatar: Fire and Ash",
                venueName: "PVR Ambience Mall",
                venueArea: "Vasant Kunj, Delhi",
                dateTime: futureDate(days: 2, hour: 21, minute: 15),
                hostName: "Vihaan",
                capacity: 5,
                joinedCount: 2,
                members: [v, n],
                basePrice: 650,
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
        // Dining
        SocializeListing(
            category: .dining,
            title: "Italian Dinner Table",
            venueName: "Café Delhi Heights",
            venueArea: "Cyber Hub, Gurugram",
            detail: "Italian · Casual dining · Dinner",
            pricePerPerson: 1200,
            rating: 4.6,
            systemImage: "fork.knife"
        ),
        SocializeListing(
            category: .dining,
            title: "Sushi & Dim Sum Night",
            venueName: "Yum Yum Cha",
            venueArea: "Khan Market, Delhi",
            detail: "Pan-Asian · Shared plates",
            pricePerPerson: 1500,
            rating: 4.7,
            systemImage: "fish.fill"
        ),
        SocializeListing(
            category: .dining,
            title: "Heritage North Indian Dinner",
            venueName: "Daryaganj",
            venueArea: "Connaught Place, Delhi",
            detail: "North Indian · Heritage recipes",
            pricePerPerson: 1000,
            rating: 4.5,
            systemImage: "takeoutbag.and.cup.and.straw.fill"
        ),

        // Movies
        SocializeListing(
            category: .movies,
            title: "Dune: Part Three",
            venueName: "PVR Select Citywalk",
            venueArea: "Saket, Delhi",
            detail: "IMAX 2D · English · 2h 46m",
            pricePerPerson: 520,
            rating: 4.8,
            systemImage: "movieclapper.fill"
        ),
        SocializeListing(
            category: .movies,
            title: "Interstellar",
            venueName: "INOX Nehru Place",
            venueArea: "Nehru Place, Delhi",
            detail: "IMAX 70mm · English · 2h 49m",
            pricePerPerson: 480,
            rating: 4.9,
            systemImage: "film.fill"
        ),
        SocializeListing(
            category: .movies,
            title: "Avatar: Fire and Ash",
            venueName: "PVR Ambience Mall",
            venueArea: "Vasant Kunj, Delhi",
            detail: "3D · English · 3h 05m",
            pricePerPerson: 650,
            rating: 4.7,
            systemImage: "sparkles.tv.fill"
        ),

        // Events
        SocializeListing(
            category: .events,
            title: "Friday Night Stand-up",
            venueName: "The Laugh Store",
            venueArea: "DLF CyberHub, Gurugram",
            detail: "Live comedy · 18+ · 90 min",
            pricePerPerson: 799,
            rating: 4.5,
            systemImage: "mic.fill"
        ),
        SocializeListing(
            category: .events,
            title: "Indie Nights: Live Sessions",
            venueName: "The Piano Man",
            venueArea: "Safdarjung, Delhi",
            detail: "Live music · Jazz & indie",
            pricePerPerson: 999,
            rating: 4.7,
            systemImage: "music.note"
        ),
        SocializeListing(
            category: .events,
            title: "Sufi Evening",
            venueName: "Sunder Nursery",
            venueArea: "Nizamuddin, Delhi",
            detail: "Open-air concert · Sundown show",
            pricePerPerson: 599,
            rating: 4.8,
            systemImage: "music.mic"
        ),

        // Stores
        SocializeListing(
            category: .stores,
            title: "Streetwear Drop Day",
            venueName: "Select Citywalk",
            venueArea: "Saket, Delhi",
            detail: "Guided store walk · New collections",
            pricePerPerson: 300,
            rating: 4.4,
            systemImage: "bag.fill"
        ),
        SocializeListing(
            category: .stores,
            title: "Books & Coffee Trail",
            venueName: "Bahrisons Booksellers",
            venueArea: "Khan Market, Delhi",
            detail: "Bookstore crawl · Ends at a café",
            pricePerPerson: 450,
            rating: 4.8,
            systemImage: "books.vertical.fill"
        ),
        SocializeListing(
            category: .stores,
            title: "Vintage & Thrift Hunt",
            venueName: "Sarojini Nagar Market",
            venueArea: "South Delhi",
            detail: "Curated market walk · 2 hrs",
            pricePerPerson: 250,
            rating: 4.5,
            systemImage: "tshirt.fill"
        ),

        // Activities
        SocializeListing(
            category: .activities,
            title: "Lodhi Art District Walk",
            venueName: "Lodhi Colony",
            venueArea: "New Delhi",
            detail: "Guided murals & photo walk · 90 min",
            pricePerPerson: 650,
            rating: 4.7,
            systemImage: "figure.walk"
        ),
        SocializeListing(
            category: .activities,
            title: "Wheel Pottery Session",
            venueName: "The Clay Company",
            venueArea: "Shahpur Jat, Delhi",
            detail: "Beginner friendly · Materials included",
            pricePerPerson: 1400,
            rating: 4.6,
            systemImage: "paintbrush.fill"
        ),
        SocializeListing(
            category: .activities,
            title: "Sunrise Kayaking",
            venueName: "Damdama Lake",
            venueArea: "Sohna, Gurugram",
            detail: "Guided · Gear provided · 6 AM start",
            pricePerPerson: 900,
            rating: 4.8,
            systemImage: "water.waves"
        ),

        // Play
        SocializeListing(
            category: .play,
            title: "Pickleball Social",
            venueName: "Hudle Courts",
            venueArea: "Sector 43, Gurugram",
            detail: "Doubles · All levels · Coach on court",
            pricePerPerson: 600,
            rating: 4.7,
            systemImage: "figure.pickleball"
        ),
        SocializeListing(
            category: .play,
            title: "Board Game Evening",
            venueName: "The Board Room",
            venueArea: "Hauz Khas, Delhi",
            detail: "Strategy & party games · Snacks",
            pricePerPerson: 500,
            rating: 4.5,
            systemImage: "dice.fill"
        ),
        SocializeListing(
            category: .play,
            title: "Go-Karting Grand Prix",
            venueName: "F9 Go Karting",
            venueArea: "Sector 29, Gurugram",
            detail: "10-lap race · Helmet included",
            pricePerPerson: 750,
            rating: 4.6,
            systemImage: "flag.checkered"
        )
    ]

    static let movieMatchProfiles: [MatchProfile] = [
        MatchProfile(
            name: "Kabir",
            age: 27,
            matchScore: 94,
            interests: ["Sci-fi", "IMAX", "Film scores"],
            matchReason: "You both book opening weekends and rate sci-fi highly.",
            ecosystemSignals: [
                "Booked one ticket for this movie",
                "Matching District movie history",
                "Both prefer IMAX evening shows"
            ]
        ),
        MatchProfile(
            name: "Naina",
            age: 25,
            matchScore: 91,
            interests: ["Cinema", "Thrillers", "Coffee"],
            matchReason: "Your movie taste and preferred show timings strongly overlap.",
            ecosystemSignals: [
                "Booked one ticket for this movie",
                "Both watch weekend evening shows",
                "Similar thriller ratings"
            ]
        ),
        MatchProfile(
            name: "Ishaan",
            age: 26,
            matchScore: 89,
            interests: ["IMAX", "Action", "Film trivia"],
            matchReason: "You both frequently book premium-format action movies.",
            ecosystemSignals: [
                "Booked one ticket for this movie",
                "Similar District booking history",
                "Both choose premium screens"
            ]
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
            movieMatchProfiles.randomElement() ?? movieMatchProfiles[0]
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
