//
//  ParseHelper.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 4/5/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

class ParseHelper {
    internal class func downloadAllObjectsWithQuery(query: PFQuery,
        downloadedObjects: [PFObject],
        completion: (objects: [PFObject]?, error: NSError?) -> Void
    ) {
        query.skip = downloadedObjects.count
        query.limit = 1000
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            if let objects = objects as? [PFObject] {
                if objects.count > 0 {
                    let newDownloadedObjects = downloadedObjects + objects
                    
                    self.downloadAllObjectsWithQuery(query,
                        downloadedObjects: newDownloadedObjects,
                        completion: completion
                    )
                } else {
                    completion(objects: downloadedObjects, error: error)
                }
            } else {
                completion(objects: nil, error: error)
            }
        }
    }
}
