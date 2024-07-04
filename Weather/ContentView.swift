//
//  ContentView.swift
//  Weather
//
//  Created by Milind Contractor on 4/7/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @ObservableObject
    
    var body: some View {
        VStack {
            
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
