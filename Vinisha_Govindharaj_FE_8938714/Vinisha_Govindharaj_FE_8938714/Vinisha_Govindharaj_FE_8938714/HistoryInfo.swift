//
//  HistoryInfo.swift
//  Vinisha_Govindharaj_FE_8938714
//
//  Created by user240738 on 4/10/24.
//

import Foundation
enum InteractionSource: String {
    case home = "Home"
    case news = "News"
    case map = "Map"
    case weather = "Weather"
}

enum InteractionType: String {
    case news
    case weather
    case directions
}

struct HistoryInfo {
    var city: String
    var source: InteractionSource
    var type: InteractionType
    var content: String?
    var date: Date?
    var startLocation: String?
    var endLocation: String?
    var modeOfTravel: String?
    var distanceTraveled: String?
    var temperature: String?
    var humidity: String?
    var wind: String?
}
