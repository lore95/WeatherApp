import SwiftUI

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        Group {
            if let place = locationManager.currentLocation {
                WeatherView(place: place)
            } else {
                ProgressView("Determining Location...")
                    .foregroundColor(.gray)
            }
        }
    }
}
