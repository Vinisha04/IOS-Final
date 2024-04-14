//
//  newsTableViewController.swift
//  Vinisha_Govindharaj_FE_8938714
//
//  Created by user240738 on 4/10/24.
//

import UIKit
import CoreLocation
// Define newsTableViewController class inheriting from UITableViewController and conforming to CLLocationManagerDelegate
class newsTableViewController: UITableViewController ,CLLocationManagerDelegate{
    // Array to hold Article instances
    var articles = [Article]()
    // Location manager to handle location-related functionalities
       let locationManager = CLLocationManager()
    // Geocoder for converting locations to readable addresses
    let geocoder = CLGeocoder()
    // Called after the controller's view is loaded into memory - setup tasks
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set this controller as delegate for location manager and request access for location services

                    locationManager.delegate = self
                    locationManager.requestWhenInUseAuthorization()
                    locationManager.startUpdatingLocation()
        // Set this view controller as the dataSource and delegate for tableView
                    self.tableView.dataSource = self
                    self.tableView.delegate = self
    }

    // Define number of sections in the table view
          override func numberOfSections(in tableView: UITableView) -> Int {
              return 1
          }
    // Define number of rows in any given section
          override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
              return articles.count
          }
    // Specify the height for rows in the tableView
    
        override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            // Return the desired height for the cells
            return 150 // Adjust this value according to your requirements
        }

    // Handle location permission changes
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        } else {
            print("Location permission not granted")
        }
    }
    // Update location handling; fetching the first received location and stopping further updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            locationManager.stopUpdatingLocation() // Stop updates after the first location
            fetchCityAndNews(for: location)
        }
    }
    // Use geocoder to reverse geocode the location and fetch news for the found city
    func fetchCityAndNews(for location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            if let placemark = placemarks?.first, let cityName = placemark.locality {
                print("Found city: \(cityName), updating news...")
                self?.fetchNewsForCity(cityName: cityName) { articles, error in
                    DispatchQueue.main.async {
                        if let articles = articles {
                            self?.articles = articles
                            self?.tableView.reloadData()
                        } else if let error = error {
                            print("Error fetching news: \(error)")
                        }
                    }
                }
            } else if let error = error {
                print("Error in reverse geocoding: \(error)")
            }
        }
    }

    // Fetches news articles for a given city using the News API
      func fetchNewsForCity(cityName: String, completion: @escaping ([Article]?, Error?) -> Void) {
          let apiKey = "0a4e4483535f47f6b5a1c2594f44a0ad"
          let urlString = "https://newsapi.org/v2/everything?q=\(cityName)&apiKey=\(apiKey)"
          guard let url = URL(string: urlString) else {
              completion(nil, NSError(domain: "Invalid URL", code: -1, userInfo: nil))
              return
          }

          // Perform the network request
          let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
              if let error = error {
                  completion(nil, error)
                  return
              }
             
              guard let data = data else {
                  completion(nil, NSError(domain: "Data not found", code: -2, userInfo: nil))
                  return
              }
             
              // Decode the JSON data into NewsInfo structure
              do {
                  let decoder = JSONDecoder()
                  let newsResponse = try decoder.decode(NewsInfo.self, from: data)
                  completion(newsResponse.articles, nil)
              } catch let parsingError {
                  completion(nil, parsingError)
              }
          }
          task.resume()
      }

    // Action triggered by UI, presenting a location input alert
    @IBAction func changeButton(_ sender: Any) {
        // Define the `alert` within the scope of this function
                   let alert = UIAlertController(title: "Where would you like to go", message: "Enter your new destination here", preferredStyle: .alert)

                   // Add a text field to the alert for the city name
                   alert.addTextField { textField in
                       textField.placeholder = "City name"
                   }
                // Your existing implementation of showing alert ...
                let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, unowned alert] _ in
                    if let cityName = alert.textFields?.first?.text, !cityName.isEmpty {
                        self?.fetchNewsForCity(cityName: cityName) { articles, error in
                            DispatchQueue.main.async {
                                if let articles = articles {
                                    self?.articles = articles
                                    self?.tableView.reloadData()
                                } else if let error = error {
                                    print("Error: \(error)")
                                    // Handle the error, perhaps show an alert to the user
                                }
                            }
                        }
                    }
                }
                alert.addAction(submitAction)
                present(alert, animated: true)
        
    }
    
    // Configure cell with article data
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           // Dequeue a reusable cell
           let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath) as! basicTableViewCell
          
           let article = articles[indexPath.row]
                   cell.titleLabel.text = article.title
           //print("description",Optional(article.description)!);
           cell.descriptionView.text = article.description;
           // cell.descriptionField.sizeToFit()
                  cell.authorLabel.text = article.author
        
                cell.sourceLabel.text = article.source.name// Assuming your Article model has these properties
              
              return cell
       }
    
}
