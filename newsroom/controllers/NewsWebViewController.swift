//
//  NewWebViewcontrollerViewController.swift
//  newsroom
//
//  Created by Sarthak Jha on 27/12/22.
//

import UIKit
import WebKit

final class NewsWebViewController: UIViewController, WKNavigationDelegate {

    var webView: WKWebView?
    var navBar: UINavigationBar?
    var url: URL?
    
    var backButtonItem: UINavigationItem = {
        var item = UINavigationItem(title: "back")
        return item
    }()
    override func viewDidLoad() {
        
        if let navigationController = navigationController {
            navigationController.isNavigationBarHidden = false
        }
        super.viewDidLoad()
        webView = WKWebView()
        guard let webView = webView else {return}

        view.addSubview(webView)

        webView.translatesAutoresizingMaskIntoConstraints = false

        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            guard let url = self.url else {return}
            guard let webView = self.webView else {return}
            self.title = url.absoluteString
            webView.load(URLRequest(url: url))
        }
        webView.allowsBackForwardNavigationGestures = true
        webView.navigationDelegate = self
        navBar = UINavigationBar()
        guard let navBar = navBar else {return}

        view.addSubview(navBar)
        navBar.translatesAutoresizingMaskIntoConstraints = false
        navBar.isHidden = false
        navBar.backgroundColor = .white
        addConstraints()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if let navigationController = navigationController {
            navigationController.isNavigationBarHidden = true
        }
    }
    
    @objc func dismiss() {
        guard let webView = webView else {return}

        webView.goBack()
    }
    deinit{
        guard var webView = webView else {return}

        webView.stopLoading()
    }
    
    func addConstraints() {
        guard let url = url else {return}
        guard let webView = webView else {return}
        guard let navBar = navBar else {return}

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
