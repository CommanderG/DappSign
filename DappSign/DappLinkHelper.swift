//
//  DappLinkHelper.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 2/25/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import Foundation

class DappLinkHelper {
    internal class func linkWithAddress(
        linkAddress: String,
        completion: (link: Link?, errorMessage: String?) -> Void
    ) {
        if let URL = NSURL(string: linkAddress) {
            self.getTitleFromURL(URL, completion: {
                (title: String?, errorMessage: String?) -> Void in
                if let title = title {
                    let link = Link(URLStr: linkAddress, title: title)
                    
                    completion(link: link, errorMessage: nil)
                } else if let errorMessage = errorMessage {
                    completion(link: nil, errorMessage: errorMessage)
                } else {
                    completion(link: nil, errorMessage: nil)
                }
            })
        } else {
            completion(link: nil, errorMessage: "Incorrect URL.")
        }
    }
    
    private class func getTitleFromURL(
        URL: NSURL,
        completion: (title: String?, errorMessage: String?) -> Void
    ) {
        Requests.downloadDataFromURL(URL, completion: {
            (data: NSData?, error: NSError?) -> Void in
            if let data = data {
                var parsingError: NSError? = nil
                let parser: HTMLParser!
                
                do {
                    parser = try HTMLParser(data: data)
                } catch let error as NSError {
                    parsingError = error
                    parser = nil
                } catch {
                    fatalError()
                }
                
                if parsingError != nil {
                    let errorMessage = "Parsing error. Failed to get the title from \(URL)."
                    
                    completion(title: nil, errorMessage: errorMessage)
                } else {
                    let headTag = parser.head() as HTMLNode?
                    let titleTag = headTag?.findChildTag("title") as HTMLNode?
                    let title = titleTag?.contents()
                    
                    completion(title: title, errorMessage: nil)
                }
            } else if let error = error {
                completion(title: nil, errorMessage: error.localizedDescription)
            } else {
                completion(title: nil, errorMessage: nil)
            }
        })
    }
}
