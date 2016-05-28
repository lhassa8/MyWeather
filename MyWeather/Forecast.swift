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
        
        print(forecastData["list"]![2])
        for index in 0..<36 {
            let temp = forecastData["list"]![index]["main"]!!["temp"] as! Double
            let time = forecastData["list"]![index]["dt"] as! NSTimeInterval
            let desc = forecastData["list"]![index]["weather"]!![0]["description"] as! String
            let icon = forecastData["list"]![index]["weather"]!![0]["icon"] as! String
            
            let item = ForecastItem(time: time, temp: temp, icon: icon, desc: desc)
            forecast.append(item)
            
            // print("Temp: \(temp), Time: \(time), Desc: \(desc), Icon: \(icon)")
        }
        
        //print(forecast)
        
        
        
        /*
        dateAndTime = NSDate(timeIntervalSince1970: weatherData["dt"] as! NSTimeInterval)
        city = weatherData["name"] as! String
        
        let coordDict = weatherData["coord"] as! [String: AnyObject]
        longitude = coordDict["lon"] as! Double
        latitude = coordDict["lat"] as! Double
        
        let weatherDict = weatherData["weather"]![0] as! [String: AnyObject]
        weatherID = weatherDict["id"] as! Int
        mainWeather = weatherDict["main"] as! String
        weatherDescription = weatherDict["description"] as! String
        weatherIconID = weatherDict["icon"] as! String
        
        let mainDict = weatherData["main"] as! [String: AnyObject]
        temp = mainDict["temp"] as! Double
        humidity = mainDict["humidity"] as! Int
        pressure = mainDict["pressure"] as! Int
        
        cloudCover = weatherData["clouds"]!["all"] as! Int
        
        let windDict = weatherData["wind"] as! [String: AnyObject]
        windSpeed = windDict["speed"] as! Double
        windDirection = windDict["deg"] as? Double
        
        if weatherData["rain"] != nil {
            let rainDict = weatherData["rain"] as! [String: AnyObject]
            rainfallInLast3Hours = rainDict["3h"] as? Double
        }
        else {
            rainfallInLast3Hours = nil
        }
        
        let sysDict = weatherData["sys"] as! [String: AnyObject]
        country = sysDict["country"] as! String
        sunrise = NSDate(timeIntervalSince1970: sysDict["sunrise"] as! NSTimeInterval)
        sunset = NSDate(timeIntervalSince1970:sysDict["sunset"] as! NSTimeInterval)
 */
    }

    
    
}


struct ForecastItem {
    private var _time: NSDate
    private var _temperature: Double
    private var _icon: String
    private var _description: String
    
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
    
    var time: NSDate {
        get {
            return _time
        }
    }
    
    var temp: Double {
        get {
            return _temperature
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
    
    init (time: AnyObject, temp: AnyObject, icon: String, desc: String) {
        self._time = NSDate(timeIntervalSince1970: time as! NSTimeInterval)
        self._temperature = temp as! Double
        self._icon = icon
        self._description = desc
        
    }
    

    
}
