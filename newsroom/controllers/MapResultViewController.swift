//
//  MapResultViewController.swift
//  newsroom
//
//  Created by Sarthak Jha on 22/12/22.
//

import UIKit
import CoreLocation

final class MapResultViewController: UIViewController {
    var delegate:MapViewControllerDelegate!
    public var countryCode: String?
    
    
    private var newsViewCollection: NewsViewController!
    
    private var dragable: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
//        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 3
        return view
    }()

    override func viewDidLoad() {
        
        super.viewDidLoad()
        dragable.frame = CGRect(x: view.frame.width/4, y: 0, width: view.frame.width/2, height: 10)
        view.backgroundColor = .white
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 20
        newsViewCollection = NewsViewController(collectionViewLayout: flowLayout)
        print("haha: ", countryCode)
        newsViewCollection.setCountryCode(countryCode: countryCode!)
        newsViewCollection.setControllerType(controllerType: .mapResult)
//        newsViewCollection.cou
        newsViewCollection.delegate = self
        
        view.addSubview(newsViewCollection.collectionView)
        view.addSubview(newsViewCollection.loadingAnimation)
        view.addSubview(newsViewCollection.notFoundAnimation)
        view.addSubview(dragable)

        // Do any additional setup after loading the view.
        addConstraints()
    }
    
    private func addConstraints(){
        
        //dragable view
        dragable.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        dragable.bottomAnchor.constraint(equalTo: newsViewCollection.collectionView.topAnchor).isActive = true

        
        // collectionView constraints
        newsViewCollection.collectionView.topAnchor.constraint(equalTo: dragable.bottomAnchor, constant: dragable.intrinsicContentSize.height).isActive = true
        newsViewCollection.collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        newsViewCollection.collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        newsViewCollection.collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        // loading animation constraints
        newsViewCollection.loadingAnimation.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        newsViewCollection.loadingAnimation.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        newsViewCollection.loadingAnimation.heightAnchor.constraint(equalToConstant: 50).isActive = true
        newsViewCollection.loadingAnimation.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        // not found animation
        newsViewCollection.notFoundAnimation.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        newsViewCollection.notFoundAnimation.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        newsViewCollection.notFoundAnimation.heightAnchor.constraint(equalToConstant: 100).isActive = true
        newsViewCollection.notFoundAnimation.widthAnchor.constraint(equalToConstant: 100).isActive = true
    }

    
}

extension MapResultViewController: NewsViewControllerDelegate {
    
    func pushWebView(_ viewController: UIViewController) {
        
        if let navigationController = navigationController {
            DispatchQueue.main.async {
                navigationController.pushViewController(viewController, animated: true)
            }
        }
    }
}
