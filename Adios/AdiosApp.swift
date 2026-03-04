import SwiftUI

// MARK: NAVIGATION

enum AppScreen {
    case home
    case log
    case benefits(food: String, lines: [String])
    case mapPlot(food: String, lines: [String])
    case map
}

@MainActor
final class AppState: ObservableObject {
    @Published var screen: AppScreen = .home
    @Published var mapEntries: [MapEntry] = [] {
        didSet { save() }
    }

    private let entriesKey = "adios_map_entries"

    init() {
        load()
    }

    func navigate(to screen: AppScreen) {
        withAnimation(.easeInOut(duration: 0.3)) {
            self.screen = screen
        }
    }

    func addEntry(_ entry: MapEntry) {
        mapEntries.append(entry)
    }

    private func save() {
        if let encoded = try? JSONEncoder().encode(mapEntries) {
            UserDefaults.standard.set(encoded, forKey: entriesKey)
        }
    }

    private func load() {
        guard
            let data = UserDefaults.standard.data(forKey: entriesKey),
            let decoded = try? JSONDecoder().decode([MapEntry].self, from: data)
        else { return }
        mapEntries = decoded
    }
}

// MARK: MAP ENTRY MODEL

struct MapEntry: Identifiable, Codable {
    let id: UUID
    let food: String
    let benefits: [String]
    var x: CGFloat
    var y: CGFloat

    init(food: String, benefits: [String], x: CGFloat, y: CGFloat) {
        self.id = UUID()
        self.food = food
        self.benefits = benefits
        self.x = x
        self.y = y
    }
}

// MARK: ENTRY POINT

@main
struct AdiosApp: App {
    @StateObject private var state = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(state)
        }
    }
}

// MARK: ROOT

struct RootView: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        ZStack {
            switch state.screen {
            case .home:
                HomeView()
            case .log:
                LogView()
            case .benefits(let food, let lines):
                BenefitsView(food: food, benefits: lines)
            case .mapPlot(let food, let lines):
                MapPlotView(food: food, benefits: lines)
            case .map:
                MapView()
            }
        }
    }
}
