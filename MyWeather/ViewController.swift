//
//  ViewController.swift
//  MyWeather
//
//  Created by User on 5/25/16.
//  Copyright © 2016 TheSitePass. All rights reserved.
//

import UIKit
import CoreLocation
import AVFoundation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class ViewController: UIViewController,
    WeatherGetterDelegate, ForecastGetterDelegate, CLLocationManagerDelegate,
    UITextFieldDelegate
{
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cloudCoverLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var getLocationWeatherButton: UIButton!
    @IBOutlet weak var getCityWeatherButton: UIButton!
    @IBOutlet weak var weatherDescImage: UIImageView!
    
    @IBOutlet weak var cloudCoverIcon: UIImageView!
    @IBOutlet weak var windIcon: UIImageView!
    @IBOutlet weak var humidityIcon: UIImageView!
    
    
 
    let locationManager = CLLocationManager()
    var weather: WeatherGetter!
    var fullForecast: ForecastGetter!
    var formattedForecast = FormattedForecast()
    var day1: Daily!
    var day2: Daily!
    var day3: Daily!
    var day4: Daily!
    var day5: Daily!

    
    
    
    
    // MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        weather = WeatherGetter(delegate: self)
        fullForecast = ForecastGetter(delegate: self)
        
        // Gesture Init
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.respondToSwipeGesture(_:)))
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.respondToSwipeGesture(_:)))
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.respondToSwipeGesture(_:)))
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.respondToSwipeGesture(_:)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        self.view.addGestureRecognizer(swipeDown)
        swipeUp.direction = UISwipeGestureRecognizerDirection.up
        self.view.addGestureRecognizer(swipeUp)
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        
        
        self.view.addGestureRecognizer(swipeLeft)
        // Initialize UI
        // -------------
        cityLabel.text = "audible weather"
        weatherLabel.text = "loading..."
        temperatureLabel.text = ""
        cloudCoverLabel.text = ""
        windLabel.text = ""
        humidityLabel.text = ""
        cityTextField.text = ""
        cityTextField.placeholder = "enter city name or zip"
        cityTextField.delegate = self
        cityTextField.enablesReturnKeyAutomatically = true
        getCityWeatherButton.isEnabled = false
        
        getLocation()
        
        

    }
    
    
    // MARK: - Button events and states
    // --------------------------------
    
    @IBAction func getWeatherForLocationButtonTapped(_ sender: UIButton) {
        setWeatherButtonStates(false)
        getLocation()
    }
    
    @IBAction func getWeatherForCityButtonTapped(_ sender: UIButton) {
        guard let text = cityTextField.text, !text.trimmed.isEmpty else {
            return
        }
        setWeatherButtonStates(false)
        if Int(cityTextField.text!.urlEncoded) != nil {
            weather.getWeatherByZip(cityTextField.text!.urlEncoded)
            fullForecast.getForecastByZip(cityTextField.text!.urlEncoded)
        } else {
            weather.getWeatherByCity(cityTextField.text!.urlEncoded)
            fullForecast.getForecastByCity(cityTextField.text!.urlEncoded)
        }
    }
    
    func setWeatherButtonStates(_ state: Bool) {
        getLocationWeatherButton.isEnabled = state
        getCityWeatherButton.isEnabled = state
    }
    

    func respondToSwipeGesture(_ gesture: UIGestureRecognizer) {
        if self.day1?.day != nil {
            
            if let swipeGesture = gesture as? UISwipeGestureRecognizer {
    
                switch swipeGesture.direction {
                case UISwipeGestureRecognizerDirection.right:
                    
                    var toSpeak = ("The current temperature for \(self.cityLabel.text!) is \(self.temperatureLabel.text!), ")

                    toSpeak += ("the humidity is at \(self.humidityLabel.text!).")

                    self.speak(toSpeak)
                case UISwipeGestureRecognizerDirection.down:
                    var max = self.day1.max
                    var min = self.day1.min
                    if String(describing: self.temperatureLabel.text?.characters.dropLast()) > max {
                        max = self.temperatureLabel.text
                    }
                    if String(describing: self.temperatureLabel.text?.characters.dropLast()) < min {
                        min = self.temperatureLabel.text
                    }
                    
                    
                    var toSpeak = ("For \(self.day1.day), the high will be \(max), with a low of \(min).  ")
                    toSpeak += ("\(self.day2.day) will have a high of \(self.day2.max), and a low of \(String(self.day2.min.characters.dropLast())).  ")
                    toSpeak += ("On \(self.day3.day), expect a high of \(String(self.day3.max.characters.dropLast())), and a low of \(String(self.day3.min.characters.dropLast())).  ")
                    
                    self.speak(toSpeak)
                    
                case UISwipeGestureRecognizerDirection.left:
                    
                    let toSpeak = ("Updating weather for current location.")
                    self.speak(toSpeak)
                    setWeatherButtonStates(false)
                    getLocation()
                    
                case UISwipeGestureRecognizerDirection.up:
                    print("Swiped up")
                default:
                    break
                }
            }
        }
    }

    
    // MARK: - WeatherGetterDelegate methods
    // -----------------------------------
    
    func didGetWeather(_ weather: Weather) {
        // This method is called asynchronously, which means it won't execute in the main queue.

        DispatchQueue.main.async {
            self.cityLabel.text = weather.city
            self.weatherLabel.text = weather.weatherDescription
            self.temperatureLabel.text = "\(Int(round(weather.tempFahrenheit)))°F"
            self.cloudCoverLabel.text = "\(weather.cloudCover)%"
            self.windLabel.text = "\(weather.windSpeed) m/s"
            
            self.humidityLabel.text = "\(weather.humidity)%"
            self.getLocationWeatherButton.isEnabled = true
            self.getCityWeatherButton.isEnabled = self.cityTextField.text?.characters.count > 0
            self.weatherDescImage.image = UIImage(named: weather.weatherIconID)
        }
    }
    
    func didNotGetWeather(_ error: NSError) {
        // This method is called asynchronously, which means it won't execute in the main queue.

        DispatchQueue.main.async {
            self.showSimpleAlert(title: "Can't get the weather",
                                 message: "The weather service isn't responding.")
            self.getLocationWeatherButton.isEnabled = true
            self.getCityWeatherButton.isEnabled = self.cityTextField.text?.characters.count > 0
        }
        print("didNotGetWeather error: \(error)")
    }
    
    // MARK: - ForecastGetterDelegate methods
    // -----------------------------------
    
    func didGetForecast(_ fullForecast: Forecast) {
        // This method is called asynchronously, which means it won't execute in the main queue.

        DispatchQueue.main.async {
            
            
            self.formattedForecast.formatForecast(fullForecast)

            let DailyArray = self.getDailyMinMax(self.formattedForecast)

            self.day1 = DailyArray[0]
            self.day2 = DailyArray[1]
            self.day3 = DailyArray[2]
            self.day4 = DailyArray[3]
            self.day5 = DailyArray[4]
            
        }
    }
    
    func didNotGetForecast(_ error: NSError) {
        // This method is called asynchronously, which means it won't execute in the main queue.

        DispatchQueue.main.async {
            self.showSimpleAlert(title: "Can't get the weather",
                                 message: "The weather service isn't responding.")
            self.getLocationWeatherButton.isEnabled = true
            self.getCityWeatherButton.isEnabled = self.cityTextField.text?.characters.count > 0
        }
        print("didNotGetForecast error: \(error)")
    }
    
    // MARK: - CLLocationManagerDelegate and related methods
    
    func getLocation() {
        guard CLLocationManager.locationServicesEnabled() else {
            showSimpleAlert(
                title: "Please turn on location services",
                message: "This app needs location services in order to report the weather " +
                    "for your current location.\n" +
                "Go to Settings → Privacy → Location Services and turn location services on."
            )
            getLocationWeatherButton.isEnabled = true
            return
        }
        
        let authStatus = CLLocationManager.authorizationStatus()
        guard authStatus == .authorizedWhenInUse else {
            switch authStatus {
            case .denied, .restricted:
                let alert = UIAlertController(
                    title: "Location services for this app are disabled",
                    message: "In order to get your current location, please open Settings for this app, choose \"Location\"  and set \"Allow location access\" to \"While Using the App\".",
                    preferredStyle: .alert
                )
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                let openSettingsAction = UIAlertAction(title: "Open Settings", style: .default) {
                    action in
                    if let url = URL(string: UIApplicationOpenSettingsURLString) {
                        UIApplication.shared.openURL(url)
                    }
                }
                alert.addAction(cancelAction)
                alert.addAction(openSettingsAction)
                present(alert, animated: true, completion: nil)
                getLocationWeatherButton.isEnabled = true
                return
                
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
                
            default:
                print("Oops! Shouldn't have come this far.")
            }
            
            return
        }
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        weather.getWeatherByCoordinates(latitude: newLocation.coordinate.latitude,
                                        longitude: newLocation.coordinate.longitude)
        fullForecast.getForecastByCoordinates(latitude: newLocation.coordinate.latitude,
                                        longitude: newLocation.coordinate.longitude)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // This method is called asynchronously, which means it won't execute in the main queue.
        // All UI code needs to execute in the main queue, which is why we're wrapping the call
        // to showSimpleAlert(title:message:) in a dispatch_async() call.
        DispatchQueue.main.async {
            self.showSimpleAlert(title: "Can't determine your location",
                                 message: "The GPS and other location services aren't responding.")
        }
        print("locationManager didFailWithError: \(error)")
    }
    
    
    // MARK: - UITextFieldDelegate and related methods
    // -----------------------------------------------
    

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                                                 replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let prospectiveText = (currentText as NSString).replacingCharacters(
            in: range,
            with: string).trimmed
        getCityWeatherButton.isEnabled = prospectiveText.characters.count > 0
        return true
    }
    
    // Pressing the clear button on the text field (the x-in-a-circle button
    // on the right side of the field)
    func textFieldShouldClear(_ textField: UITextField) -> Bool {

        textField.text = ""
        
        getCityWeatherButton.isEnabled = false
        return true
    }
    
    // Pressing the return button on the keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        getWeatherForCityButtonTapped(getCityWeatherButton)
        return true
    }
    
    // Tapping on the view should dismiss the keyboard.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        animateViewMoving(false, moveValue: 205)
        toggleHideBottom(false)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        animateViewMoving(true, moveValue: 205)
        toggleHideBottom(true)
    }
    
    func animateViewMoving (_ up:Bool, moveValue :CGFloat){
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = self.view.frame.offsetBy(dx: 0,  dy: movement)
        UIView.commitAnimations()
    }
    
    // MARK: Speech Methods
    
    func speak(_ textToSpeak: String) {
        let utterance = AVSpeechUtterance(string: textToSpeak)
        //utterance.voice = self.voiceToUse
        // utterance.rate = 0.1
        
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
    
    // MARK: - Utility methods
    // -----------------------
    
    func showSimpleAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(
            title: "OK",
            style:  .default,
            handler: nil
        )
        alert.addAction(okAction)
        present(
            alert,
            animated: true,
            completion: nil
        )
    }
    
    func toggleHideBottom(_ hide: Bool) {
        
        //cloudCoverIcon.hidden = hide
        //cloudCoverLabel.hidden = hide
        //windIcon.hidden = hide
        //windLabel.hidden = hide
        //humidityIcon.hidden = hide
        //humidityLabel.hidden = hide
        // getLocationWeatherButton.hidden = hide
        weatherDescImage.isHidden = hide
    }
    
    func getDailyMinMax(_ forecast: FormattedForecast) -> [Daily] {
        
        var output = [Daily]()
        
        var previousDay = forecast.formattedForecast[0].day
        var minTemp = forecast.formattedForecast[0].low
        var maxTemp = forecast.formattedForecast[0].high
        var item: Daily!
        
        var i = 1
        
        for _ in 0...4 {
            
            while (forecast.formattedForecast[i].day) == previousDay {
            
                if forecast.formattedForecast[i].high > maxTemp {
                    maxTemp = forecast.formattedForecast[i].high
                }
            
                if forecast.formattedForecast[i].low < minTemp {
                    minTemp = forecast.formattedForecast[i].low
                }
            
                previousDay = forecast.formattedForecast[i].day
                i += 1
                
                if i == forecast.formattedForecast.count {
                    break
                }
            
            }
            item = Daily(day: previousDay, min: minTemp, max: maxTemp)
            output.append(item)
        
            if i == forecast.formattedForecast.count {
                break
            }
            previousDay = forecast.formattedForecast[i].day
            minTemp = forecast.formattedForecast[i].low
            maxTemp = forecast.formattedForecast[i].high
            
            }

        return output
        
    }
}


extension String {
    
    // Method for %-encoding strings containing spaces and other
    // characters that need to be converted for use in URLs.
    var urlEncoded: String {
        return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlUserAllowed)!
    }
    
    var trimmed: String {
        return self.trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
}
