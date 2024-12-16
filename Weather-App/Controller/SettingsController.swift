import Foundation

class SettingsController: ObservableObject {
    private let refreshIntervalKey = "refreshInterval" // UserDefaults key
    
    @Published var refreshInterval: TimeInterval = 60.0 // Default refresh interval
    
    init() {
        loadRefreshInterval()
    }
    
    // Load refresh interval from UserDefaults
    func loadRefreshInterval() {
        let savedInterval = UserDefaults.standard.double(forKey: refreshIntervalKey)
        if savedInterval > 0 {
            refreshInterval = savedInterval
        }
    }
    
    // Save refresh interval to UserDefaults
    func saveRefreshInterval() {
        UserDefaults.standard.set(refreshInterval, forKey: refreshIntervalKey)
    }
}
