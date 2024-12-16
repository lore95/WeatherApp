import SwiftUI

struct WeatherView: View {
    @StateObject private var weatherController = WeatherController()
    @StateObject private var searchController = SearchController()
    @StateObject private var settingsController = SettingsController()
    @State private var showSearchView = false  // Toggle for the bottom search view
    @StateObject private var favoriteManager = FavoritePlacesManager()
    @State private var showFavoritesView = false  // Toggle for the favorites pop-up
    @State private var showSettingsView = false  // Toggle for settings pop-up
    @State private var refreshInterval: TimeInterval = 60.0  // Default to 60 seconds
    @State private var refreshTask: Task<Void, Never>? = nil  // Holds the refresh task

    let place: PlaceSuggestion  // Default place

    var body: some View {
        ZStack {
            ZStack {
                // Background Image
                Image(weatherController.backgroundName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()

                // Dark overlay
                Color.black.opacity(0.4)  // Adjust opacity for darkness
                    .ignoresSafeArea()

                // Foreground Content
                VStack {
                    // Your main weather content here...
                    Spacer()
                }
            }
            VStack {
                // MARK: - Main Weather Info
                if let forecast = weatherController.forecastData {
                    VStack(spacing: 8) {

                        // City Name - Truncates nicely if it's too long
                        Text(
                            weatherController.cityName.components(
                                separatedBy: ","
                            ).first ?? weatherController.cityName
                        )
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)

                        ZStack {
                            // Centered Temperature
                            Text(
                                "\(Int(weatherController.forecastData?.hourly.temperature_2m[weatherController.dayIndex] ?? 0))°"
                            )
                            .font(.system(size: 100, weight: .thin))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)  // Ensures centering

                            // List Button - Positioned slightly to the right
                            HStack {
                                Spacer()  // Pushes the button to the right
                                Button(action: {
                                    showFavoritesView.toggle()
                                }) {
                                    Image(systemName: "list.bullet")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .padding(8)
                                        .background(Color.white.opacity(0.2))
                                        .clipShape(Circle())
                                }
                                .padding(.trailing, 24)  // Adjusts button position slightly to the right
                            }
                        }
                        .padding(.horizontal)
                        Text(weatherController.weatherDescription)  // Placeholder for weather description
                            .font(.title2)
                            .foregroundColor(.white)

                        Text(
                            "H: \(Int(forecast.daily.temperature_2m_max[weatherController.dayIndex] ?? 0))° L: \(Int(forecast.daily.temperature_2m_min[weatherController.dayIndex] ?? 0))°"
                        )
                        .foregroundColor(.white.opacity(0.8))
                        .font(.headline)
                    }
                    .padding(.top, 20)

                    // MARK: - Hourly Forecast
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            if let forecast = weatherController.forecastData {
                                ForEach(
                                    0..<forecast.hourly.time.count, id: \.self
                                ) { index in
                                    if forecast.hourly.time[index].hasPrefix(
                                        forecast.daily.time.first ?? "")
                                    {
                                        HourlyWeatherView(
                                            hour: weatherController.formatHour(
                                                forecast.hourly.time[index]),
                                            temp:
                                                "\(Int(forecast.hourly.temperature_2m[index]))°"
                                        )
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                    .frame(height: 120)  // Fixed height for hourly forecast
                    .background(Color.white.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding()

                    // MARK: - Weekly Forecast
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 16) {
                            if let forecast = weatherController.forecastData {
                                let weeklyData = zip(
                                    0..<forecast.daily.time.count,
                                    forecast.daily.weathercode
                                ).map { index, weatherCode in
                                    return (
                                        day: weatherController.formatDay(
                                            forecast.daily.time[index]),
                                        high:
                                            "\(Int(forecast.daily.temperature_2m_max[index]))",
                                        low:
                                            "\(Int(forecast.daily.temperature_2m_min[index]))",
                                        iconCode: Int(weatherCode),
                                        index: index
                                    )
                                }

                                ForEach(weeklyData, id: \.day) { data in
                                    WeeklyWeatherRow(
                                        day: data.day,
                                        high: data.high,
                                        low: data.low,
                                        iconCode: data.iconCode
                                    )
                                    .onTapGesture {
                                        weatherController.dayIndex = data.index
                                        weatherController.weatherDescription =
                                            weatherController
                                            .descriptionForWeatherCode(
                                                Int(data.iconCode))
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                    .frame(height: 250)  // Fixed height for weekly forecast
                    .background(Color.white.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding()
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
                    Button(action: {
                        let currentPlace = PlaceSuggestion(
                            display_name: weatherController.cityName,
                            lat: String(
                                format: "%.3f",
                                weatherController.forecastData?.latitude ?? 0.0),  // Format as 6 decimal places
                            lon: String(
                                format: "%.3f",
                                weatherController.forecastData?.longitude ?? 0.0
                            )  // Format as 6 decimal places
                        )

                        if favoriteManager.favoritePlaces.contains(where: {
                            $0.display_name == currentPlace.display_name
                        }) {
                            favoriteManager.removePlace(currentPlace)
                        } else {
                            favoriteManager.addPlace(currentPlace)
                        }
                    }) {
                        Image(
                            systemName: favoriteManager.favoritePlaces.contains(
                                where: {
                                    $0.display_name
                                        == weatherController.cityName
                                }) ? "heart.fill" : "heart"
                        )
                        .font(.system(size: 28))
                        .foregroundColor(.red)
                    }
                    Spacer()
                    Button(action: {
                        showSettingsView.toggle()
                    }) {
                        Image(systemName: "gearshape.fill")  // Settings Icon
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                    }
                    Spacer()
                }
                .padding(.bottom, 20)
            }

            // MARK: - Search View as Bottom Sheet
            if showSearchView {
                VStack {
                    Spacer()
                    SearchView(searchController: searchController) {
                        suggestion in
                        // Update weather data for the selected place
                        showSearchView = false
                        Task {
                            await weatherController.fetchWeatherData(
                                for: suggestion)
                        }
                    }
                }
                .transition(.move(edge: .bottom))
                .animation(.easeInOut, value: showSearchView)
            }
            // MARK: - Favorites Pop-Up View
            if showFavoritesView {
                Color.black.opacity(0.4).ignoresSafeArea()  // Background dimming effect
                FavoritesView(
                    favoriteManager: favoriteManager,
                    onSelect: { selectedPlace in
                        Task {
                            await weatherController.fetchWeatherData(
                                for: selectedPlace)
                            showFavoritesView = false
                        }
                    },
                    onClose: {
                        showFavoritesView = false
                    }
                )
                .transition(.move(edge: .top))
                .animation(.easeInOut, value: showFavoritesView)
            }

            // Settings Pop-Up View
            if showSettingsView {
                ZStack {
                    Color.black.opacity(0.4).ignoresSafeArea()  // Dim background

                    // Settings Pop-Up
                    if showSettingsView {
                        ZStack {
                            Color.black.opacity(0.4).ignoresSafeArea()
                            SettingsView(
                                settingsController: settingsController,
                                onClose: {
                                    showSettingsView = false
                                    weatherController.startAutoRefresh(
                                        for: place,
                                        with: settingsController.refreshInterval
                                    )
                                }
                            )
                        }
                        .transition(.move(edge: .bottom))
                        .animation(.easeInOut, value: showSettingsView)
                    }
                }
                .transition(.move(edge: .bottom))
                .animation(.easeInOut, value: showSettingsView)
            }
        }
        .task {
            // Fetch data initially
            await weatherController.fetchWeatherData(for: place)

            // Start the auto-refresh loop
            weatherController.startAutoRefresh(
                for: place, with: settingsController.refreshInterval)
        }
    }
}
