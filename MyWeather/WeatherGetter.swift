//
//  WeatherGetter.swift
//  MyWeather
//
//  Created by User on 5/25/16.
//  Copyright © 2016 TheSitePass. All rights reserved.
//

import Foundation

protocol WeatherGetterDelegate {
    func didGetWeather(_ weather: Weather)
    func didNotGetWeather(_ error: NSError)
}


// MARK: WeatherGetter
// ===================

class WeatherGetter {
    
    fileprivate let openWeatherMapBaseURL = "http://api.openweathermap.org/data/2.5/weather"
    fileprivate let openWeatherMapAPIKey = "2ff20d90017ebb3dc6c11d402ff5b949"
    
    fileprivate var delegate: WeatherGetterDelegate
    
    
    // MARK: -
    
    init(delegate: WeatherGetterDelegate) {
        self.delegate = delegate
    }
    
    func getWeatherByCity(_ city: String) {
        let weatherRequestURL = URL(string: "\(openWeatherMapBaseURL)?APPID=\(openWeatherMapAPIKey)&q=\(city)")!
        getWeather(weatherRequestURL)
    }
    
    func getWeatherByCoordinates(latitude: Double, longitude: Double) {
        let weatherRequestURL = URL(string: "\(openWeatherMapBaseURL)?APPID=\(openWeatherMapAPIKey)&lat=\(latitude)&lon=\(longitude)")!
        getWeather(weatherRequestURL)
    }
    
    func getWeatherByZip(_ zip: String) {
        let weatherRequestURL = URL(string: "\(openWeatherMapBaseURL)?APPID=\(openWeatherMapAPIKey)&zip=\(zip),us")!
        getWeather(weatherRequestURL)
    }
    
    fileprivate func getWeather(_ weatherRequestURL: URL) {
        
        let session = URLSession.shared
        session.configuration.timeoutIntervalForRequest = 3
        
        // The data task retrieves the data.
        let dataTask = session.dataTask(with: weatherRequestURL, completionHandler: {
            (data: Data?, response: URLResponse?, error: NSError?) in
            if let networkError = error {
                // Case 1: Error
                // An error occurred while trying to get data from the server.
                self.delegate.didNotGetWeather(networkError)
            }
            else {
                // Case 2: Success
                // We got data from the server!
                do {
                    // Try to convert that data into a Swift dictionary
                    let weatherData = try JSONSerialization.jsonObject(
                        with: data!,
                        options: .mutableContainers) as! [String: AnyObject]
                    
                    // If we made it to this point, we've successfully converted the
                    // JSON-formatted weather data into a Swift dictionary.
                    // Use that dictionary to initialize a Weather struct.
                    let weather = Weather(weatherData: weatherData)
                    
                    // Now that we have the Weather struct, let's notify the view controller,
                    // which will use it to display the weather to the user.
                    self.delegate.didGetWeather(weather)
                }
                catch let jsonError as NSError {
                    // An error occurred while trying to convert the data into a Swift dictionary.
                    self.delegate.didNotGetWeather(jsonError)
                }
            }
        }) 
        
        // The data task is set up...launch it!
        dataTask.resume()
    }
    
}
