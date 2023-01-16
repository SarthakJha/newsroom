//
//  newsViewModel.swift
//  newsroom
//
//  Created by Sarthak Jha on 12/01/23.
//

import Foundation

public enum NewsControllerType {
    case topHeadlines
    case mapResult
    case searchResult
}

public class NewsViewmodel {
    
    private let service = NewsroomAPIService.APIManager
    private var newsArticles: ArticleResponse?{
        didSet{
            
            guard let totalResults = newsArticles?.totalResults else {return}
            if totalResults > 0 {
                delegate?.reloadCollectionview()
                delegate?.stopRefreshing()
            } else {
                delegate?.handleNotFound()
            }
            
        }
    }
    private var category: String? = "general"
    private var screenType: NewsControllerType?
    private var currentPage: Int = 1
    private var isEndReached: Bool = false
    public var countryCode: String?

    
    public var delegate: ViewModelDelegate?
    
    public var newsCount: Int {
        get{
            return newsArticles?.articles.count ?? 0
        }
    }
    
    init(screenType: NewsControllerType, countryCode: String? = "in", delegate: ViewModelDelegate? = nil, newsArticles: ArticleResponse? = nil) {
        self.screenType = screenType
        self.countryCode = countryCode
    }
    
    public func resetCurrentPage(){
        currentPage = 1
    }
    
    public func getArticleForIndexPath(indexPath: IndexPath)->Article? {
        return newsArticles?.articles[indexPath.row]
    }
    
    public func getResponses(){
        if (!isEndReached){
            delegate?.startRefreshing()
            switch screenType{
            case .topHeadlines:
                service.fetchHeadlines(category: .general, countryCode: countryCode, page: currentPage) { res, err in
                    if let err = err {
                        print("error")
                        return
                    }
                    guard let res = res else {return}
                    
                    if var newsArticles = self.newsArticles{
                        newsArticles.articles.append(contentsOf: res.articles)
                        if(newsArticles.articles.count == newsArticles.totalResults!){
                            self.isEndReached = true
                        }
                        self.newsArticles = newsArticles
                    }else{
                        self.newsArticles = res
                    }
                    self.currentPage += 1
                }
//                break
                
            case .mapResult:
                guard let countryCode = countryCode else {return}
                service.fetchHeadlines(category: .general, countryCode: countryCode, page: currentPage) { res, err in
                    if let err = err {
                        print("error")
                        return
                    }
                    guard let res = res else {return}
                    
                    if var newsArticles = self.newsArticles{
                        newsArticles.articles.append(contentsOf: res.articles)
                        if(newsArticles.articles.count == newsArticles.totalResults!){
                            self.isEndReached = true
                        }
                        self.newsArticles = newsArticles
                    }else{
                        self.newsArticles = res
                    }
                    self.currentPage += 1
                }
            default:
                print("lol")
            }
        }
    }
    
}
