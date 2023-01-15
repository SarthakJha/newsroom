//
//  NewsViewController.swift
//  newsroom
//
//  Created by Sarthak Jha on 12/01/23.
//

import UIKit
import Lottie

private let reuseIdentifier = "news-cell"

protocol ViewModelDelegate {
    func reloadCollectionview()
    func stopRefreshing()
    func startRefreshing()
}

class NewsViewController: UICollectionViewController {
    
    private var category: String?
    private var sourceId: String?
    private var searchText: String?
    private var countryCode: String?
    private var refreshController: UIRefreshControl = {
        var rc = UIRefreshControl()
        return rc
    }()
    public var loadingAnimation: LottieAnimationView! = {
        var loadingAnimationView = LottieAnimationView.init(name: "loading")
        loadingAnimationView.translatesAutoresizingMaskIntoConstraints = false
        loadingAnimationView.contentMode = .scaleAspectFit
        loadingAnimationView.loopMode = .loop
        loadingAnimationView.animationSpeed = 1
        loadingAnimationView.alpha = 0
        return loadingAnimationView
    }()

    private var newsViewModel: NewsViewmodel?
    
    private var controllerType: NewsControllerType?
        
    override func viewDidLoad() {
        
        super.viewDidLoad()
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.refreshControl = refreshController
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Register cell classes
        self.collectionView!.register(HeadlineCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        guard let controllerType = controllerType else {return}
        newsViewModel = NewsViewmodel(screenType: controllerType)
        newsViewModel?.delegate = self
        newsViewModel?.getResponses()
        
        refreshController.addTarget(self, action: #selector(didEnableRefreshing), for: .valueChanged)
    }
    
    public func setControllerType(controllerType: NewsControllerType){
        self.controllerType = controllerType
    }
    
    @objc private func didEnableRefreshing(){
        newsViewModel?.resetCurrentPage()
        newsViewModel?.getResponses()
    }
}


private typealias CollectionViewDelegates = NewsViewController
extension CollectionViewDelegates: UICollectionViewDelegateFlowLayout {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let newsViewModel = newsViewModel{
            return newsViewModel.newsCount
        } else {
            return 0
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if (indexPath.row == (newsViewModel?.newsCount)!-1) {
            newsViewModel?.getResponses()
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! HeadlineCollectionViewCell
        cell.setDataNew(article: (newsViewModel?.getArticleForIndexPath(indexPath: indexPath))!)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: (collectionView.frame.size.width)-20, height: 300)
        }
        
}

//private typealias NewsCollectionHelpers = NewsViewController
//extension NewsCollectionHelpers{
//
//    private func loadInitialAPIResponse(){
//        switch controllerType {
//        case .topHeadlines:
//            NewsroomAPIService.APIManager.fetchHeadlines(category: .entertainment, countryCode: "in", page: currentPage) { res, err in
//                if let err = err{
//                    return
//                }else{
//                    self.newsArticles = res
//                }
//            }
//            break
//        case .mapResult:
//            guard let countryCode = countryCode else {return}
//            NewsroomAPIService.APIManager.fetchHeadlines(category: nil, countryCode: countryCode, page: 1) { response, error in
//                if let error = error{
//                    return
//                }
//                self.newsArticles = response
//            }
//            break
//        case .searchResult:
//            guard let searchText = searchText else {return}
//            NewsroomAPIService.APIManager.fetchSearchResults(searchText: searchText, sourceId: sourceId,page: currentPage) { data, error in
//                if let _ = error {
//                    return
//                }
//                guard let data = data else {return}
//                self.newsArticles = data
//            }
//            break
//        default:
//            print("went wrong")
//        }
//    }
//    public func setSource(source: String){
//        self.sourceId = source
//    }
//    public func setCategory(category: String){
//        self.category = category
//    }
//    public func setSearchText(searchText: String){
//        self.searchText = searchText
//    }
//}

private typealias NewsViewmodelExtension = NewsViewController
extension NewsViewmodelExtension: ViewModelDelegate {
    
    func startRefreshing() {
        DispatchQueue.main.async {
            self.loadingAnimation.play()
            self.loadingAnimation.alpha = 1
            self.collectionView.alpha = 0
        }
    }
    
    func reloadCollectionview() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.collectionView.alpha = 0
        }
    }
    
    func stopRefreshing() {
        DispatchQueue.main.async {
            self.loadingAnimation.stop()
            self.loadingAnimation.alpha = 0
            self.collectionView.alpha = 1
            self.refreshController.endRefreshing()
        }
    }
}
