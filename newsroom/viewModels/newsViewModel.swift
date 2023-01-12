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

final class NewsViewmodel {
    
    private let service = NewsroomAPIService.APIManager
    private var newsArticles: ArticleResponse?{
        didSet{
            delegate?.reloadCollectionview()
        }
    }
    private var category: String? = "general"
    private var screenType: NewsControllerType?
    private var currentPage: Int = 1
    private var isEndReached: Bool = false
    
    public var delegate: ViewModelDelegate?
    
    public var newsCount: Int {
        get{
            return newsArticles?.articles.count ?? 0
        }
    }
    
    init(screenType: NewsControllerType) {
        self.screenType = screenType
    }
    
    public func getArticleForIndexPath(indexPath: IndexPath)->Article?{
        return newsArticles?.articles[indexPath.row]
    }
    
    public func getResponses(){
        if (!isEndReached){
            switch screenType{
            case .topHeadlines:
                service.fetchHeadlines(category: .general, countryCode: "in", page: currentPage) { res, err in
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
                break
            default:
                print("lol")
            }
        }
    }
    
}
