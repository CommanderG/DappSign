//
//  Link.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 9/24/15.
//  Copyright © 2015 DappSign. All rights reserved.
//

import UIKit

class Link: NSObject {
    internal private(set) var URLStr: String?
    internal private(set) var title: String = ""
    
    required init(URLStr: String?, title: String) {
        super.init()
        
        self.URLStr = URLStr
        self.title = title
    }
    
    init(linkObj: PFObject) {
        super.init()
        
        self.URLStr = linkObj["URL"] as? String
        
        if let linkTitle = linkObj["Title"] as? String {
            self.title = linkTitle
        } else {
            self.title = ""
        }
    }
}
