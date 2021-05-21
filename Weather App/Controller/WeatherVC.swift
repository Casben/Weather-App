//
//  ViewController.swift
//  Weather App
//
//  Created by Herbert Dodge on 5/1/21.
//

import UIKit
import CoreLocation

class WeatherVC: UIViewController {

    //MARK: - Properties
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var forcastView: UIView!
    @IBOutlet weak var forecastControl: UISegmentedControl!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var weatherCollectionView: UICollectionView!
    
    var hourlyForecast = [WeatherModel]()
    var dailyForecast = [WeatherModel]()

    var weatherManager = WeatherManager()
    var viewModel = WeatherViewModel()
    let locationManager = CLLocationManager()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    //MARK: - Configuration
    
    func configure() {
        forcastView.alpha = 0
        forcastView.layer.cornerRadius = 10
        forecastControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        forecastControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(red: 22 / 255, green: 54 / 255, blue: 58 / 255, alpha: 0.64)], for: .normal)
        forecastControl.addTarget(self, action: #selector(forcastControlToggled), for: .valueChanged)
        refreshButton.addTarget(self, action: #selector(refreshWeatherData), for: .touchUpInside)
        refreshButton.isEnabled = false
        configureDate()
        configureLocationManager()
        weatherCollectionView.dataSource = self
        weatherCollectionView.delegate = self
    }

    func configureLocationManager() {
        locationManager.delegate = self
        weatherManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    func configureDate() {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d"
        var currentDate = dateFormatter.string(from: date)
        
        switch currentDate.last {
        case "1":
            if currentDate.contains("11") {
                currentDate.append("th")
                dateLabel.text = currentDate
            } else {
                currentDate.append("st")
                dateLabel.text = currentDate
            }
        case "2":
            currentDate.append("nd")
            dateLabel.text = currentDate
        case "3":
            currentDate.append("rd")
            dateLabel.text = currentDate
        default:
            currentDate.append("th")
            dateLabel.text = currentDate
        }
    }
    
    //MARK: - Methods
    
    @objc func forcastControlToggled(_ sender: UISegmentedControl) {
        weatherCollectionView.reloadData()
    }
    
    @objc func refreshWeatherData() {
        locationManager.requestLocation()
        cityLabel.text = "Loading weather data"
        descriptionLabel.text = "Please stand by..."
        forcastView.alpha = 0
        refreshButton.isEnabled = false
        weatherCollectionView.reloadData()
    }
}

//MARK: - UICollectionViewDataSource & UICollectionViewDelegate

extension WeatherVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = weatherCollectionView.dequeueReusableCell(withReuseIdentifier: WeatherDetailCell.identifier, for: indexPath) as! WeatherDetailCell
        if hourlyForecast.isEmpty == false && dailyForecast.isEmpty == false {
            
            cell.configureWeather(withHourlyWeather: hourlyForecast[indexPath.row], andDailyWeather: dailyForecast[indexPath.row])

            switch forecastControl.selectedSegmentIndex {
            case 0:
                cell.configureCellForHourly()
            case 1:
                cell.configureCellForDaily()
            default:
                break
            }
        }
        return cell
    }
    
}

//MARK: - UICollectionViewFlowLayout
extension WeatherVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 110, height: 128)
    }
}

//MARK: - WeatherManagerDelegate

extension WeatherVC: WeatherManagerDelegate {
    
    func didUpdateForecast(_ weatherManager: WeatherManager, weather: inout ForecastCallWeatherData) {
        let forecastWeather = viewModel.configureForecastWeatherData(withWeather: &weather)
        
        hourlyForecast = forecastWeather.0
        dailyForecast = forecastWeather.1
        
        DispatchQueue.main.async {
            self.weatherCollectionView.reloadData()
        }
    }
    
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: SingleCallWeatherData) {
        let currentWeather = viewModel.configureWeatherData(withWeather: weather)
        
        DispatchQueue.main.async {
            self.temperatureLabel.text = currentWeather.temperatureString
            self.conditionImageView.image = UIImage(systemName: currentWeather.conditionName)
            self.cityLabel.text = currentWeather.cityName
            self.descriptionLabel.text = currentWeather.description
        }
        
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.5) {
            UIView.animate(withDuration: 0.75) {
                self.forcastView.alpha = 1
                self.refreshButton.isEnabled = true
            }
            
        }
    }
    
    func didFailWithError(error: Error) {
        print(error.localizedDescription)
    }
}

//MARK: - CLLocationManagerDelegate

extension WeatherVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            weatherManager.fetchWeather(latitude: lat, longitude: lon)
            weatherManager.fetchForcast(latitude: lat, longitude: lon)
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
