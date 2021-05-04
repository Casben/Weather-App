//
//  WeatherData.swift
//  Weather App
//
//  Created by Herbert Dodge on 5/2/21.
//

import Foundation

struct Weather: Codable {
    let id: Int
    let description: String
}

struct Hourly: Codable {
    let dt: Double
    let temp: Double
    let weather: [Weather]
}

struct Daily: Codable {
    let dt: Double
    let temp: Temperature
    let weather: [Weather]
    
    struct Temperature: Codable {
        private let day: Double
        private let night: Double
        private let eve: Double
        private let morn: Double
        
        var determineHourlyRead: Double {
            let currentHour = Calendar.current.component(.hour, from: Date())
            
            switch currentHour {
            case 1...3:
                return night
            case 4...10:
                return morn
            case 11...16:
                return day
            case 17...19:
                return eve
            case 20...24:
                return night
            default:
                return day
            }
        }
    }
}

struct SingleCallWeatherData: Codable {
    let name: String
    let main: Main
    let weather: [Weather]
    
    struct Main: Codable {
        let temp: Double
    }
}



struct ForecastCallWeatherData: Codable {
    var hourly: [Hourly]
    var daily: [Daily]

    mutating func sortForecastData() {
        hourly.sort { hour1, hour2 in
            return hour1.dt < hour2.dt
        }
        
        daily.sort { day1, day2 in
            return day1.dt < day2.dt
        }
        
        hourly = Array(hourly.prefix(through: 5))
        daily = Array(daily.prefix(upTo: 5))
    }
}
