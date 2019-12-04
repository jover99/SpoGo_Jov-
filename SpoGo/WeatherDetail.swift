//
//  WeatherDetail.swift
//  SpoGo
//
//  Created by Richard Jove on 12/2/19.
//  Copyright © 2019 Richard Jove. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class WeatherDetail {
    var coordinates: String
    
    
    init(coordinates: String) {
        self.coordinates = coordinates

    }
    
    var currentTemp = "--"
    var currentSummary = ""
    var currentIcon = ""
    var currentTime = 0.0
    var timeZone = ""
    
    
    func getWeather(completed: @escaping () -> ()) {
        let weatherURL = urlBase + urlAPIKey + coordinates
        Alamofire.request(weatherURL).responseJSON { response in
            print("Success!")
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                if let temperature = json["currently"]["temperature"].double {
                    let roundedTemp = String(format: "%3.f", temperature)
                    self.currentTemp = roundedTemp + "°F"
                } else {
                    print("Could not return a temperature.")
                }
                if let icon = json["currently"]["icon"].string {
                    self.currentIcon = icon
                } else {
                    print("Could not return an icon")
                }
            case .failure(let error):
                print(error)
            }
            completed()
        }
    }
}
