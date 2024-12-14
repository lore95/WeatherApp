import CoreLocation
import Foundation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var currentLocation: PlaceSuggestion? // Location suggestion object
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let geocoder = CLGeocoder()
            
            // Perform reverse geocoding to get a display name
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                if let error = error {
                    print("Reverse geocoding failed: \(error.localizedDescription)")
                    return
                }
                
                if let placemark = placemarks?.first {
                    // Extract city name or locality as display_name
                    let cityName = placemark.locality ?? "Unknown Location"
                    
                    // Create PlaceSuggestion object
                    let place = PlaceSuggestion(
                        display_name: cityName,
                        lat: "\(location.coordinate.latitude)",
                        lon: "\(location.coordinate.longitude)"
                    )
                    
                    DispatchQueue.main.async {
                        self.currentLocation = place
                    }
                }
            }
            
            manager.stopUpdatingLocation() // Stop further updates
        }
    }
}
