//
//  NewsInfo.swift
//  Vinisha_Govindharaj_FE_8938714
//
//  Created by user240738 on 4/10/24.
//

import Foundation
struct NewsInfo: Codable {
    let articles: [Article]
}

struct Article: Codable {
    let title: String
    let description: String?
    let author: String?
    let source: Source
    let urlToImage: String?
    let publishedAt: String
    let content: String?
}

struct Source: Codable {
    let name: String
}
