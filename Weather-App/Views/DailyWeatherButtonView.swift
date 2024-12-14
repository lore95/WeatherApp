import SwiftUI


struct DailyWeatherButton: View {
    let day: String
    let high: String
    let low: String
    var iconCode: Int
    
    // Helper function to get the system image name based on weather code
    func weatherIconName(for code: Int) -> String {
        if code == 0 {
            return "sun"
        } else if (1...2).contains(code) {
            return "cloudy"
        } else if code == 3 || code == 45 || code == 48 {
            return "cloud"
        } else if (51...53).contains(code) || (61...65).contains(code) || (80...82).contains(code) {
            return "rainy"
        } else if (56...57).contains(code) || (66...67).contains(code) || (71...77).contains(code) || (85...86).contains(code) {
            return "snow"
        } else if code == 95 || code == 96 || code == 99 {
            return "strom"
        } else {
            return "questionmark"
        }
    }
    let onSelect: () -> Void // Callback when clicked

    var body: some View {
        Button(action: onSelect) {
            HStack {
                Text(day)
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                Image(weatherIconName(for: iconCode))
                    .resizable()
                    .frame(width: 25, height: 25)
                    .scaledToFit()

                Spacer()

                Text("H: \(high)° L: \(low)°")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding()
            .background(Color.white.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}
