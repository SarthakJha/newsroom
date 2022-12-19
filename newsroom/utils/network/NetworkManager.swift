//
//  NetworkManager.swift
//  newsroom
//
//  Created by Sarthak Jha on 16/12/22.
//

import Foundation


final class NetworkManager {
    var baseURL: String?
    var apiKey: String?
    fileprivate var apiVersion = "/v2"
    fileprivate var topHeadlineRoute = "/top-headlines"
    
    init(baseURL:String, apiKey: String){
        self.baseURL = baseURL
        self.apiKey = apiKey
    }
    
    // fetch headlines
    func fetchHeadlines(category cat: Category?, completion: @escaping((ArticleResponse?, Error?)-> Void)) {
        guard var url: URL = URL(string: baseURL!+apiVersion+topHeadlineRoute) else {return}
        var topHeadlines: ArticleResponse?
        var queryItems: [URLQueryItem] = [URLQueryItem(name: "apiKey", value: Secrets.APIKey)]
        
        if let cat = cat {
            queryItems.append(URLQueryItem(name: "category", value: cat.rawValue))
        }
        
        url.append(queryItems: queryItems)
        print(url.absoluteString)

        let dataSession = URLSession.shared.dataTask(with: URLRequest(url: url)) { (data, response, error) in
            
            if let error = error{
                completion(nil,error)
            }
            guard let data = data else {return}
            do{
                topHeadlines = try JSONDecoder().decode(ArticleResponse.self, from: data) as ArticleResponse

                completion(topHeadlines,nil)
            } catch let error {
                completion(nil,error)
            }
        }
        dataSession.resume()
        
    }
    
    
}
