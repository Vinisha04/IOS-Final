//
//  weatherData.swift
//  Vinisha_Govindharaj_FE_8938714
//
//  Created by user240738 on 4/8/24.
//

import Foundation
import Foundation
struct weatherData: Codable {
    let name: String
    let weather: [Weather]
    let main: Main
    let wind: Wind
}

struct Weather: Codable {
    let description: String
    let icon: String
}

struct Main: Codable {
    let temp: Double
    let humidity: Int
}

struct Wind: Codable {
    let speed: Double
}
