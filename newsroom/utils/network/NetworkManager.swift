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
    fileprivate var sourceRoute = "/top-headlines/sources"
    
    init(baseURL:String, apiKey: String){
        self.baseURL = baseURL
        self.apiKey = apiKey
    }
    
    // fetch headlines
    /**
     * default category= entertainment
     */
    func fetchHeadlines(category cat: Category?, countryCode: String?,page:Int?, completion: @escaping((ArticleResponse?, Error?)-> Void)) {
        
        guard var url: URL = URL(string: baseURL!+apiVersion+topHeadlineRoute) else {return}
        var topHeadlines: ArticleResponse?
        var queryItems: [URLQueryItem] = [URLQueryItem(name: "apiKey", value: Secrets.APIKey)]
        
        if let cat = cat {
            queryItems.append(URLQueryItem(name: "category", value: cat.rawValue))
        }else{
            queryItems.append(URLQueryItem(name: "category", value: "entertainment"))
        }
        
        if let countryCode = countryCode {
            queryItems.append(URLQueryItem(name: "country", value: countryCode))
        }
        if let page = page{
            queryItems.append(URLQueryItem(name: "page", value: String(page)))
            queryItems.append(URLQueryItem(name: "pageSize", value: String(5)))
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
    
    func fetchSearchResults(searchText text: String ,sourceId: String?, page: Int?, completion: @escaping((ArticleResponse?,Error?) -> Void)){
        
        if text == "" {
            return
        }
        guard var url: URL = URL(string: baseURL!+apiVersion+topHeadlineRoute) else {return}
        var queryItems: [URLQueryItem] = [URLQueryItem(name: "apiKey", value: Secrets.APIKey)]
        queryItems.append(URLQueryItem(name: "apiKey", value: Secrets.APIKey))
        queryItems.append(URLQueryItem(name: "q", value: text))
        if let source = sourceId{
            queryItems.append(URLQueryItem(name: "sources", value: source))
        }
        if let page = page{
            queryItems.append(URLQueryItem(name: "page", value: String(page)))
            queryItems.append(URLQueryItem(name: "pageSize", value: String(5)))
        }
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
    
    func fetchSources(category: String?, completion: @escaping((Sources?, Error?)-> Void)){
        if(category == ""){
            return
        }
        guard var url: URL = URL(string: baseURL!+apiVersion+sourceRoute) else {return}
        var queryItems: [URLQueryItem] = [URLQueryItem(name: "apiKey", value: Secrets.APIKey)]
        queryItems.append(URLQueryItem(name: "apiKey", value: Secrets.APIKey))
        if let category = category{
            queryItems.append(URLQueryItem(name: "category", value: category))
        }
        
        url.append(queryItems: queryItems)

        var searchResponse: Sources?
        let dataSession = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error{
                completion(nil, error)
                return
            }
            guard let data = data else {return}

            do{
                searchResponse = try JSONDecoder().decode(Sources.self, from: data)
                if searchResponse?.status == .ok{
                    completion(searchResponse,nil)
                }else{
                    completion(nil,error)
                }
            }catch let error{
                completion(nil, error)
            }
        }
        
        dataSession.resume()
        
    }
    
}
