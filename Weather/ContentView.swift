//
//  ContentView.swift
//  Weather
//
//  Created by Milind Contractor on 4/7/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @ObservedObject var weatherManager = WeatherManager()
    @State var exisitingWeatherData: [WeatherDataRead] = []
    var latestData: WeatherDataRead {
        if exisitingWeatherData.count != 0 {
            return exisitingWeatherData[exisitingWeatherData.count - 1]
        } else {
            return WeatherDataRead(hour: "Loading...", daylight: 0, code: 0, temperature: 0)
        }
    }
    @Environment(\.colorScheme) var colorScheme

    
    func recieveData() {
        locationManager.checkLocationAuthorization()
        if let coordinate = locationManager.lastKnownLocation {
            weatherManager.fetchWeatherData(from: "https://api.open-meteo.com/v1/forecast?latitude=\(coordinate.latitude)&longitude=\(coordinate.longitude)&hourly=precipitation,temperature_2m,weather_code,is_day&timezone=Asia%2FSingapore") { weather in
                if let weatherData = weather {
                    for (index, item) in weatherData.hourly.time.enumerated() {
                        exisitingWeatherData.append(WeatherDataRead(hour: weatherData.hourly.time[index], daylight: Int(weatherData.hourly.temperature2M[index]), code: weatherData.hourly.isDay[index], temperature: weatherData.hourly.temperature2M[index]))
                    }
                } else {
                    print("Failed to fetch weather data.")
                }
            }
        }

    }
    
    var body: some View {
        VStack {
            VStack {
                if latestData.hour != "Loading..." {
                    VStack(spacing: 20) {
                        Text("Current Weather:")
                            .fontWidth(.expanded)
                        Image(systemName: latestData.iconForecast)
                            .font(.system(size: 90))
                        Text("\(latestData.temperatureValue)°C")
                            .font(.system(size: 20))
                            .fontWidth(.expanded)
                        Text("at (\(latestData.textHour))")
                            .font(.system(size: 20))
                            .fontWidth(.expanded)
                    }
                } else {
                    Text("Loading Weather Data...")
                        .fontWidth(.expanded)
                        .onAppear {
                            recieveData()
                        }
                }
            }
            ScrollView {
                ForEach(exisitingWeatherData, id: \.id) { data in
                    HStack {
                        Image(systemName: data.iconForecast)
                            .font(.system(size: 30))
                            .symbolRenderingMode(.palette)
                            .padding()
                        VStack {
                            Text("\(data.temperatureValue)°C")
                                .font(.system(size: 17))
                                .fontWidth(.expanded)
                            Text("_at \(data.textHour)_")
                                .font(.system(size: 17))
                                .fontWidth(.expanded)
                        }
                    }
                    .padding(10)
                    .frame(width: UIScreen.main.bounds.width - 40)
                    .background(colorScheme == .dark ? Color(red: 18/225, green: 18/225, blue: 18/225) : Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10.0, style: .continuous))
                    .shadow(color: colorScheme == .dark ? .white.opacity(0.01) : .black.opacity(0.1), radius: 15, x: 0, y: 5)
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                }
            }
            .onAppear {
                recieveData()
            }
        }
    }
}

#Preview {
    ContentView()
}
