//
//  FormattedForecast.swift
//  MyWeather
//
//  Created by User on 5/31/16.
//  Copyright © 2016 TheSitePass. All rights reserved.
//

import Foundation

struct FormattedForecast {
    
    var formattedForecast = [FormattedForecastItem]()
    
    init() {
    }
    
    mutating func formatForecast(_ forecast: Forecast) {
        
        for i in 0..<forecast.forecast.count {
            
            let time = forecast.forecast[i].time
            let high = forecast.forecast[i].highFar
            let low = forecast.forecast[i].lowFar
            
            let item = FormattedForecastItem(time: time, high: high, low: low)
            self.formattedForecast.append(item)
            
        }
        
    }
    
}


struct FormattedForecastItem {
    fileprivate var _time: Date
    fileprivate var _high: String
    fileprivate var _low: String
    fileprivate var _day: String
    
    var high: String {
        get {
            return _high
        }
    }
    
    var low: String {
        get {
            return _low
        }
    }
    
    var day: String {
        get {
            return _day
        }
    }
    
    
    init (time: Date, high: Double, low: Double) {
        self._time = time
        self._high = String(format:"%.0f", high) + "°"
        self._low = String(format:"%.0f", low) + "°"
        let df  = DateFormatter()
        df.dateFormat = "EEEE"
        self._day = df.string(from: _time);
    }
}
