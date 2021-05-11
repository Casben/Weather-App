//
//  WeatherDetailCell.swift
//  Weather App
//
//  Created by Herbert Dodge on 5/11/21.
//

import UIKit

class WeatherDetailCell: UICollectionViewCell {
    static let identifier = "WeatherDetailCell"
    
    @IBOutlet weak var weatherDetailView: WeatherDetailView!
    var hourlyWeather: WeatherModel?
    var dailyWeather: WeatherModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureWeather(withHourlyWeather hourlyWeather: WeatherModel, andDailyWeather dailyWeather: WeatherModel) {
        self.hourlyWeather = hourlyWeather
        self.dailyWeather = dailyWeather
    }
    
    func configureCellForHourly() {
        guard hourlyWeather != nil else {return}
        weatherDetailView.updateUIForHourly(with: hourlyWeather!)
    }
    
    func configureCellForDaily() {
        guard dailyWeather != nil else {return}
        weatherDetailView.updateUIForDaily(with: dailyWeather!)
    }
}
