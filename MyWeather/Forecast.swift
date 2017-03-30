//
//  Forecast.swift
//  MyWeather
//
//  Created by User on 5/25/16.
//  Copyright © 2016 TheSitePass. All rights reserved.
//

import Foundation

struct Forecast {
    
    var forecast = [ForecastItem]()
    
    init(forecastData: [String: AnyObject]) {
        

        for index in 0..<36 {
            let temp = forecastData["list"]![index]["main"]!!["temp"] as! Double
            let high = forecastData["list"]![index]["main"]!!["temp_max"] as! Double
            let low = forecastData["list"]![index]["main"]!!["temp_min"] as! Double
            let time = forecastData["list"]![index]["dt"] as! TimeInterval
            let desc = forecastData["list"]![index]["weather"]!![0]["description"] as! String
            let icon = forecastData["list"]![index]["weather"]!![0]["icon"] as! String
            
            let item = ForecastItem(time: time, temp: temp, high: high, low: low, icon: icon, desc: desc)
            forecast.append(item)
            
        }
        
    }

}

struct ForecastItem {
    fileprivate var _time: Date
    fileprivate var _temperature: Double
    fileprivate var _high: Double
    fileprivate var _low: Double
    fileprivate var _icon: String
    fileprivate var _description: String
    
    var tempCelsius: Double {
        get {
            return _temperature - 273.15
        }
    }
    var tempFahrenheit: Double {
        get {
            return (_temperature - 273.15) * 1.8 + 32
        }
    }
    
    var time: Date {
        get {
            return _time
        }
    }
    
    var temp: Double {
        get {
            return _temperature
        }
    }
    
    var highFar: Double {
        get {
            return (_high - 273.15) * 1.8 + 32
        }
    }
    
    var highCel: Double {
        get {
            return _high - 273.15
        }
    }
    
    var lowFar: Double {
        get {
            return (_low - 273.15) * 1.8 + 32
        }
    }
    
    var lowCel: Double {
        get {
            return _low - 273.15
        }
    }
    
    var icon: String {
        get {
            return _icon
        }
    }
    
    var desc: String {
        get {
            return _description
        }
    }
    
    init (time: AnyObject, temp: AnyObject, high: AnyObject, low: AnyObject, icon: String, desc: String) {
        self._time = Date(timeIntervalSince1970: time as! TimeInterval)
        self._temperature = temp as! Double
        self._high = high as! Double
        self._low = low as! Double
        self._icon = icon
        self._description = desc
        
    }
    
}
