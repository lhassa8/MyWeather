//
//  WeatherGetter.swift
//  MyWeather
//
//  Created by User on 5/25/16.
//  Copyright © 2016 TheSitePass. All rights reserved.
//

import Foundation

protocol ForecastGetterDelegate {
    func didGetForecast(forecast: Forecast)
    func didNotGetForecast(error: NSError)
}


// MARK: Forecast
// ===================

class ForecastGetter {
    
    private let openWeatherMapBaseURL = "http://api.openweathermap.org/data/2.5/"
    private let openWeatherMapAPIKey = "2ff20d90017ebb3dc6c11d402ff5b949"
    
    private var delegate: ForecastGetterDelegate
    
    
    // MARK: -
    
    init(delegate: ForecastGetterDelegate) {
        self.delegate = delegate
    }
    
   
    func getForecastByCity(city: String) {
        let weatherRequestURL = NSURL(string: "\(openWeatherMapBaseURL)forecast?APPID=\(openWeatherMapAPIKey)&q=\(city)")!
        getForecast(weatherRequestURL)
    }
    
    func getForecastByCoordinates(latitude latitude: Double, longitude: Double) {
        let weatherRequestURL = NSURL(string: "\(openWeatherMapBaseURL)forecast?APPID=\(openWeatherMapAPIKey)&lat=\(latitude)&lon=\(longitude)")!
        getForecast(weatherRequestURL)
    }
    
    func getForecastByZip(zip: String) {
        let weatherRequestURL = NSURL(string: "\(openWeatherMapBaseURL)forecast?APPID=\(openWeatherMapAPIKey)&zip=\(zip),us")!
        getForecast(weatherRequestURL)
    }
    
    private func getForecast(weatherRequestURL: NSURL) {
        
        // This is a pretty simple networking task, so the shared session will do.
        let session = NSURLSession.sharedSession()
        session.configuration.timeoutIntervalForRequest = 3
        
        // The data task retrieves the data.
        let dataTask = session.dataTaskWithURL(weatherRequestURL) {
            (data: NSData?, response: NSURLResponse?, error: NSError?) in
            if let networkError = error {
                // Case 1: Error
                // An error occurred while trying to get data from the server.
                self.delegate.didNotGetForecast(networkError)
            }
            else {
                // Case 2: Success
                // We got data from the server!
                do {
                    //print(data)
                    // Try to convert that data into a Swift dictionary
                    let forecastData = try NSJSONSerialization.JSONObjectWithData(
                        data!,
                        options: .MutableContainers) as! [String: AnyObject]
                    
                    // If we made it to this point, we've successfully converted the
                    // JSON-formatted weather data into a Swift dictionary.
                    // Let's now used that dictionary to initialize a Weather struct.
                    
                    
                    let forecast = Forecast(forecastData: forecastData)
                    
                    // Now that we have the Weather struct, let's notify the view controller,
                    // which will use it to display the weather to the user.
                    self.delegate.didGetForecast(forecast)
                }
                catch let jsonError as NSError {
                    // An error occurred while trying to convert the data into a Swift dictionary.
                    print("forecast error")
                    self.delegate.didNotGetForecast(jsonError)
                }
            }
        }
        
        // The data task is set up...launch it!
        dataTask.resume()
    }
    
    
}
