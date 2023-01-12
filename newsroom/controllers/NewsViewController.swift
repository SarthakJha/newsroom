//
//  NewsViewController.swift
//  newsroom
//
//  Created by Sarthak Jha on 12/01/23.
//

import UIKit

private let reuseIdentifier = "news-cell"

enum NewsControllerType {
    case topHeadlines
    case mapResult
    case searchResult
}

class NewsCollectionViewController: UICollectionViewController {
    private var category: String?
    private var sourceId: String?
    private var searchText: String?
    private var countryCode: String?
    
    private var controllerType: NewsControllerType?
    private var currentPage: Int = 1
    private var newsArticles: ArticleResponse? {
        didSet{
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {return}
                self.collectionView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Register cell classes
        self.collectionView!.register(HeadlineCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        guard let controllerType = controllerType else {return}
        loadInitialAPIResponse()
    }

}


private typealias CollectionViewDelegates = NewsCollectionViewController
extension CollectionViewDelegates: UICollectionViewDelegateFlowLayout {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("lol: ",newsArticles?.articles.count)
        return (newsArticles?.articles.count) ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //        if (indexPath.row == (newsArticles?.articles.count)!-1 && !didReachEnd){
        //            currentPage = currentPage! + 1
        //            NewsroomAPIService.APIManager.fetchHeadlines(category: nil, countryCode: nil,page: currentPage!) { articles, error in
        //                if let error = error{
        //                    return
        //                }
        //                self.newsArticles?.articles.append(contentsOf: articles!.articles)
        //                DispatchQueue.main.async {
        //                    self.headlineCollectionView.reloadData()
        //                }
        //                if((self.newsArticles?.articles.count)! == (self.newsArticles?.totalResults!)!){
        //                    self.didReachEnd = true
        //                }
        //            }
        //        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! HeadlineCollectionViewCell
        cell.setData(headlineText: newsArticles?.articles[indexPath.row].title, sourceText:  newsArticles?.articles[indexPath.row].source.name, backgroundImgURL: newsArticles?.articles[indexPath.row].urlToImage)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: (collectionView.frame.size.width)-20, height: 300)
        }
        
}

private typealias NewsCollectionHelpers = NewsCollectionViewController
extension NewsCollectionHelpers{
    
    private func loadInitialAPIResponse(){
        switch controllerType {
        case .topHeadlines:
            NewsroomAPIService.APIManager.fetchHeadlines(category: .entertainment, countryCode: "in", page: currentPage) { res, err in
                if let err = err{
                    return
                }else{
                    self.newsArticles = res
                }
            }
            break
        case .mapResult:
            guard let countryCode = countryCode else {return}
            NewsroomAPIService.APIManager.fetchHeadlines(category: nil, countryCode: countryCode, page: 1) { response, error in
                if let error = error{
                    return
                }
                self.newsArticles = response
            }
            break
        case .searchResult:
            guard let searchText = searchText else {return}
            NewsroomAPIService.APIManager.fetchSearchResults(searchText: searchText, sourceId: sourceId,page: currentPage) { data, error in
                if let _ = error {
                    return
                }
                guard let data = data else {return}
                self.newsArticles = data
            }
            break
        default:
            print("went wrong")
        }
    }
    
    public func setControllerType(controllerType: NewsControllerType){
        self.controllerType = controllerType
    }
    public func setSource(source: String){
        self.sourceId = source
    }
    public func setCategory(category: String){
        self.category = category
    }
    public func setSearchText(searchText: String){
        self.searchText = searchText
    }
}
