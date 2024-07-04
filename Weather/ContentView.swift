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
    @State var exisitingWeatherData = []
    
    var body: some View {
        VStack {
            
        }
        .padding()
        .onAppear {
            weatherManager.fetchWeatherData(from: "https://api.open-meteo.com/v1/forecast?latitude=1.342128&longitude=103.9568&hourly=precipitation,temperature_2m,weather_code,is_day&timezone=Asia%2FSingapore") { weather in
                if let weatherData = weather {
                    exisitingWeatherData.append(weather)
                } else {
                    print("Failed to fetch weather data.")
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
