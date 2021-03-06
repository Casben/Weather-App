//
//  WeatherManager.swift
//  Weather App
//
//  Created by Herbert Dodge on 5/2/21.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: SingleCallWeatherData)
    func didUpdateForecast(_ weatherManager: WeatherManager, weather: inout ForecastCallWeatherData)
    func didFailWithError(error: Error)
}

fileprivate let apiKey = "48d7c8f8e6f767f90b8ae438346b5f3a"

struct WeatherManager {
    
    let decoder = JSONDecoder()
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
                        if var forecast = self.parseForecastCallData(safeData) {
                            self.delegate?.didUpdateForecast(self, weather: &forecast)
                        }
                    }
                }
            }
            task.resume()
        }
    }
    
    //MARK: - Methods for parsing API calls
    
    func parseSingleCallData(_ weatherData: Data) -> SingleCallWeatherData? {
        
        do {
            let decodedData = try decoder.decode(SingleCallWeatherData.self, from: weatherData)
            return decodedData
        } catch {
            print(error)
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    func parseForecastCallData(_ weatherData: Data) -> ForecastCallWeatherData? {
        
        do {
            let decodedData = try decoder.decode(ForecastCallWeatherData.self, from: weatherData)
            return decodedData
            
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}


