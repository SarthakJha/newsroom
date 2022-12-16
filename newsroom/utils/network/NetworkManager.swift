//
//  NetworkManager.swift
//  newsroom
//
//  Created by Sarthak Jha on 16/12/22.
//

import Foundation


final class NetworkManager {
    var baseURL: URL?
    var apiKey: String?
    
    init(baseURL:String, apiKey: String){
        self.baseURL = URL(string: baseURL)
        self.apiKey = apiKey
    }
}
