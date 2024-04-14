//
//  WeatherViewController.swift
//  Vinisha_Govindharaj_FE_8938714
//
//  Created by user240738 on 4/8/24.
//

import UIKit
import CoreLocation
// Defines a UIViewController that handles weather data presentation.
class WeatherViewController: UIViewController, CLLocationManagerDelegate {
    // Outlets connecting storyboard UI components to code.
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var cityTextField: UITextField!
    // Action for the search button to input a city name manually.
   
    @IBAction func searchButton(_ sender: Any) {
        let alert = UIAlertController(title: "Where would you like to go", message: "Enter your new destination here", preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.placeholder = "City Name"   // Placeholder for city input.
            }
            alert.addAction(UIAlertAction(title: "Go", style: .default, handler: { [weak self, weak alert] (_) in
                // Handling user input for city name.
                if let textField = alert?.textFields?.first, let cityName = textField.text {
                    self?.fetchweatherData(forCity: cityName)
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
    }
    
    
    
    // API key for OpenWeatherMap requests.
     let apiKey = "e7cd87ec7049c2fd8ca82ab7aed1868b"
     // Location manager for accessing GPS data.
     let locationManager = CLLocationManager()

     // Called after the view controller's view is loaded into memory.
     override func viewDidLoad() {
         super.viewDidLoad()
         locationManager.delegate = self
         locationManager.requestWhenInUseAuthorization()  // Ask user for location permission.
         locationManager.startUpdatingLocation()  // Start receiving location updates.
     }

    
    
    // Fetches weather data from OpenWeatherMap API for a given city.
        func fetchweatherData(forCity cityName: String) {
            guard let urlEncodedCityName = cityName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),  // Ensure the city name is URL safe.
                  let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(urlEncodedCityName)&appid=\(apiKey)") else {
                print("Invalid city name")  // Handle situations where URL could not be formed.
                return
            }

            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print("Error: \(error!.localizedDescription)")
                    return
                }

                guard let data = data else {
                    return  // Guard against nil data.
                }
                // Parse the returned data.
                self.parseWeatherData(data)
            }
            task.resume()  // Start the URL session task.
        }

        // CLLocationManagerDelegate method to handle location update.
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let location = locations.last else {  // Get the most recent location.
                return
            }
            locationManager.stopUpdatingLocation()  // Stop updating location to save battery.
            fetchWeatherData(for: location.coordinate)  // Fetch weather data for the current location.
        }

        // Error handling for location manager.
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("Failed to get location: \(error)")
        }

        // Fetches weather data for specific coordinates.
        func fetchWeatherData(for coordinate: CLLocationCoordinate2D) {
            guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&exclude=hourly,daily&appid=\(apiKey)") else {
                return
            }

            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print("Error: \(error!.localizedDescription)")
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data else {
                    print("Invalid response or data")
                    return  // Guard against invalid HTTP responses and nil data.
                }

                // Parse the weather data.
                self.parseWeatherData(data)
            }
            task.resume()
        }

        // Decodes JSON data into usable models.
        func parseWeatherData(_ data: Data) {
            do {
                let weatherData = try JSONDecoder().decode(weatherData.self, from: data)
                updateUI(with: weatherData)  // Update the UI with parsed data.
            } catch {
                print("Error decoding weather data: \(error)")
            }
        }

        // Updates the UI elements with the data received.
        func updateUI(with weatherData: weatherData) {
            DispatchQueue.main.async {  // Ensure UI updates are on main thread.
                self.cityTextField.text = weatherData.name
                self.locationLabel.text = weatherData.name
                self.descriptionLabel.text = weatherData.weather.first?.description
                self.weatherImageView.image = UIImage(named: weatherData.weather.first?.icon ?? "")
                let temperatureInCelsius = weatherData.main.temp - 273.15
                self.temperatureLabel.text = "\(Int(temperatureInCelsius))°C"
                self.humidityLabel.text = "Humidity: \(weatherData.main.humidity)%"
                self.windLabel.text = "Wind: \(Int(weatherData.wind.speed)) m/s"

                // Fetch the icon if available.
                if let weatherIconCode = weatherData.weather.first?.icon {
                    self.fetchWeatherIcon(with: weatherIconCode) { image in
                        DispatchQueue.main.async {
                            self.weatherImageView.image = image  // Update weather icon.
                        }
                    }
                }
            }
        }

        // Fetches weather icon from OpenWeatherMap based on icon code.
        func fetchWeatherIcon(with iconCode: String, completion: @escaping (UIImage?) -> Void) {
            let imageUrlString = "https://api.openweathermap.org/img/w/\(iconCode).png"
            guard let url = URL(string: imageUrlString) else {
                completion(nil)
                return
            }

            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard
                    let httpURLResponse = response as? HTTPURLResponse,
                    httpURLResponse.statusCode == 200,  // Check for HTTP success.
                    let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                    let data = data, error == nil,
                    let image = UIImage(data: data)  // Construct image from data.
                else {
                    completion(nil)
                    return
                }

                completion(image)  // Complete with image.
            }

            task.resume()  // Start the task.
        }
    }
