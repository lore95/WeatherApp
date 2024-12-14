import SwiftUI

struct WeeklyWeatherRow: View {
    var day: String
    var high: String
    var low: String
    var iconCode: Int
    
    // Helper function to get the system image name based on weather code
    func weatherIconName(for code: Int) -> String {
        if code == 0 {
            return "sun.max.fill"
        } else if (1...2).contains(code) {
            return "cloud.sun.fill"
        } else if code == 3 || code == 45 || code == 48 {
            return "cloud.fill"
        } else if (51...53).contains(code) || (61...65).contains(code) || (80...82).contains(code) {
            return "cloud.rain.fill"
        } else if (56...57).contains(code) || (66...67).contains(code) || (71...77).contains(code) || (85...86).contains(code) {
            return "snow"
        } else if code == 95 || code == 96 || code == 99 {
            return "cloud.bolt.fill"
        } else {
            return "questionmark"
        }
    }
    
    var body: some View {
        HStack {
            Text(day)
                .font(.headline)
                .foregroundColor(.white)
            Spacer()
            Image(systemName: weatherIconName(for: iconCode)) // Use helper function
                .font(.title2)
                .foregroundColor(.white)
            Spacer()
            Text("\(high)° / \(low)°")
                .font(.subheadline)
                .foregroundColor(.white)
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
        .background(Color.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
