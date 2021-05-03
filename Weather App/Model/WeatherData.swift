//
//  WeatherData.swift
//  Weather App
//
//  Created by Herbert Dodge on 5/2/21.
//

import Foundation

struct WeatherData: Codable {
    let name: String
    let main: Main
    let weather: [Weather]
//    let hourly: [Hourly]
//    let daily: [Daily]
    
    struct Main: Codable {
        let temp: Double
    }
    
    struct Weather: Codable {
        let id: Int
        let description: String
    }
    
    struct Hourly: Codable {
        let dt: Int
        let temp: Double
        let weather: [Weather]
    }
    
    struct Daily: Codable {
        let dt: Int
        let temp: Double
        let weather: [Weather]
    }
}

