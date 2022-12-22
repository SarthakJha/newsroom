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
    fileprivate let apiVersion = "/v2"
    fileprivate let topHeadlineRoute = "/top-headlines"
    fileprivate var everythingRoute = "/everything"
    
    init(baseURL:String, apiKey: String){
        self.baseURL = baseURL
        self.apiKey = apiKey
    }
    
    // fetch headlines
    /**
     * default category= entertainment
     */
    func fetchHeadlines(category cat: Category?, countryCode: String?, completion: @escaping((ArticleResponse?, Error?)-> Void)) {
        
        guard var url: URL = URL(string: baseURL!+apiVersion+topHeadlineRoute) else {return}
        var topHeadlines: ArticleResponse?
        var queryItems: [URLQueryItem] = [URLQueryItem(name: "apiKey", value: Secrets.APIKey)]
        
        if let cat = cat {
            queryItems.append(URLQueryItem(name: "category", value: cat.rawValue))
        }else{
            queryItems.append(URLQueryItem(name: "category", value: "entertainment"))
        }
        
        if let countryCode = countryCode{
            queryItems.append(URLQueryItem(name: "country", value: countryCode))
        }
        
        url.append(queryItems: queryItems)

        let dataSession = URLSession.shared.dataTask(with: URLRequest(url: url)) { (data, response, error) in
            
            if let error = error{
                completion(nil,error)
                return
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
    
    
    // MARK :- put sources also
    
    func fetchSearchResults(searchText text: String ,Source completion: @escaping((ArticleResponse?,Error?) -> Void)){
        guard var url: URL = URL(string: baseURL!+apiVersion+topHeadlineRoute) else {return}
        var queryItems: [URLQueryItem] = [URLQueryItem(name: "apiKey", value: Secrets.APIKey)]
        queryItems.append(URLQueryItem(name: "apiKey", value: Secrets.APIKey))
        queryItems.append(URLQueryItem(name: "q", value: text))
        
        url.append(queryItems: queryItems)

        var searchResponse: ArticleResponse?
        let dataSession = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error{
                completion(nil, error)
                return
            }
            guard let data = data else {return}

            do{
                searchResponse = try JSONDecoder().decode(ArticleResponse.self, from: data)
                completion(searchResponse,nil)
            }catch let error{
                completion(nil, error)
            }
        }
        
        dataSession.resume()
    }
    
    
}
