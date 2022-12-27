//
//  NewWebViewcontrollerViewController.swift
//  newsroom
//
//  Created by Sarthak Jha on 27/12/22.
//

import UIKit
import WebKit

class NewsWebViewController: UIViewController {

    var webView: WKWebView!
    var url: URL!
    override func viewDidLoad() {
        super.viewDidLoad()
        webView = WKWebView(frame: view.frame)
        self.webView.load(URLRequest(url: self.url))
        webView.allowsBackForwardNavigationGestures = true

        view.addSubview(webView)

        // Do any additional setup after loading the view.
    }
    
}
