//
//  ViewController.swift
//  Coda
//
//  Created by Joyce Echessa on 1/8/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

import UIKit
import WebKit

let baseUrl = "https://www.appcoda.com"

struct WebKitStringConstants {
    static let MessageHandler = "didGetPosts"
}

struct Segues {
    static let recentPosts = "recentPosts"
}

struct Resources {
    struct Files {
        static let hideSections = "hideSections"
        static let getPosts = "getPosts"
    }
    
    static let typeJS = "js"
}

struct Keys {
    static let loading = "loading"
    static let estimatedProgress = "estimatedProgress"
    static let title = "title"
}

class ViewController: UIViewController, WKNavigationDelegate {
    
    var webView: WKWebView
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    @IBOutlet weak var reloadButton: UIBarButtonItem!
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var recentPostsButton: UIBarButtonItem!
    var postsWebView: WKWebView?
    var posts: [Post] = []
    
    let contentController = WKUserContentController()
    
    required init(coder aDecoder: NSCoder) {
        
        let config = WKWebViewConfiguration()
        

        let scriptContent = getDataFromFile(withName: Resources.Files.hideSections, otType: Resources.typeJS)
        
        let script = WKUserScript(source: scriptContent!, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        //let contentController =
        config.userContentController.addUserScript(script)
        self.webView = WKWebView(frame: .zero, configuration: config)
        super.init(coder: aDecoder)!
        self.webView.navigationDelegate = self
    }
    
//    required init(coder aDecoder: NSCoder) {
//        self.webView = WKWebView(frame: CGRect.zero)
//        super.init(coder: aDecoder)!
//        self.webView.navigationDelegate = self
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.insertSubview(webView, belowSubview: progressView)
        self.setupWebViewPosition()
        NotificationCenter.default.addObserver(self, selector: #selector(postSelected(_:)), name: .postSelected, object: nil)
        self.setupObservers()
        
        let url: URL = URL(string: baseUrl)!
        let urlRequest: URLRequest = URLRequest(url: url)
        webView.load(urlRequest)
        self.loadPostList()
        
        backButton.isEnabled = false
        forwardButton.isEnabled = false
        self.recentPostsButton.isEnabled = false
    }
    
    func postSelected(_ notification: Notification) {

        if let post = notification.object as? Post, let url = URL(string: post.postURL)  {
            let urlRequest = URLRequest(url: url)
            self.webView.load(urlRequest)
        } else {
            print("No article to open")
        }
    }
    
    func loadPostList() {
        let config = WKWebViewConfiguration()
        let scriptContent = getDataFromFile(withName: Resources.Files.getPosts, otType: Resources.typeJS)
        let script = WKUserScript(source: scriptContent!, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        
        self.contentController.addUserScript(script)
        
        self.contentController.add(self, name: WebKitStringConstants.MessageHandler)
        
        config.userContentController = self.contentController
        
        postsWebView = WKWebView(frame: .zero, configuration: config)
        let url: URL = URL(string: baseUrl)!
        let urlRequest: URLRequest = URLRequest(url: url)
        postsWebView!.load(urlRequest)
    }
    
    func setupWebViewPosition() {
        self.webView.translatesAutoresizingMaskIntoConstraints = false
        let height = NSLayoutConstraint(item: webView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1, constant: -44)
        let width = NSLayoutConstraint(item: webView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: 0)
        view.addConstraints([height, width])
    }
    
    func setupObservers() {
        webView.addObserver(self, forKeyPath: Keys.loading, options: .new, context: nil)
        webView.addObserver(self, forKeyPath: Keys.estimatedProgress, options: .new, context: nil)
        webView.addObserver(self, forKeyPath: Keys.title, options: .new, context: nil)
    }
    
    @IBAction func back(_ sender: UIBarButtonItem) {
        webView.goBack()
    }
    
    @IBAction func forward(_ sender: UIBarButtonItem) {
        webView.goForward()
    }
    
    @IBAction func reload(_ sender: UIBarButtonItem) {
        let request = URLRequest(url:webView.url!)
        webView.load(request)
    }
    @IBAction func recentAction(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: Segues.recentPosts, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == Segues.recentPosts) {
            guard let navVC = segue.destination as? UINavigationController else { return }
            guard let postsVC = navVC.topViewController as? PostsTableViewController else { return }
            postsVC.posts = posts
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == Keys.loading) {
            backButton.isEnabled = webView.canGoBack
            forwardButton.isEnabled = webView.canGoForward
        }
        if (keyPath == Keys.estimatedProgress) {
            progressView.isHidden = webView.estimatedProgress == 1
            progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        }
        if keyPath == Keys.title {
            self.title = webView.title
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressView.setProgress(0.0, animated: false)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> ()) {
        if (navigationAction.navigationType == .linkActivated && (navigationAction.request.url?.host?.lowercased().hasPrefix("www.appcoda.com"))!) {
            UIApplication.shared.openURL(navigationAction.request.url!)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}

extension ViewController: WKScriptMessageHandler {

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if (message.name == WebKitStringConstants.MessageHandler) {
            if let postsList = message.body as? [[String:Any]] {
                for ps in postsList {
                    let post = Post(dictionary: ps)
                    posts.append(post)
                }
                recentPostsButton.isEnabled = true
            }
        }
    }
}

// Helper Functions
func getDataFromFile(withName fileName: String, otType fileType: String) -> String? {
    guard let fileURL = Bundle.main.path(forResource: fileName, ofType: fileType) else { return nil }
    do {
        let fileContentString = try String(contentsOfFile: fileURL, encoding: .utf8)
        return fileContentString
    } catch {
        print("Loading Data from file error: \(error.localizedDescription)")
        return nil
    }
}

