//
//  WeatherViewModel.swift
//  Weather App
//
//  Created by Herbert Dodge on 5/10/21.
//

import Foundation

struct WeatherViewModel {
    
     func configureWeatherData(withWeather data: SingleCallWeatherData) -> WeatherModel {
        let currentWeather = WeatherModel(conditionId: data.weather[0].id, cityName: data.name ?? "City not found", temperature: data.main.temp, description: data.weather[0].description, dt: nil)
        return currentWeather
    }
    
    func configureForecastWeatherData(withWeather data: inout ForecastCallWeatherData) -> ([WeatherModel], [WeatherModel]) {
        var weather: ([WeatherModel], [WeatherModel])
        data.sortForecastData()
        let hourly = data.hourly
        let daily = data.daily
        
        let hourlyData: [WeatherModel] = hourly.map { hourlyWeather in
            let convertedData = WeatherModel(conditionId: hourlyWeather.weather[0].id, cityName: "", temperature: hourlyWeather.temp, description: hourlyWeather.weather[0].description, dt: hourlyWeather.dt)
            return convertedData
        }
        
        let dailyData: [WeatherModel] = daily.map { dailyWeather in
            let convertedData = WeatherModel(conditionId: dailyWeather.weather[0].id, cityName: "", temperature: dailyWeather.temp.determinedHourlyRead, description: dailyWeather.weather[0].description, dt: dailyWeather.dt)
            return convertedData
        }

        weather = (hourlyData, dailyData)
        return weather
    }
}
