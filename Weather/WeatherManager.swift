//
//  WeatherManager.swift
//  Weather
//
//  Created by Milind Contractor on 4/7/24.
//

import Foundation
import OpenMeteoSdk

import Foundation

// Define the structures to match the JSON
struct WeatherData: Codable, Identifiable {
    let id = UUID()
    let latitude: Double
    let longitude: Double
    let generationTimeMS: Double
    let utcOffsetSeconds: Int
    let timezone: String
    let timezoneAbbreviation: String
    let elevation: Double
    let hourlyUnits: HourlyUnits
    let hourly: HourlyData
    
    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
        case generationTimeMS = "generationtime_ms"
        case utcOffsetSeconds = "utc_offset_seconds"
        case timezone
        case timezoneAbbreviation = "timezone_abbreviation"
        case elevation
        case hourlyUnits = "hourly_units"
        case hourly
    }
}

struct HourlyUnits: Codable {
    let time: String
    let precipitation: String
    let temperature2M: String
    let weatherCode: String
    let isDay: String
    
    enum CodingKeys: String, CodingKey {
        case time
        case precipitation
        case temperature2M = "temperature_2m"
        case weatherCode = "weather_code"
        case isDay = "is_day"
    }
}

struct HourlyData: Codable {
    let time: [String]
    let precipitation: [Double]
    let temperature2M: [Double]
    let weatherCode: [Int]
    let isDay: [Int]
    
    enum CodingKeys: String, CodingKey {
        case time
        case precipitation
        case temperature2M = "temperature_2m"
        case weatherCode = "weather_code"
        case isDay = "is_day"
    }
}



class WeatherManager: ObservableObject {
    func testClass() async -> Bool {
        let url = URL(string: "https://api.open-meteo.com/v1/forecast?latitude=1.342128&longitude=103.9568&hourly=precipitation,temperature_2m,weather_code,is_day&timezone=Asia%2FSingapore")!
        do {
            let responses = try await WeatherApiResponse.fetch(url: url)
            return true
        } catch {
            return false
        }
    }
    
    
    func fetchWeatherData(from urlString: String, completion: @escaping (WeatherData?) -> Void) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error fetching weather data: \(error)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }
            
            do {
                let weatherData = try JSONDecoder().decode(WeatherData.self, from: data)
                completion(weatherData)
            } catch {
                print("Failed to decode JSON: \(error)")
                completion(nil)
            }
        }
        task.resume()
    }
    
    func parseWeatherData(from jsonString: String) -> WeatherData? {
        let jsonData = jsonString.data(using: .utf8)!
        
        do {
            let weatherData = try JSONDecoder().decode(WeatherData.self, from: jsonData)
            return weatherData
        } catch {
            print("Failed to decode JSON: \(error)")
            return nil
        }
    }
    
    
}

struct WeatherDataRead: Identifiable {
    let id = UUID()
    var hour: String
    var textHour: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"

        guard let date = formatter.date(from: hour) else {
          return "Loading..." // Handle invalid date format
        }

        formatter.dateFormat = "hh a"
        return formatter.string(from: date)
    }
    var daylight: Int
    var code: Int
    var iconForecast: String {
        if code == 0 {
            if daylight == 1 {
                return "sun.max.fill"
            } else {
                return "moon.fill"
            }
        } else if [1, 2, 3].contains(code) {
            if daylight == 1 {
                return "cloud.sun.fill"
            } else {
                return "cloud.moon.fill"
            }
        } else if [45, 48].contains(code) {
            return "cloud.fog.fill"
        } else if [51, 53, 55].contains(code) {
            if daylight == 1 {
                return "sun.rain.fill"
            } else {
                return "cloud.moon.rain.fill"
            }
        } else if [56, 57].contains(code) {
            return "cloud.drizzle.fill"
        } else if [61, 63, 65, 66, 67].contains(code) {
            return "cloud.rain.fill"
        } else if [71, 73, 75, 77, 85, 86].contains(code) {
            return "cloud.snow.fill"
        } else if code == 77 {
            return "snowflake"
        } else if [95, 96, 99].contains(code) {
            return "cloud.bolt.rain.fill"
        } else {
            return "exclamationmark.circle.fill"
        }
    }
    var temperature: Double
    var temperatureValue: String {
        return String(format: "%.1f", temperature)
    }
}
