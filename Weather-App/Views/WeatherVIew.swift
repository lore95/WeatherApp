import SwiftUI

struct WeatherView: View {
    @StateObject private var weatherController = WeatherController()
    @StateObject private var searchController = SearchController()
    @State private var showSearchView = false // Toggle for the bottom search view
    
    let place: PlaceSuggestion // Default place

    var body: some View {
        ZStack {
            // Background Image based on weather code
                       Image(weatherController.backgroundName)
                .resizable()
                    .aspectRatio(contentMode: .fill) // Fill but respect aspect ratio
                    .opacity(0.6)
                    .frame(maxWidth: .infinity, maxHeight: .infinity) // Use full screen space
                    .clipped() // Prevent overflowing
                    .ignoresSafeArea()

            VStack {
                // MARK: - Main Weather Info
                if let forecast = weatherController.forecastData {
                    VStack(spacing: 8) {
                        Text(weatherController.cityName.components(separatedBy: ",").first ?? weatherController.cityName)
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.white)
                        
                        Text("\(Int(forecast.hourly.temperature_2m[weatherController.dayIndex] ?? 0))°")
                            .font(.system(size: 100, weight: .thin))
                            .foregroundColor(.white)
                        
                        Text(weatherController.weatherDescription) // Placeholder for weather description
                            .font(.title2)
                            .foregroundColor(.white)
                        
                        Text("H: \(Int(forecast.daily.temperature_2m_max[weatherController.dayIndex] ?? 0))° L: \(Int(forecast.daily.temperature_2m_min[weatherController.dayIndex] ?? 0))°")
                            .foregroundColor(.white.opacity(0.8))
                            .font(.headline)
                    }
                    .padding(.top, 20)
                
                    // MARK: - Hourly Forecast
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                               if let forecast = weatherController.forecastData {
                                   ForEach(0..<forecast.hourly.time.count, id: \.self) { index in
                                       // Check if this hour is part of today's forecast
                                       if forecast.hourly.time[index].hasPrefix(forecast.daily.time.first ?? "") {
                                           HourlyWeatherView(
                                               hour: weatherController.formatHour(forecast.hourly.time[index]),
                                               temp: "\(Int(forecast.hourly.temperature_2m[index]))°"
                                           )
                                       }
                                   }
                               }
                           }
                        .padding()
                    }
                    .background(Color.white.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding()

                    // MARK: - Weekly Forecast
                    VStack(spacing: 16) {
                        // Preprocess the forecast data into an array of tuples
                        let weeklyData = zip(0..<forecast.daily.time.count, forecast.daily.weathercode).map { index, weatherCode in
                            return (
                                day: weatherController.formatDay(forecast.daily.time[index]),
                                high: "\(Int(forecast.daily.temperature_2m_max[index]))",
                                low: "\(Int(forecast.daily.temperature_2m_min[index]))",
                                iconCode: Int(weatherCode),
                                index: index
                            )
                        }
                        
                        // Use preprocessed data in the ForEach loop
                        ForEach(weeklyData, id: \.day) { data in
                            WeeklyWeatherRow(
                                day: data.day,
                                high: data.high,
                                low: data.low,
                                iconCode: data.iconCode
                            )
                            .onTapGesture {
                                weatherController.dayIndex = data.index
                                                weatherController.weatherDescription = weatherController.descriptionForWeatherCode(
                                                    Int(data.iconCode)
                                                )
                                   }
                        }
                    }
                    .padding(.horizontal)
                    
                } else {
                    ProgressView("Loading Weather...")
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // MARK: - Footer with Lens and Heart Icons
                HStack {
                    Spacer()
                    Button(action: {
                        showSearchView.toggle()
                    }) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Image(systemName: "heart.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.red)
                    Spacer()
                }
                .padding(.bottom, 20)
            }
            
            // MARK: - Search View as Bottom Sheet
            if showSearchView {
                VStack {
                    Spacer()
                    SearchView(searchController: searchController) { suggestion in
                        // Update weather data for the selected place
                        showSearchView = false
                        Task {
                            await weatherController.fetchWeatherData(for: suggestion)
                        }
                    }
                }
                .transition(.move(edge: .bottom))
                .animation(.easeInOut, value: showSearchView)
            }
        }
        .task {
            await weatherController.fetchWeatherData(for: place)
        }
    }
}
