//
//  NewWebViewcontrollerViewController.swift
//  newsroom
//
//  Created by Sarthak Jha on 27/12/22.
//

import UIKit
import WebKit

class NewsWebViewController: UIViewController, WKNavigationDelegate {

    var webView: WKWebView!
    var navBar: UINavigationBar!
    var url: URL!
    
    var backButtonItem: UINavigationItem = {
        var item = UINavigationItem(title: "back")
        return item
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        webView = WKWebView()
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false

        self.webView.load(URLRequest(url: self.url))
        webView.allowsBackForwardNavigationGestures = true
        webView.navigationDelegate = self
        navBar = UINavigationBar()
        view.addSubview(navBar)
//        backButtonItem.backBarButtonItem = UIBarButtonItem(title: "back", style: .done, target: self, action: #selector(dismiss))
//        navBar.setItems([backButtonItem], animated: true)
        navBar.translatesAutoresizingMaskIntoConstraints = false
        navBar.isHidden = false
        navBar.backgroundColor = .white
        addConstraints()
    }
    
    @objc func dismiss(){
        webView.goBack()
    }
    
    
    func addConstraints(){
        let constrains: [NSLayoutConstraint] = [
            navBar.topAnchor.constraint(equalTo: view.topAnchor),
            navBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navBar.heightAnchor.constraint(equalToConstant: 84),
            webView.topAnchor.constraint(equalTo: navBar.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constrains)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
    
}
