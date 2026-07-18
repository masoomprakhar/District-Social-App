import Foundation
import Observation

@Observable
final class HomeViewModel {
    var searchText: String = ""
    var locationName: String = "Delhi NCR"
    var locationSubtitle: String = "New Delhi, India"
    var selectedTab: HomeTab = .home

    private let dataService: MockDataService

    init(dataService: MockDataService = .shared) {
        self.dataService = dataService
    }

    var currentUser: UserProfile {
        dataService.currentUser
    }

    var categories: [HomeCategory] {
        dataService.homeCategories
    }

    var spotlightItems: [SpotlightItem] {
        dataService.spotlightItems
    }
}
