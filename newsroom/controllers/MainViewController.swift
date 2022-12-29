//
//  ViewController.swift
//  newsroom
//
//  Created by Sarthak Jha on 16/12/22.
//

import UIKit

class MainViewController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let navigationController = navigationController {
            navigationController.navigationBar.isHidden = false
        }
        let searchVC = SearchViewController()
        let mapVC = MapViewController()
        let headlineVC = HeadlineViewController()
        
//        tabBar.backgroundColor = .black
        
        let searchBarItem = UITabBarItem(title: "search", image: UIImage(systemName: "magnifyingglass"), tag: 0)
        searchVC.tabBarItem = searchBarItem
        
        let categoryBarItem = UITabBarItem(title: "map", image: UIImage(systemName: "map"), tag: 1)
        mapVC.tabBarItem = categoryBarItem
        
    
        
        
        let mapBarItem = UITabBarItem(title: "headlines", image: UIImage(systemName: "bolt") , tag: 2)
        headlineVC.tabBarItem = mapBarItem
        self.viewControllers = [searchVC, mapVC ,headlineVC]
        tabBar.backgroundColor = UIColor(white: 1, alpha: 0.7)
        
    }
}

