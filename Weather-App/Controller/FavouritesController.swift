import Foundation

class FavoritePlacesManager: ObservableObject {
    private let favoritesKey = "favorite_places"

    @Published var favoritePlaces: [PlaceSuggestion] = []

    init() {
        loadFavorites()
    }

    // Add a place to favorites
    func addPlace(_ place: PlaceSuggestion) {
        if !favoritePlaces.contains(where: { $0.display_name == place.display_name }) {
            favoritePlaces.append(place)
            saveFavorites()
        }
    }

    // Remove a place from favorites
    func removePlace(_ place: PlaceSuggestion) {
        favoritePlaces.removeAll { $0.display_name == place.display_name }
        saveFavorites()
    }

    // Load favorites from UserDefaults
    private func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: favoritesKey) {
            if let decoded = try? JSONDecoder().decode([PlaceSuggestion].self, from: data) {
                favoritePlaces = decoded
            }
        }
    }

    // Save favorites to UserDefaults
    private func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favoritePlaces) {
            UserDefaults.standard.set(encoded, forKey: favoritesKey)
        }
    }
}
