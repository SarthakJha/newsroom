//
//  NewsroomAPIService.swift
//  newsroom
//
//  Created by Sarthak Jha on 16/12/22.
//

import Foundation


enum NewsroomAPIService {
    static let BaseURL:String = "https://www.newsapi.org"
    static let APIManager = NetworkManager(baseURL: BaseURL, apiKey: Secrets.APIKey)
}
