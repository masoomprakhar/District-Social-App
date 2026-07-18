import Foundation
import SwiftUI

/// Local mock data source for the Social District frontend prototype.
final class MockDataService {
    static let shared = MockDataService()

    let currentUser: UserProfile
    let profiles: [UserProfile]
    let plans: [GroupPlan]

    private init() {
        let ananya = UserProfile(
            name: "Ananya Mehra",
            handle: "@ananya",
            bio: "Food trails & late-night chai. Host of cozy group dinners.",
            isVerified: true,
            symbolName: "person.fill",
            accentColor: Color(red: 0.90, green: 0.45, blue: 0.55)
        )
        let kabir = UserProfile(
            name: "Kabir Shah",
            handle: "@kabir",
            bio: "IMAX regular. Always down for a sci-fi night.",
            isVerified: true,
            symbolName: "person.fill",
            accentColor: Color(red: 0.35, green: 0.48, blue: 0.90)
        )
        let riya = UserProfile(
            name: "Riya Kapoor",
            handle: "@riya",
            bio: "Comedy clubs & rooftop evenings.",
            isVerified: true,
            symbolName: "person.fill",
            accentColor: Color(red: 0.55, green: 0.38, blue: 0.82)
        )
        let arjun = UserProfile(
            name: "Arjun Desai",
            handle: "@arjun",
            bio: "Weekend hikes and board-game nights.",
            isVerified: false,
            symbolName: "person.fill",
            accentColor: Color(red: 0.20, green: 0.65, blue: 0.55)
        )
        let meera = UserProfile(
            name: "Meera Nair",
            handle: "@meera",
            bio: "Live music, galleries, and good company.",
            isVerified: true,
            symbolName: "person.fill",
            accentColor: Color(red: 0.95, green: 0.55, blue: 0.30)
        )
        let vihaan = UserProfile(
            name: "Vihaan Malhotra",
            handle: "@vihaan",
            bio: "Pickleball, cafés, and spontaneous plans.",
            isVerified: false,
            symbolName: "person.fill",
            accentColor: Color(red: 0.30, green: 0.55, blue: 0.75)
        )
        let sara = UserProfile(
            name: "Sara Ali",
            handle: "@sara",
            bio: "Art walks through Delhi’s quieter streets.",
            isVerified: true,
            symbolName: "person.fill",
            accentColor: Color(red: 0.75, green: 0.40, blue: 0.55)
        )
        let ishaan = UserProfile(
            name: "Ishaan Rao",
            handle: "@ishaan",
            bio: "Coffee first, plans second.",
            isVerified: false,
            symbolName: "person.fill",
            accentColor: Color(red: 0.45, green: 0.60, blue: 0.35)
        )
        let current = UserProfile(
            name: "You",
            handle: "@you",
            bio: "Ready to go out.",
            isVerified: false,
            symbolName: "person.crop.circle.fill",
            accentColor: AppTheme.socializePurple
        )

        self.currentUser = current
        self.profiles = [ananya, kabir, riya, arjun, meera, vihaan, sara, ishaan]

        self.plans = [
            GroupPlan(
                title: "Pizza & Conversations",
                category: .dining,
                location: "Cyber Hub, Gurugram",
                cityArea: "Gurugram",
                dateLabel: "Tonight",
                timeLabel: "8:00 PM",
                joinedCount: 3,
                maxGroupSize: 5,
                interestTags: ["Casual Dining", "Meet New People", "Italian"],
                description: "Laid-back pizza night for people who love good food and easy conversation. We’ll grab a table at a popular Cyber Hub spot, share plates, and keep the vibe friendly and low-pressure. Perfect if you’re new to the city or just want company for dinner.",
                host: ananya,
                participants: [ananya, meera, ishaan],
                headerSymbolName: "fork.knife.circle.fill",
                headerGradientColors: [
                    Color(red: 0.95, green: 0.45, blue: 0.40),
                    Color(red: 0.85, green: 0.30, blue: 0.50)
                ]
            ),
            GroupPlan(
                title: "Interstellar IMAX",
                category: .movies,
                location: "Saket, Delhi",
                cityArea: "Delhi",
                dateLabel: "Saturday",
                timeLabel: "7:30 PM",
                joinedCount: 2,
                maxGroupSize: 4,
                interestTags: ["IMAX", "Sci-Fi", "Weekend Plans"],
                description: "Catching Interstellar on IMAX at Select Citywalk. Looking for fellow film lovers who appreciate Nolan’s sound design and don’t mind staying for the end credits. We’ll meet 20 minutes early at the lobby.",
                host: kabir,
                participants: [kabir, vihaan],
                headerSymbolName: "film.circle.fill",
                headerGradientColors: [
                    Color(red: 0.20, green: 0.25, blue: 0.55),
                    Color(red: 0.35, green: 0.40, blue: 0.85)
                ]
            ),
            GroupPlan(
                title: "Stand-up Comedy Night",
                category: .events,
                location: "Aerocity, Delhi",
                cityArea: "Delhi",
                dateLabel: "Friday",
                timeLabel: "8:30 PM",
                joinedCount: 4,
                maxGroupSize: 6,
                interestTags: ["Comedy", "Nightlife", "Live Shows"],
                description: "Friday night open-mic + headliner set in Aerocity. Tickets are on us for confirmed members. Expect laughs, post-show chai, and a friendly group that doesn’t take itself too seriously.",
                host: riya,
                participants: [riya, ananya, sara, arjun],
                headerSymbolName: "mic.circle.fill",
                headerGradientColors: [
                    Color(red: 0.50, green: 0.28, blue: 0.75),
                    Color(red: 0.70, green: 0.35, blue: 0.65)
                ]
            ),
            GroupPlan(
                title: "Lodhi Garden Morning Walk",
                category: .activities,
                location: "Lodhi Garden, Delhi",
                cityArea: "Delhi",
                dateLabel: "Sunday",
                timeLabel: "7:00 AM",
                joinedCount: 3,
                maxGroupSize: 8,
                interestTags: ["Outdoors", "Wellness", "Morning"],
                description: "Easy 45-minute walk through Lodhi Garden followed by coffee nearby. All fitness levels welcome — this is about fresh air and meeting people, not a race.",
                host: arjun,
                participants: [arjun, meera, sara],
                headerSymbolName: "leaf.circle.fill",
                headerGradientColors: [
                    Color(red: 0.20, green: 0.60, blue: 0.45),
                    Color(red: 0.35, green: 0.72, blue: 0.55)
                ]
            ),
            GroupPlan(
                title: "Board Games & Brews",
                category: .activities,
                location: "Hauz Khas Village",
                cityArea: "Delhi",
                dateLabel: "Thursday",
                timeLabel: "6:30 PM",
                joinedCount: 2,
                maxGroupSize: 5,
                interestTags: ["Board Games", "Café", "Casual"],
                description: "Catan, Exploding Kittens, and whatever the café has on the shelf. Come for one game or stay for the evening — no experience needed.",
                host: vihaan,
                participants: [vihaan, ishaan],
                headerSymbolName: "dice.fill",
                headerGradientColors: [
                    Color(red: 0.25, green: 0.45, blue: 0.70),
                    Color(red: 0.40, green: 0.55, blue: 0.85)
                ]
            ),
            GroupPlan(
                title: "Indie Music Night",
                category: .events,
                location: "Connaught Place",
                cityArea: "Delhi",
                dateLabel: "Saturday",
                timeLabel: "9:00 PM",
                joinedCount: 5,
                maxGroupSize: 7,
                interestTags: ["Live Music", "Indie", "Nightlife"],
                description: "A local indie set at a CP venue with great acoustics. We’ll grab a corner table, enjoy the music, and hang after for a quick bite.",
                host: meera,
                participants: [meera, riya, kabir, sara, ananya],
                headerSymbolName: "music.note.list",
                headerGradientColors: [
                    Color(red: 0.85, green: 0.40, blue: 0.25),
                    Color(red: 0.95, green: 0.55, blue: 0.35)
                ]
            ),
            GroupPlan(
                title: "Sushi & Sake Tasting",
                category: .dining,
                location: "DLF Phase 4, Gurugram",
                cityArea: "Gurugram",
                dateLabel: "Friday",
                timeLabel: "7:00 PM",
                joinedCount: 2,
                maxGroupSize: 4,
                interestTags: ["Fine Dining", "Japanese", "Small Group"],
                description: "Intimate sushi tasting for four. Sharing plates, light conversation, and a reservation already held under the host’s name. Prefer people comfortable with a quieter dinner vibe.",
                host: sara,
                participants: [sara, ananya],
                headerSymbolName: "fish.fill",
                headerGradientColors: [
                    Color(red: 0.70, green: 0.30, blue: 0.45),
                    Color(red: 0.85, green: 0.45, blue: 0.55)
                ]
            ),
            GroupPlan(
                title: "Weekend Cricket Watch",
                category: .events,
                location: "Sector 29, Gurugram",
                cityArea: "Gurugram",
                dateLabel: "Sunday",
                timeLabel: "3:00 PM",
                joinedCount: 4,
                maxGroupSize: 8,
                interestTags: ["Sports", "Cricket", "Casual"],
                description: "Watching the match at a sports bar with big screens and good snacks. Cheer, chat, and meet fellow fans — no jersey required.",
                host: ishaan,
                participants: [ishaan, kabir, arjun, vihaan],
                headerSymbolName: "sportscourt.fill",
                headerGradientColors: [
                    Color(red: 0.15, green: 0.50, blue: 0.35),
                    Color(red: 0.25, green: 0.65, blue: 0.45)
                ]
            )
        ]

    }

    func plan(withId id: UUID) -> GroupPlan? {
        plans.first { $0.id == id }
    }

    func filteredPlans(category: PlanCategory, searchText: String) -> [GroupPlan] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        return plans.filter { plan in
            let matchesCategory = category == .forYou || plan.category == category
            guard matchesCategory else { return false }

            guard !query.isEmpty else { return true }

            let searchable = [
                plan.title,
                plan.location,
                plan.cityArea,
                plan.category.rawValue,
                plan.interestTags.joined(separator: " ")
            ]
            .joined(separator: " ")
            .lowercased()

            return searchable.contains(query)
        }
    }
}
