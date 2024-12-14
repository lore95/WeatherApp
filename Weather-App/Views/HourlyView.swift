import SwiftUI


// MARK: - Subviews
struct HourlyWeatherView: View {
    var hour: String
    var temp: String
    
    var body: some View {
        VStack {
            Text(hour)
                .font(.subheadline)
                .foregroundColor(.white)
            Text(temp)
                .font(.title3)
                .foregroundColor(.white)
        }
        .padding()
        .background(Color.white.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
