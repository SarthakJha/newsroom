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
    var refreshController: UIRefreshControl = UIRefreshControl()
    var topHeadlineData: ArticleResponse? {
        didSet{
            DispatchQueue.main.async {[self] in
                
                headlineCollectionView.isHidden = false
                headlineCollectionView.reloadData()
//                self.activityIndicator.stopAnimating()
                loadingAnimationView.stop()
                loadingAnimationView.isHidden = true
                refreshController.endRefreshing()
            }
        }
    }
    
    @objc func refreshScreen(){
        NewsroomAPIService.APIManager.fetchHeadlines(category: .general, countryCode: "in") { res, err in
            if let err = err{
                print(err)
                let configuration = ToastConfiguration(
                    autoHide: true,
                    enablePanToClose: true,
                    displayTime: 3,
                    animationTime: 0.2
                )
                let toast = Toast.default(image: nil, title: "No results found!", subtitle: "No news articles found for your current location",configuration: configuration)
                DispatchQueue.main.async {
                    toast.show(haptic: .warning)
                    self.refreshController.endRefreshing()
                }
                return
            }else{
                self.topHeadlineData = res
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
     
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
        print(("hjeadline: ", countryCode))
        DispatchQueue.main.async {
            self.loadingAnimationView.isHidden = false
            self.headlineCollectionView.isHidden = true
            self.loadingAnimationView.play()
        }
        NewsroomAPIService.APIManager.fetchHeadlines(category: .entertainment, countryCode: "in") { res, err in
            if let err = err{
                print(err)
                let configuration = ToastConfiguration(
                    autoHide: true,
                    enablePanToClose: true,
                    displayTime: 3,
                    animationTime: 0.2
                )
                let toast = Toast.default(image: nil, title: "No results found!", subtitle: "No news articles found for your current location",configuration: configuration)
                DispatchQueue.main.async {
                    toast.show(haptic: .warning)
                }
                return
            }else{
                self.topHeadlineData = res
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
//            UIApplication.shared.open(url)
        }
    }
}

extension HeadlineViewController: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width-20, height: 300)
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: view.safeAreaInsets.top, left: 0, bottom: 0, right: 0)
//    }
    
}

extension HeadlineViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return topHeadlineData?.articles.count ?? 0
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = headlineCollectionView.dequeueReusableCell(withReuseIdentifier: "headline-cell", for: indexPath) as! HeadlineCollectionViewCell
        cell.headlineText.text = topHeadlineData?.articles[indexPath.row].title
        if let imageUrl = topHeadlineData?.articles[indexPath.row].urlToImage{
            cell.cellBackgroundImage.sd_setImage(with: URL(string: imageUrl))
        }else{
            cell.cellBackgroundImage.image = UIImage(named: "news-default")
        }
        cell.cellBackgroundImage.sd_setImage(with: URL(string: topHeadlineData?.articles[indexPath.row].urlToImage ?? ""))
        cell.sourceLabel.text = topHeadlineData?.articles[indexPath.row].source.name ?? ""
//        cell.cellBackgroundImage.sd = topHeadlineData?.articles[indexPath.row].urlToImage
        return cell
    }
    
    
}
