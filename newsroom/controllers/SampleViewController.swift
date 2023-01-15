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
        view.addSubview(newsViewCollection.loadingAnimation)

        // Do any additional setup after loading the view.
        addConstraints()
    }
    
    private func addConstraints(){
        
        // collectionView constraints
        newsViewCollection.collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        newsViewCollection.collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        newsViewCollection.collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        newsViewCollection.collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        // loading animation constraints
        newsViewCollection.loadingAnimation.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        newsViewCollection.loadingAnimation.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        newsViewCollection.loadingAnimation.heightAnchor.constraint(equalToConstant: 50).isActive = true
        newsViewCollection.loadingAnimation.widthAnchor.constraint(equalToConstant: 50).isActive = true
    }

}
