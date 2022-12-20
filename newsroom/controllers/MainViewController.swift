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
        
        let searchVC = SearchViewController()
        let categoryVC = MapViewController()
        let mapVC = HeadlineViewController()
        
        let searchBarItem = UITabBarItem(title: "search", image: UIImage(named: "icon.png"), tag: 0)
        searchVC.tabBarItem = searchBarItem
        
        let categoryBarItem = UITabBarItem(title: "map", image: UIImage(named: "icon.png"), tag: 1)
        categoryVC.tabBarItem = categoryBarItem
        
        let mapBarItem = UITabBarItem(title: "headlines", image: UIImage(named: "ss"), tag: 2)
        mapVC.tabBarItem = mapBarItem
        self.viewControllers = [searchVC, categoryVC,mapVC]
        self.tabBar.backgroundColor = .black
        self.tabBar.isTranslucent = true
        
    }
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        print(viewController)
    }

}

