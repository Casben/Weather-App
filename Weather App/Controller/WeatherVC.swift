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
    @IBOutlet weak var forcastControl: UISegmentedControl!
    @IBOutlet weak var refreshButton: UIButton!
    
    @IBOutlet weak var detailView1: WeatherDetailView!
    @IBOutlet weak var detailView2: WeatherDetailView!
    @IBOutlet weak var detailView3: WeatherDetailView!
    @IBOutlet weak var detailView4: WeatherDetailView!
    @IBOutlet weak var detailView5: WeatherDetailView!
    
    lazy var detailViews: [WeatherDetailView] = {
       var collection = Array<WeatherDetailView>()
        collection.append(detailView1)
        collection.append(detailView2)
        collection.append(detailView3)
        collection.append(detailView4)
        collection.append(detailView5)
        return collection
    }()
    
    var hourlyForecast = [WeatherModel]()
    var dailyForecast = [WeatherModel]()

    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    //MARK: - Configuration
    
    func configure() {
        forcastView.alpha = 0
        hideUI()
        forcastView.layer.cornerRadius = 10
        forcastControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        forcastControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(red: 22 / 255, green: 54 / 255, blue: 58 / 255, alpha: 0.64)], for: .normal)
        forcastControl.addTarget(self, action: #selector(forcastControlToggled), for: .valueChanged)
        refreshButton.addTarget(self, action: #selector(refreshWeatherData), for: .touchUpInside)
        refreshButton.isEnabled = false
        configureDate()
        configureLocationManager()
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
            currentDate.append("st")
            dateLabel.text = currentDate
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

    //MARK: - Helpers
    
    func updateHourlyForecastUI() {
        _ = detailViews.enumerated().map { view in
            view.element.updateUIForHourly(with: hourlyForecast[view.offset])
        }
    }
    
    func updateDailyForecastUI() {
        _ = detailViews.enumerated().map({ view in
            view.element.updateUIForDaily(with: dailyForecast[view.offset])
        })
    }
    
    func animateUI() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            for view in self.detailViews {
                UIView.animate(withDuration: 0.75) {
                    view.alpha = 1
                }
                
            }
        }
    }
    
    func hideUI() {
        _ = detailViews.map({ view in
            DispatchQueue.main.async {
                view.alpha = 0
            }
        })
    }
    
    //MARK: - Methods
    
    @objc func forcastControlToggled(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            updateHourlyForecastUI()
            hideUI()
            animateUI()
        case 1:
            updateDailyForecastUI()
            hideUI()
            animateUI()
        default:
            break
        }
    }
    
    @objc func refreshWeatherData() {
        locationManager.requestLocation()
        cityLabel.text = "Loading weather data"
        descriptionLabel.text = "Please stand by..."
        hideUI()
        forcastView.alpha = 0
        refreshButton.isEnabled = false
    }
}

//MARK: - WeatherManagerDelegate

extension WeatherVC: WeatherManagerDelegate {
    func didUpdateForecast(_ weatherManager: WeatherManager, weather: ([WeatherModel], [WeatherModel])) {
        hourlyForecast = weather.0
        dailyForecast = weather.1
        updateHourlyForecastUI()
    }

    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async {
            self.temperatureLabel.text = weather.temperatureString + "°F"
            self.conditionImageView.image = UIImage(systemName: weather.conditionName)
            self.cityLabel.text = weather.cityName
            self.descriptionLabel.text = weather.description
            
        }
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.5) {
            UIView.animate(withDuration: 0.75) {
                self.forcastView.alpha = 1
                self.refreshButton.isEnabled = true
            }
            
        }
        animateUI()
        
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
