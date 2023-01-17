//
//  NewsViewController.swift
//  newsroom
//
//  Created by Sarthak Jha on 12/01/23.
//

import UIKit
import Lottie

private let reuseIdentifier = "news-cell"

public protocol ViewModelDelegate {
    func reloadCollectionview()
    func stopRefreshing()
    func startRefreshing()
    func handleNotFound()
}

public protocol NewsViewControllerDelegate {
    func pushWebView(_ viewController: UIViewController)
}

class NewsViewController: UICollectionViewController {
    
    private var category: String?
    private var sourceId: String? {
        didSet{
            newsViewModel?.sourceId = sourceId
            if searchText != nil {
                newsViewModel?.resetCurrentPage()
                newsViewModel?.getResponses()
            }
        }
    }
    private var searchText: String? {
        didSet {
            newsViewModel?.searchText = searchText
            if sourceId != nil {
                newsViewModel?.resetCurrentPage()
                newsViewModel?.getResponses()
            }
        }
    }
    private var countryCode: String?
    private var refreshController: UIRefreshControl = {
        var rc = UIRefreshControl()
        return rc
    }()
    public var delegate: NewsViewControllerDelegate?
    public var loadingAnimation: LottieAnimationView = {
        var loadingAnimationView = LottieAnimationView.init(name: "loading")
        loadingAnimationView.translatesAutoresizingMaskIntoConstraints = false
        loadingAnimationView.contentMode = .scaleAspectFit
        loadingAnimationView.loopMode = .loop
        loadingAnimationView.animationSpeed = 1
        loadingAnimationView.alpha = 0
        return loadingAnimationView
    }()
    public var notFoundAnimation: LottieAnimationView = {
        var notFoundAnimation = LottieAnimationView.init(name: "notfoundresults")
        notFoundAnimation.translatesAutoresizingMaskIntoConstraints = false
        notFoundAnimation.contentMode = .scaleAspectFit
        notFoundAnimation.loopMode = .loop
        notFoundAnimation.animationSpeed = 1
        notFoundAnimation.alpha = 0
        return notFoundAnimation
    }()
    private var newsWebViewController: NewsWebViewController = NewsWebViewController()

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
        newsViewModel = NewsViewmodel(screenType: controllerType, countryCode: countryCode)
        newsViewModel?.delegate = self
        if(controllerType != .searchResult){
            newsViewModel?.getResponses()
        }
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
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let urlString = newsViewModel?.getArticleForIndexPath(indexPath: indexPath)?.url
        if let urlString = urlString {
            let url = URL(string: urlString)
            newsWebViewController.url = url
            delegate?.pushWebView(newsWebViewController)
        }
    }
}

private typealias NewsCollectionHelpers = NewsViewController
extension NewsCollectionHelpers{

    public func setCountryCode(countryCode: String){
        self.countryCode = countryCode
    }
    public func setCategory(category: String){
        self.category = category
    }
    public func setSearchText(searchText: String){
        self.searchText = searchText
    }
    public func setSourceId(sourceId: String){
        self.sourceId = sourceId
    }
}

private typealias NewsViewmodelExtension = NewsViewController
extension NewsViewmodelExtension: ViewModelDelegate {
    
    func handleNotFound() {
        DispatchQueue.main.async {
            self.loadingAnimation.alpha = 0
            self.notFoundAnimation.play()
            self.notFoundAnimation.alpha = 1
            self.collectionView.alpha = 0
        }
    }
    
    func startRefreshing() {
        DispatchQueue.main.async {
            self.loadingAnimation.play()
            self.loadingAnimation.alpha = 1
            self.collectionView.alpha = 0.5
            self.notFoundAnimation.alpha = 0
        }
    }
    
    func reloadCollectionview() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
//            self.collectionView.alpha = 0
        }
    }
    
    func stopRefreshing() {
        DispatchQueue.main.async {
            self.loadingAnimation.stop()
            self.loadingAnimation.alpha = 0
            self.notFoundAnimation.alpha = 0
            self.collectionView.alpha = 1
            self.refreshController.endRefreshing()
        }
    }
}
