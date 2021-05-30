//
//  WebViewController.swift
//  Triponus
//
//  Created by admin on 31/05/2021.
//

import UIKit
import WebKit

class WebViewController: BaseViewController, WKNavigationDelegate {
    var urlString: String = ""
    var webView : WKWebView!
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        self.view = webView
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.hideLoading()
    }
    
    override func viewDidLoad() {
        let url = URL(string: urlString)!
        self.showLoading()
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
        
        
    }

}
