//
//  NewsModel.swift
//  AlphaNews
//
//  Created by developer on 25.05.21.
//

import Foundation

struct NewsResponse: Codable {
    let articles: [Article]
}

struct Article: Codable {
    let title: String
    let description: String?
    let urlToImage: String?
}
