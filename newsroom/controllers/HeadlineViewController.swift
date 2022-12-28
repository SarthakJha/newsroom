//
//  HeadlineViewController.swift
//  newsroom
//
//  Created by Sarthak Jha on 16/12/22.
//

import UIKit

class HeadlineViewController: UIViewController {
    /**
     Allow user to filter the headline results based on category
     */
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(style: .large)
    var headlineCollectionView: UICollectionView!
    var newsWebViewController: NewsWebViewController!
    var topHeadlineData: ArticleResponse? {
        didSet{
            DispatchQueue.main.async {
                
                self.headlineCollectionView.reloadData()
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    @objc func s(){
        print("lololololl")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Headlines"
        newsWebViewController = NewsWebViewController()
        view.addSubview(activityIndicator)
        let flowLayout = UICollectionViewFlowLayout()
        
        var btnItem = UIBarButtonItem(image: UIImage(systemName: "person"), style: .plain, target: self, action: #selector(s))
        self.navigationItem.rightBarButtonItem = btnItem
        self.navigationItem.rightBarButtonItem?.isHidden = false
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 20
        headlineCollectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        view.addSubview(headlineCollectionView)
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
        activityIndicator.startAnimating()
        NewsroomAPIService.APIManager.fetchHeadlines(category: .entertainment, countryCode: countryCode ?? "in") { res, err in
            if let err = err{
                print(err)
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
//        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
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
