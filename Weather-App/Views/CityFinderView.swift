import SwiftUI

struct SearchView: View {
    @ObservedObject var searchController: SearchController
    var onSuggestionSelected: (PlaceSuggestion) -> Void
    @State private var query = "" // Search input
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                // Search Bar
                HStack {
                    TextField("Enter city name", text: $query)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.leading)
                        .onChange(of: query) { newValue in
                            searchController.fetchSuggestions(for: newValue)
                        }
                    
                    if searchController.isSearching {
                        ProgressView()
                            .padding(.trailing)
                    }
                }
                .padding(.vertical)
                
                // List of Suggestions
                List(searchController.suggestions) { suggestion in
                    Button(action: {
                        onSuggestionSelected(suggestion)
                    }) {
                        Text(suggestion.display_name)
                            .foregroundColor(.primary)
                    }
                }
            }
            .frame(width: geometry.size.width * 0.9, height: geometry.size.height * 0.75) // 3/4 of the screen height
            .background(Color.gray.opacity(0.9)) // Gray background
            .cornerRadius(12)
            .shadow(radius: 10)
            .position(x: geometry.size.width / 2, y: geometry.size.height * 0.5) // Centered
        }
        .ignoresSafeArea(edges: .all) // Ensures the view doesn't get cut off
    }
}
