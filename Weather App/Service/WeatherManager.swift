//
//  WeatherManager.swift
//  Weather App
//
//  Created by Herbert Dodge on 5/2/21.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didUpdateForecast(_ weatherManager: WeatherManager, weather: ([WeatherModel], [WeatherModel]))
    func didFailWithError(error: Error)
}

fileprivate let apiKey = "48d7c8f8e6f767f90b8ae438346b5f3a"

struct WeatherManager {
    
    var delegate: WeatherManagerDelegate?
    
    enum APIUrl {
        static let singleCall = "https://api.openweathermap.org/data/2.5/weather?appid=\(apiKey)&units=imperial"
        static let foreCastCall = "https://api.openweathermap.org/data/2.5/onecall?appid=\(apiKey)&units=imperial"
    }
    
    //MARK: - Methods for preparing for API call
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString = "\(APIUrl.singleCall)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    
    func fetchForcast(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString = "\(APIUrl.foreCastCall)&lat=\(latitude)&lon=\(longitude)&exclude=minutely,current,alerts"
        performRequest(with: urlString)
    }
    
    //MARK: - Body of API call
    
    func performRequest(with urlString: String) {
        let session = URLSession(configuration: .default)
        if let url = URL(string: urlString) {
            
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    print("task error")
                    return
                }
                
                if let safeData = data {
                    if let weather = self.parseSingleCallData(safeData) {
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    } else {
                        if let forecast = self.parseForecastCallData(safeData) {
                            self.delegate?.didUpdateForecast(self, weather: forecast)
                        }
                    }
                }
            }
            task.resume()
        }
    }
    
    //MARK: - Methods for parsing API calls
    
    func parseSingleCallData(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(SingleCallWeatherData.self, from: weatherData)
            let weather = WeatherModel(conditionId: decodedData.weather[0].id, cityName: decodedData.name ?? "City not found..", temperature: decodedData.main.temp, description: decodedData.weather[0].description, dt: nil)
            return weather
        } catch {
            print(error)
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    func parseForecastCallData(_ weatherData: Data) -> ([WeatherModel], [WeatherModel])? {
        let decoder = JSONDecoder()
        var weather: ([WeatherModel], [WeatherModel])?
        do {
            var decodedData = try decoder.decode(ForecastCallWeatherData.self, from: weatherData)
            decodedData.sortForecastData()
            let hourly = decodedData.hourly
            let daily = decodedData.daily
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
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
