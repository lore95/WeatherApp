import Foundation

class WeatherController: ObservableObject {
    @Published var forecastData: ForecastData? // Holds fetched weather data
    @Published var cityName: String = "Unknown" // Make it non-optional
    @Published var weatherDescription: String = "Loading..." // Human-readable weather description
    @Published var hourlyToday: [(time: String, temp: Double, code: Int)] = [] // Hourly for today
    @Published var dailyWeatherIcons: [String] = [] // Daily weather icons
    @Published var hourlyWeatherIcons: [String] = [] // Hourly weather icons
    
    // MARK: - Background Image Selector
    var backgroundName: String {
        guard let code = forecastData?.daily.weathercode.first else {
            return "default"  // Default background image name
        }
        switch code {
        case 0:
            return "sunnybckgrd"
        case 1...3:
            return "partlycloudybckgrd"
        case 45, 48:
            return "cloudybckgrd"
        case 51...55, 61...65, 80...82:
            return "rainbckgrd"
        case 56...57, 66...67, 71...77, 85...86:
            return "snowybckgrd"
        case 95, 96, 99:
            return "thunderbckgrd"
        default:
            return "default"
        }
    }
    // Fetch weather data from API
    func fetchWeatherData(for place: PlaceSuggestion) async {
        let formattedLat = String(format: "%.3f", Double(place.lat) ?? 0.0)
        let formattedLon = String(format: "%.3f", Double(place.lon) ?? 0.0)
        
        let urlString = """
                                https://api.open-meteo.com/v1/forecast?latitude=\(formattedLat)&longitude=\(formattedLon)&daily=weathercode,temperature_2m_max,temperature_2m_min,apparent_temperature_max,apparent_temperature_min,sunrise,sunset,precipitation_sum,rain_sum,showers_sum,snowfall_sum,precipitation_hours,windspeed_10m_max,windgusts_10m_max,winddirection_10m_dominant,shortwave_radiation_sum,et0_fao_evapotranspiration&hourly=temperature_2m&timezone=Europe%2FBerlin
                                """
        
        guard let url = URL(string: urlString) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedData = try JSONDecoder().decode(ForecastData.self, from: data)
            DispatchQueue.main.async {
                self.forecastData = decodedData
                self.cityName = place.display_name
            }
        } catch {
            print("Error fetching data: \(error.localizedDescription)")
        }
    }
    private func filterHourlyData(for data: ForecastData) {
        guard let today = data.daily.time.first else { return }
        
        let hourlyTimes = data.hourly.time
        let hourlyTemps = data.hourly.temperature_2m
        
        self.hourlyToday = hourlyTimes.enumerated().compactMap { index, time in
            if time.hasPrefix(today) {
                let weatherCode = self.forecastData?.daily.weathercode.first ?? 0 // Fallback for icons
                return (time: String(time.suffix(5)), temp: hourlyTemps[index], code: weatherCode)
            }
            return nil
        }
    }
    
    // Format hour from ISO8601 string
    func formatHour(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            let hourFormatter = DateFormatter()
            hourFormatter.dateFormat = "HH:mm"
            return hourFormatter.string(from: date)
        }
        return dateString
    }
    
    // Format day from ISO8601 string
    func formatDay(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "EEEE"
            return dayFormatter.string(from: date)
        }
        return dateString
    }
    
    func descriptionForWeatherCode(_ code: Int) -> String {
        let descriptions: [Int: String] = [
            0: "Clear sky",
            1: "Mainly clear",
            2: "Partly cloudy",
            3: "Overcast",
            45: "Fog",
            48: "Depositing rime fog",
            
            51: "Light drizzle",
            53: "Moderate drizzle",
            55: "Dense drizzle",
            56: "Light freezing drizzle",
            57: "Dense freezing drizzle",
            
            61: "Slight rain",
            63: "Moderate rain",
            65: "Heavy rain",
            66: "Light freezing rain",
            67: "Heavy freezing rain",
            
            71: "Slight snowfall",
            73: "Moderate snowfall",
            75: "Heavy snowfall",
            77: "Snow grains",
            
            80: "Slight rain showers",
            81: "Moderate rain showers",
            82: "Violent rain showers",
            
            85: "Slight snow showers",
            86: "Heavy snow showers",
            
            95: "Thunderstorm (slight or moderate)",
            96: "Thunderstorm with slight hail",
            99: "Thunderstorm with heavy hail",
        ]
        
        return descriptions[code] ?? "Unknown weather condition"
    }
    func weatherIconImage(for code: Int) -> String {
        switch code {
        case 0:
            return "sun"
        case 1...2:
            return "partCloudy"
        case 3, 45, 48:
            return "cloudy"
        case 51...53, 61...65, 80...82:
            return "rainy"
        case 56...57, 66...67, 71...77, 85...86:
            return "snow"
        case 95, 96, 99:
            return "storm"
        default:
            return "default"
        }
    }
    func weatherDescription(for dayIndex: Int) -> String {
           guard let forecast = forecastData else { return "N/A" }
           
           let weatherCode = forecast.daily.weathercode[dayIndex]
           
        let descriptions: [Int: String] = [
                    0: "Clear sky",
                    1: "Mainly clear",
                    2: "Partly cloudy",
                    3: "Overcast",
                    45: "Fog",
                    48: "Depositing rime fog",
                    51: "Light drizzle",
                    53: "Moderate drizzle",
                    55: "Dense drizzle",
                    56: "Light freezing drizzle",
                    57: "Dense freezing drizzle",
                    61: "Slight rain",
                    63: "Moderate rain",
                    65: "Heavy rain",
                    66: "Light freezing rain",
                    67: "Heavy freezing rain",
                    71: "Slight snowfall",
                    73: "Moderate snowfall",
                    75: "Heavy snowfall",
                    77: "Snow grains",
                    80: "Slight rain showers",
                    81: "Moderate rain showers",
                    82: "Violent rain showers",
                    85: "Slight snow showers",
                    86: "Heavy snow showers",
                    95: "Thunderstorm (slight or moderate)",
                    96: "Thunderstorm with slight hail",
                    99: "Thunderstorm with heavy hail"
                ]

                return descriptions[weatherCode] ?? "Unknown weather condition"
           }
}
