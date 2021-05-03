//
//  ViewController.swift
//  Weather App
//
//  Created by Herbert Dodge on 5/1/21.
//

import UIKit

class WeatherVC: UIViewController {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var forcastView: UIView!
    @IBOutlet weak var forcastControl: UISegmentedControl!
    
    @IBOutlet weak var detailView1: WeatherDetailView!
    @IBOutlet weak var detailView2: WeatherDetailView!
    @IBOutlet weak var detailView3: WeatherDetailView!
    @IBOutlet weak var detailView4: WeatherDetailView!
    @IBOutlet weak var detailView5: WeatherDetailView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    

    func configure() {
        forcastView.layer.cornerRadius = 10
        forcastControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        forcastControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
        forcastControl.addTarget(self, action: #selector(forcastControlToggled), for: .valueChanged)
        configureDate()
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
        default:
            currentDate.append("nd")
            dateLabel.text = currentDate
        }
        
        
    }

    
    @objc func forcastControlToggled(_ sender: UISegmentedControl) {
//        switch sender.selectedSegmentIndex {
//        case 0:
//        }
    }
}

