//
//  SampleViewController.swift
//  newsroom
//
//  Created by Sarthak Jha on 12/01/23.
//

import UIKit

class SampleViewController: UIViewController {
    
    var newsViewCollection: NewsViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 20
        newsViewCollection = NewsViewController(collectionViewLayout: flowLayout)
        newsViewCollection.setControllerType(controllerType: .topHeadlines)
        view.addSubview(newsViewCollection.collectionView)
        
        // Do any additional setup after loading the view.
        addConstraints()
    }
    
    private func addConstraints(){
        newsViewCollection.collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        newsViewCollection.collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        newsViewCollection.collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        newsViewCollection.collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }

}
