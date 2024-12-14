import Foundation

class SearchController: ObservableObject {
    @Published var suggestions: [PlaceSuggestion] = [] // List of city suggestions
    @Published var isSearching = false                // Indicates if search is in progress
    
    // Fetch city suggestions from API
    func fetchSuggestions(for query: String) {
        guard !query.isEmpty else {
            suggestions = []
            return
        }
        
        let queryEncoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://geocode.maps.co/search?q=\(queryEncoded)&api=67599e227aba7501199526lchd7dc3f"
        
        guard let url = URL(string: urlString) else { return }
        
        isSearching = true
        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                self.isSearching = false
            }
            
            if let error = error {
                print("Error fetching suggestions: \(error)")
                return
            }
            
            guard let data = data else { return }
            
            do {
                let decoded = try JSONDecoder().decode([PlaceSuggestion].self, from: data)
                DispatchQueue.main.async {
                    self.suggestions = decoded
                }
            } catch {
                print("Error decoding suggestions: \(error)")
            }
        }.resume()
    }
}
