//
//  Post.swift
//  Coda
//
//  Created by Roma Chopovenko on 8/10/17.
//  Copyright © 2017 Appcoda. All rights reserved.
//

import UIKit

class Post: NSObject {
    var postTitle: String = ""
    var postURL: String = ""
    
    init(dictionary: [String : Any]) {
        self.postTitle = dictionary["postTitle"] as! String
        self.postURL = dictionary["postURL"] as! String
        super.init()
    }
}
