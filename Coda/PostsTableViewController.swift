//
//  PostsTableViewController.swift
//  Coda
//
//  Created by Roma Chopovenko on 8/10/17.
//  Copyright © 2017 Appcoda. All rights reserved.
//

import UIKit

let postCellID = "postCell"

extension Notification.Name {
    static let postSelected = Notification.Name(rawValue: "postSelected")
}

class PostsTableViewController: UITableViewController {
    
    var posts: [Post] = []
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
    }
    
    required init(coder aDecoder: NSCoder) {
       	super.init(coder: aDecoder)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Recent Articles"
        tableView.reloadData()
    }
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    func numberOfSectionsInTableView(tableView:
        UITableView?) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let post = posts[indexPath.row]
        cell.textLabel?.text = post.postTitle
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.row]
        NotificationCenter.default.post(name: .postSelected, object: post)
        self.dismiss(animated: true)
    }
}
