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
    
    var headlineCollectionView: UICollectionView!
    var topHeadlineData: ArticleResponse? {
        didSet{
            DispatchQueue.main.async {
                self.headlineCollectionView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the
        self.headlineCollectionView.delegate = self
        self.headlineCollectionView.dataSource = self
        self.headlineCollectionView.register(HeadlineCollectionViewCell.self, forCellWithReuseIdentifier: "headline-cell")
        self.headlineCollectionView.register(CollectionHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        self.headlineCollectionView.alwaysBounceVertical = true
        self.headlineCollectionView.backgroundColor = .white
        let countryCode = UserDefaults.standard.string(forKey: "country-code")
        NewsroomAPIService.APIManager.fetchHeadlines(category: .entertainment, countryCode: countryCode ?? "in") { res, err in
            if let err = err{
                print(err)
            }else{
                self.topHeadlineData = res
            }
        }
    }
    override func loadView() {
        // setting up flow layout
        let flowLayout = UICollectionViewFlowLayout()

        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 20
        
        headlineCollectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        self.view = headlineCollectionView
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
