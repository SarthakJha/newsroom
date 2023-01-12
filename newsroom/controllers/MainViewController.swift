//
//  ViewController.swift
//  newsroom
//
//  Created by Sarthak Jha on 16/12/22.
//

import UIKit

final class MainViewController: UITabBarController, UITabBarControllerDelegate {
    private var noInternetView: NoInternetView = {
       var view = NoInternetView()
        view.backgroundColor = .white
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(internetStatus), name: NSNotification.Name("isConnected"), object: nil)
        view.addSubview(noInternetView)
        noInternetView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        noInternetView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        noInternetView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        noInternetView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true

    }
    
    @objc private func internetStatus(){
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            self.noInternetView.startView()

        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let navigationController = navigationController {
            navigationController.navigationBar.isHidden = false
        }
        let searchVC = SearchViewController()
        let mapVC = MapViewController()
        let headlineVC = HeadlineViewController()
        let sampleVC = SampleViewController()
        
        let searchBarItem = UITabBarItem(title: String(localized: "TAB_BAR_SEARCH_TEXT"), image: UIImage(systemName: "magnifyingglass"), selectedImage: UIImage(systemName: "magnifyingglass.fill"))
        searchVC.tabBarItem = searchBarItem
        
        let categoryBarItem = UITabBarItem(title: String(localized: "TAB_BAR_MAP_TEXT"), image: UIImage(systemName: "map"), selectedImage: UIImage(systemName: "map.fill"))
        mapVC.tabBarItem = categoryBarItem
        
        let mapBarItem = UITabBarItem(title: String(localized: "TAB_BAR_HEADLINES_TEXT"), image: UIImage(systemName: "bolt") ,selectedImage: UIImage(systemName: "bolt.fill"))
        headlineVC.tabBarItem = mapBarItem
        
        // MARK:sample
        let sampleItem = UITabBarItem(title: "sample", image: nil, selectedImage: nil)
        sampleVC.tabBarItem = sampleItem
        
        self.viewControllers = [searchVC, mapVC, headlineVC, sampleVC]
        tabBar.backgroundColor = UIColor(white: 1, alpha: 1)
        tabBar.tintColor = .black
    }
    
}

