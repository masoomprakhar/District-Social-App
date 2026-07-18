import Foundation

enum PlanCategory: String, CaseIterable, Identifiable, Hashable {
    case forYou = "For You"
    case dining = "Dining"
    case movies = "Movies"
    case events = "Events"
    case activities = "Activities"
    case socialize = "Socialize"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .forYou: return "sparkles"
        case .dining: return "fork.knife"
        case .movies: return "film"
        case .events: return "ticket"
        case .activities: return "figure.run"
        case .socialize: return "person.3.fill"
        }
    }

    /// Filters shown on the Socialize home screen.
    static var socializeFilters: [PlanCategory] {
        [.forYou, .dining, .movies, .events, .activities]
    }

    /// Shortcuts shown on the main home screen.
    static var homeShortcuts: [PlanCategory] {
        [.movies, .dining, .events, .activities, .socialize]
    }
}
