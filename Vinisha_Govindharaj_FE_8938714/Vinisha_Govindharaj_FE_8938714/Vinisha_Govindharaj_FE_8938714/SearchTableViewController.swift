//
//  SearchTableViewController.swift
//  Vinisha_Govindharaj_FE_8938714
//
//  Created by user240738 on 4/10/24.
//

import UIKit

class SearchTableViewController: UITableViewController {

    
        var historyItems = [HistoryInfo]() // History items to be displayed
           
           override func viewDidLoad() {
               super.viewDidLoad()
               self.tableView.dataSource = self
               self.tableView.delegate = self
               preloadData()  // Preloading data function
           }
           
           override func numberOfSections(in tableView: UITableView) -> Int {
               return 1
           }

           override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
               return historyItems.count
           }
           
           override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
               let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath)
               
               let item = historyItems[indexPath.row]
               var contentText = ""
               
               switch item.type {
               case .news:
                   contentText = "News: \(item.content ?? "N/A")"
               case .weather:
                   let dateText = item.date?.formatted(date: .abbreviated, time: .shortened) ?? "N/A"
                   contentText = "Weather on \(dateText): Temp \(item.temperature ?? "N/A"), Humidity: \(item.humidity ?? "N/A"), Wind \(item.wind ?? "N/A")"
               case .directions:
                   contentText = "From: \(item.startLocation ?? "N/A") to \(item.endLocation ?? "N/A"). Travel by \(item.modeOfTravel ?? "N/A"), Distance: \(item.distanceTraveled ?? "N/A")"
               }
               
               cell.textLabel?.text = contentText
               cell.detailTextLabel?.text = "City: \(item.city), Source: \(item.source.rawValue)"
               
               return cell
           }

           // Preload data function
           func preloadData() {
               historyItems.append(HistoryInfo(city: "Toronto", source: .home, type: .news, content: "Mayor reveals new city plan"))
               historyItems.append(HistoryInfo(city: "Vancouver", source: .home, type: .weather, date: Date(), temperature: "15°C", humidity: "78%", wind: "5 km/h"))
               historyItems.append(HistoryInfo(city: "Calgary", source: .map, type: .directions, date: Date(), startLocation: "City Center", endLocation: "Parkside", modeOfTravel: "Car", distanceTraveled: "12 km"))
               // Add more predefined items similar to above
           }

           // Deletion of rows
           override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
               if editingStyle == .delete {
                   historyItems.remove(at: indexPath.row)
                   tableView.deleteRows(at: [indexPath], with: .automatic)
               }
           }
    }


