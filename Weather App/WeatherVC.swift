//
//  ViewController.swift
//  Weather App
//
//  Created by Herbert Dodge on 5/1/21.
//

import UIKit

class WeatherVC: UIViewController {

    @IBOutlet weak var forcastView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }


    func configure() {
        forcastView.layer.cornerRadius = 10
    }
}

