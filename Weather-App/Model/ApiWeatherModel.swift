struct ForecastData: Decodable {
    let latitude: Double
    let longitude: Double
    let generationtime_ms: Double
    let utc_offset_seconds: Int
    let timezone: String
    let timezone_abbreviation: String
    let elevation: Double
    let daily_units: DailyUnits
    let daily: DailyWeather
    let hourly_units: HourlyUnits
    let hourly: HourlyWeather
}

struct DailyUnits: Decodable {
    let time: String
    let weathercode: String
    let temperature_2m_max: String
    let temperature_2m_min: String
    let apparent_temperature_max: String
    let apparent_temperature_min: String
    let sunrise: String
    let sunset: String
    let precipitation_sum: String
    let rain_sum: String
    let showers_sum: String
    let snowfall_sum: String
    let precipitation_hours: String
    let windspeed_10m_max: String
    let windgusts_10m_max: String
    let winddirection_10m_dominant: String
    let shortwave_radiation_sum: String
    let et0_fao_evapotranspiration: String
}

struct DailyWeather: Decodable {
    let time: [String]
    let weathercode: [Int]
    let temperature_2m_max: [Double]
    let temperature_2m_min: [Double]
    let apparent_temperature_max: [Double]
    let apparent_temperature_min: [Double]
    let sunrise: [String]
    let sunset: [String]
    let precipitation_sum: [Double]
    let rain_sum: [Double]
    let showers_sum: [Double]
    let snowfall_sum: [Double]
    let precipitation_hours: [Double]
    let windspeed_10m_max: [Double]
    let windgusts_10m_max: [Double]
    let winddirection_10m_dominant: [Double]
    let shortwave_radiation_sum: [Double]
    let et0_fao_evapotranspiration: [Double]
}

struct HourlyUnits: Decodable {
    let time: String
    let temperature_2m: String
}

struct HourlyWeather: Decodable {
    let time: [String]
    let temperature_2m: [Double]
}
