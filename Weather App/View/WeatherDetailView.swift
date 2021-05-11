//
//  WeatherDetailView.swift
//  Weather App
//
//  Created by Herbert Dodge on 5/2/21.
//

import UIKit

class WeatherDetailView: UIView {

    //MARK: - Properties
    
    @IBOutlet weak var informationLabel: UILabel!
    @IBOutlet weak var weatherIcon: WeatherIconImageView!
    @IBOutlet weak var tempLabel: UILabel!

    //MARK: - Methods for configuring properties based on weatherData
    
    func updateUIForHourly(with weatherData: WeatherModel) {
        let forecastHour = Date(timeIntervalSince1970: weatherData.dt!)
        var dateFormatter = Calendar.current.component(.hour, from: forecastHour)
        var amOrPM = ""
        
        switch dateFormatter {
        case 1...11:
            amOrPM = "A.M."
        case 12...23:
            amOrPM = "P.M."
        default:
            break
        }
        
        switch dateFormatter {
        case 24:
            dateFormatter = 1
        default:
            dateFormatter -= 12
            dateFormatter += 1
        }
        
    
        DispatchQueue.main.async {
            self.informationLabel.text = String(dateFormatter) + ":00" + " \(amOrPM)"
            self.weatherIcon.image = UIImage(systemName: weatherData.conditionName)
            self.tempLabel.text = weatherData.temperatureString + "°F"
            
        }
    }
    
    func updateUIForDaily(with weatherData: WeatherModel) {
        let forecastHour = Date(timeIntervalSince1970: weatherData.dt!)
        let dateFormatter = Calendar.current.component(.weekday, from: forecastHour)
        
        var dayOfTheWeek = ""
        switch dateFormatter {
        case 0:
            dayOfTheWeek = "Sun"
        case 1:
            dayOfTheWeek = "Mon"
        case 2:
            dayOfTheWeek = "Tue"
        case 3:
            dayOfTheWeek = "Wed"
        case 4:
            dayOfTheWeek = "Thur"
        case 5:
            dayOfTheWeek = "Fri"
        default:
            dayOfTheWeek = "Sat"
        }

        DispatchQueue.main.async {
            self.informationLabel.text = dayOfTheWeek
            self.weatherIcon.image = UIImage(systemName: weatherData.conditionName)
            self.tempLabel.text = weatherData.temperatureString + "°F"
        }
        
    }
}
