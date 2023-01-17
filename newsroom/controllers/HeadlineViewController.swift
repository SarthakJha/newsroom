//
//  HeadlineViewController.swift
//  newsroom
//
//  Created by Sarthak Jha on 16/12/22.
//

import UIKit

final class HeadlineViewController: UIViewController {
    
    private var newsViewCollection: NewsViewController!
    private var headlineLabel: ControllerHeaderView = ControllerHeaderView(frame: .zero)


    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.backgroundColor = .white
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 20
        newsViewCollection = NewsViewController(collectionViewLayout: flowLayout)
        newsViewCollection.setControllerType(controllerType: .topHeadlines)
        newsViewCollection.delegate = self
        view.addSubview(newsViewCollection.collectionView)
        view.addSubview(newsViewCollection.loadingAnimation)
        view.addSubview(headlineLabel)

        // Do any additional setup after loading the view.
        addConstraints()
        
        headlineLabel.setTitle(title: "Headlines")
    }
    
    private func addConstraints(){
        
        // collectionView constraints
        newsViewCollection.collectionView.topAnchor.constraint(equalTo: headlineLabel.bottomAnchor).isActive = true
        newsViewCollection.collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        newsViewCollection.collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        newsViewCollection.collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        // loading animation constraints
        newsViewCollection.loadingAnimation.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        newsViewCollection.loadingAnimation.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        newsViewCollection.loadingAnimation.heightAnchor.constraint(equalToConstant: 50).isActive = true
        newsViewCollection.loadingAnimation.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        NSLayoutConstraint.activate(headerConstraints())
    }

    private func headerConstraints()->[NSLayoutConstraint] {
        var constraints: [NSLayoutConstraint] = []
        constraints.append(headlineLabel.heightAnchor.constraint(equalToConstant: 50))
        constraints.append(headlineLabel.bottomAnchor.constraint(equalTo: newsViewCollection.collectionView.topAnchor,constant: -25))
        constraints.append(headlineLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15))
        constraints.append(headlineLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor))
        constraints.append(headlineLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 60))
        return constraints
    }
}

extension HeadlineViewController: NewsViewControllerDelegate {
    
    func pushWebView(_ viewController: UIViewController) {
        
        if let navigationController = navigationController {
            DispatchQueue.main.async {
                navigationController.pushViewController(viewController, animated: true)
            }
        }
    }
}
