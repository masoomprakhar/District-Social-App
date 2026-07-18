import Foundation
import Observation

@Observable
final class SocializeViewModel {
    var searchText: String = ""
    var selectedFilter: PlanCategory = .forYou

    private let dataService: MockDataService

    init(dataService: MockDataService = .shared) {
        self.dataService = dataService
    }

    var filters: [PlanCategory] {
        PlanCategory.socializeFilters
    }

    var filteredPlans: [GroupPlan] {
        dataService.filteredPlans(category: selectedFilter, searchText: searchText)
    }
}
