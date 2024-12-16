import SwiftUI

struct FavoritesView: View {
    @ObservedObject var favoriteManager: FavoritePlacesManager
    var onSelect: (PlaceSuggestion) -> Void
    var onClose: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            // MARK: - Header with Close Button
            HStack {
                Text("Favorite Cities")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            // MARK: - Horizontal Scroll View of Cities
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(favoriteManager.favoritePlaces) { place in
                        Button(action: {
                            onSelect(place)
                        }) {
                            VStack(spacing: 8) {
                                // City Icon
                                Image(systemName: "building.2.fill")
                                    .font(.system(size: 36))
                                    .foregroundColor(.blue.opacity(0.8))
                                
                                // City Name
                                Text(place.display_name)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            }
                            .frame(width: 120, height: 120)
                            .background(Color.black.opacity(0.3)) // Darker gray for the cards
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.6), radius: 4, x: 0, y: 2)
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding(.vertical)
        .background(Color.gray.opacity(0.9)) // Darker gray background
        .cornerRadius(16)
        .shadow(radius: 8)
        .padding()
    }
}
