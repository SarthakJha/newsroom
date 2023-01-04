//
//  HeadlineViewController.swift
//  newsroom
//
//  Created by Sarthak Jha on 16/12/22.
//

import UIKit
import Toast
import Lottie

class HeadlineViewController: UIViewController {
    /**
     Allow user to filter the headline results based on category
     */
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(style: .large)
    var headlineCollectionView: UICollectionView!
    var loadingAnimationView: LottieAnimationView!
    var newsWebViewController: NewsWebViewController!
    var currentPage: Int?
    var didReachEnd: Bool = false
    var refreshController: UIRefreshControl = UIRefreshControl()
    var topHeadlineData: ArticleResponse? {
        didSet{
            DispatchQueue.main.async {[self] in
                
                headlineCollectionView.isHidden = false
                headlineCollectionView.reloadData()
                loadingAnimationView.stop()
                loadingAnimationView.isHidden = true
                refreshController.endRefreshing()
            }
        }
    }
    
    @objc func refreshScreen(){
        currentPage = 1
        NewsroomAPIService.APIManager.fetchHeadlines(category: .general, countryCode: "in", page: currentPage!) { res, err in
            if let err = err{
                let configuration = ToastConfiguration(
                    autoHide: true,
                    enablePanToClose: true,
                    displayTime: 3,
                    animationTime: 0.2
                )
                let toast = Toast.default(image: nil, title: String(localized: "TOAST_NOT_FOUND_TITLE"), subtitle: String(localized: "TOAST_UKNOWN_LOCATION_DESCRIPTION"),configuration: configuration)
                DispatchQueue.main.async {
                    toast.show(haptic: .warning)
                    self.refreshController.endRefreshing()
                }
                return
            }else{
                self.topHeadlineData = res
                if((self.topHeadlineData?.articles.count)! == (self.topHeadlineData?.totalResults!)!){
                    self.didReachEnd = true
                }
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
     
        currentPage = 1
        view.backgroundColor = .white
        loadingAnimationView = .init(name: "loading")
        loadingAnimationView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        loadingAnimationView.translatesAutoresizingMaskIntoConstraints = false
        
        newsWebViewController = NewsWebViewController()
        view.addSubview(activityIndicator)
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 20
        headlineCollectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        view.addSubview(loadingAnimationView)
        view.addSubview(headlineCollectionView)
        if #available(iOS 10.0, *){
            headlineCollectionView.refreshControl = refreshController
        }else{
            view.addSubview(refreshController)
        }
        
        refreshController.addTarget(self, action: #selector(refreshScreen), for: .valueChanged)
        headlineCollectionView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.center = view.center
        activityIndicator.backgroundColor = .red
        self.headlineCollectionView.delegate = self
        self.headlineCollectionView.dataSource = self
        self.headlineCollectionView.register(HeadlineCollectionViewCell.self, forCellWithReuseIdentifier: "headline-cell")
        self.headlineCollectionView.register(CollectionHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        self.headlineCollectionView.alwaysBounceVertical = true
        self.headlineCollectionView.backgroundColor = .white
        addConstraints()

        let countryCode = UserDefaults.standard.string(forKey: "country-code")
        DispatchQueue.main.async {
            self.loadingAnimationView.isHidden = false
            self.headlineCollectionView.isHidden = true
            self.loadingAnimationView.play()
        }
        NewsroomAPIService.APIManager.fetchHeadlines(category: .entertainment, countryCode: "in", page: currentPage!) { res, err in
            if let err = err{
                let configuration = ToastConfiguration(
                    autoHide: true,
                    enablePanToClose: true,
                    displayTime: 3,
                    animationTime: 0.2
                )
                let toast = Toast.default(image: nil, title: String(localized: "TOAST_NOT_FOUND_TITLE"), subtitle: String(localized: "TOAST_UKNOWN_LOCATION_DESCRIPTION"),configuration: configuration)
                DispatchQueue.main.async {
                    toast.show(haptic: .warning)
                }
                return
            }else{
                self.topHeadlineData = res
                if((self.topHeadlineData?.articles.count)! == (self.topHeadlineData?.totalResults!)!){
                    self.didReachEnd = true
                }
            }
        }
    }
    
    func addConstraints(){
        let constraints: [NSLayoutConstraint] = [
            headlineCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
            headlineCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headlineCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headlineCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loadingAnimationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingAnimationView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loadingAnimationView.heightAnchor.constraint(equalToConstant: 60),
            loadingAnimationView.widthAnchor.constraint(equalToConstant: 60)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}

extension HeadlineViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let header = headlineCollectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! CollectionHeaderCollectionReusableView
            header.headerlabel.text = "Top Headlines"
            return header
        default:
            assert(false,"invalid")
        }
   
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let url = URL(string: (topHeadlineData?.articles[indexPath.row].url!)!){
            newsWebViewController.url = url
            if let navigationController = navigationController{
                navigationController.pushViewController(self.newsWebViewController, animated: true)
            }
        }
    }
}

extension HeadlineViewController: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width-20, height: 300)
    }
}

extension HeadlineViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return topHeadlineData?.articles.count ?? 0
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (indexPath.row == (topHeadlineData?.articles.count)!-1 && !didReachEnd){
            currentPage = currentPage! + 1
            NewsroomAPIService.APIManager.fetchHeadlines(category: nil, countryCode: nil,page: currentPage!) { articles, error in
                if let error = error{
                    return
                }
                self.topHeadlineData?.articles.append(contentsOf: articles!.articles)
                DispatchQueue.main.async {
                    self.headlineCollectionView.reloadData()
                }
                if((self.topHeadlineData?.articles.count)! == (self.topHeadlineData?.totalResults!)!){
                    self.didReachEnd = true
                }
            }
        }
        let cell = headlineCollectionView.dequeueReusableCell(withReuseIdentifier: "headline-cell", for: indexPath) as! HeadlineCollectionViewCell
        cell.headlineText.text = topHeadlineData?.articles[indexPath.row].title
        if let imageUrl = topHeadlineData?.articles[indexPath.row].urlToImage{
            cell.cellBackgroundImage.sd_setImage(with: URL(string: imageUrl))
        }else{
            cell.cellBackgroundImage.image = UIImage(named: "news-default")
        }
        cell.cellBackgroundImage.sd_setImage(with: URL(string: topHeadlineData?.articles[indexPath.row].urlToImage ?? ""))
        cell.sourceLabel.text = topHeadlineData?.articles[indexPath.row].source.name ?? ""
        return cell
    }
    
    
}
