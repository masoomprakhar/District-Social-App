import SwiftUI

struct ContentView: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            HomeView(path: $path)
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .socialize:
                        SocializeView(path: $path)
                    case .planDetail(let id):
                        if let plan = MockDataService.shared.plan(withId: id) {
                            PlanDetailView(plan: plan)
                        } else {
                            Text("Plan not found")
                                .foregroundStyle(AppTheme.secondaryText)
                        }
                    }
                }
        }
        .tint(AppTheme.socializePurple)
    }
}

#Preview {
    ContentView()
}

