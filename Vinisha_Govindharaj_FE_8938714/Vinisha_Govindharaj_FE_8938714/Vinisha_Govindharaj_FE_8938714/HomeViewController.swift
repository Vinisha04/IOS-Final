//
//  HomeViewController.swift
//  Vinisha_Govindharaj_FE_8938714
//
//  Created by user240738 on 4/13/24.
//

import UIKit
import MapKit
import CoreLocation
// Define the HomeViewController class which manages the home screen's user interface
class HomeViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    // Outlets for user interface components in the storyboard
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var mapview: MKMapView!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    // API key for weather data requests
    let apiKey = "e7cd87ec7049c2fd8ca82ab7aed1868b"
    // Location manager for handling location updates
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setting the delegate of locationManager to self
                locationManager.delegate = self
                
                // Requesting permission from the user to use their location
                locationManager.requestWhenInUseAuthorization()
                
                // Setting desired accuracy for location manager
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                
                // Start updating location
                locationManager.startUpdatingLocation()
                
                // Set delegate for mapview to self and configure map settings
                mapview.delegate = self
                mapview.showsUserLocation = true // Shows the user's location on the map
                mapview.userTrackingMode = .follow // Follows the user's location
                
                // Adding a background image programmatically to the view
                let backgroundImageView = UIImageView(frame: view.bounds)
                backgroundImageView.image = UIImage(named: "homebackground")
                backgroundImageView.contentMode = .scaleAspectFill // Fill the screen while preserving aspect ratio
                view.addSubview(backgroundImageView)
                view.sendSubviewToBack(backgroundImageView) // Ensure the background is behind all other views
                
                // Setup constraints for the background image view
                backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
                    backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                    backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)])
            }
            
            // Called when the locationManager updates the location
            func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
                guard let location = locations.last else {
                    return
                }
                // Fetch weather data for the current location
                fetchWeatherData(for: location.coordinate)
            }
            
            // Called when the locationManager fails to retrieve a location
            func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
                print("Failed to get user location: \(error.localizedDescription)")
            }
             
            // Fetch weather data from the OpenWeatherMap API
            func fetchWeatherData(for coordinate: CLLocationCoordinate2D) {
                guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&appid=\(apiKey)") else {
                    return
                }
                let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
                    if let error = error {
                        print("Weather request error: \(error.localizedDescription)")
                        return
                    }
                    guard let data = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                        print("Invalid response or data")
                        return
                    }
                    // Decoding weather data
                    self?.parseWeatherData(data)
                }
                task.resume()
            }
            
            // Parse weather data using JSONDecoder
            func parseWeatherData(_ data: Data) {
                do {
                    let decoder = JSONDecoder()
                    let WeatherData = try decoder.decode(weatherData.self, from: data) // Assuming weatherData is a Codable struct
                    DispatchQueue.main.async {
                        // Update user interface with the new weather data
                        self.updateUI(with: WeatherData)
                    }
                } catch {
                    print("Error decoding weather data: \(error)")
                }
            }
            
            // Update user interface elements with fetched weather data
            func updateUI(with WeatherData: weatherData) {
                // Update temperature, humidity, and wind labels
                temperatureLabel.text = "\(Int(WeatherData.main.temp - 273.15))°C" // Convert from Kelvin to Celsius
                humidityLabel.text = "Humidity: \(WeatherData.main.humidity)%"
                windLabel.text = "Wind: \(Int(WeatherData.wind.speed)) m/s"
                
                // Get the weather icon code and fetch the corresponding image
                guard let iconCode = WeatherData.weather.first?.icon else { return }
                fetchWeatherIcon(with: iconCode) { image in
                    DispatchQueue.main.async {
                        self.weatherImageView.image = image
                    }
                }
            }
            
            // Retrieve and set weather icon image from URL
            func fetchWeatherIcon(with iconCode: String, completion: @escaping (UIImage?) -> Void) {
                let imageUrlString = "https://openweathermap.org/img/wn/\(iconCode).png"
                guard let url = URL(string: imageUrlString) else {
                    completion(nil)
                    return
                }
                let task = URLSession.shared.dataTask(with: url) { data, response, error in
                    guard let data = data, error == nil, let image = UIImage(data: data) else {
                        completion(nil)
                        return
                    }
                    // Return the fetched image
                    completion(image)
                }
                task.resume()
            }
        }
