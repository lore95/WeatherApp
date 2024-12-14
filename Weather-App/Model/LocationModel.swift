import Foundation

struct PlaceSuggestion: Codable, Identifiable {
    let id = UUID() // Unique ID for SwiftUI's `ForEach` or Identifiable requirement
    var display_name: String
    var lat: String
    var lon: String
}
