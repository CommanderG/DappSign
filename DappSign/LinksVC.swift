//
//  TestVC.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 9/15/15.
//  Copyright (c) 2015 DappSign. All rights reserved.
//

import UIKit

class LinksVC: UIViewController {
    @IBOutlet weak var v1: UIView!
    @IBOutlet weak var v2: UIView!
    @IBOutlet weak var linksTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.v1.hidden = true
        self.v2.hidden = true
        
//        self.v1.hidden = false
//        self.v2.hidden = true
        
        
        
        if let URL = NSURL(string: "http://adsadasdasderge.com") {
            self.getTitleFromURL(URL, completion: { (title: String?, errorMessage: String?) -> Void in
                if let title = title {
                    println(title)
                } else if let errorMessage = errorMessage {
                    UIAlertView(
                        title: nil
                    ,   message: errorMessage
                    ,   delegate: nil
                    ,   cancelButtonTitle: "OK"
                    ).show()
                }
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func getTitleFromURL(URL: NSURL, completion: (title: String?, errorMessage: String?) -> Void) {
        Requests.downloadDataFromURL(URL, completion: { (data: NSData?, error: NSError?) -> Void in
            if let data = data {
                var parsingError: NSError? = nil
                let parser = HTMLParser(data: data, error: &parsingError)
                
                if let parsingError = parsingError {
                    let errorMessage = "Parsing error. Failed to get the title from \(URL)."
                    
                    completion(title: nil, errorMessage: errorMessage)
                } else {
                    let title = parser.head().findChildTag("title").contents()
                    
                    completion(title: title, errorMessage: nil)
                }
            } else if let error = error {
                completion(title: nil, errorMessage: error.localizedDescription)
            } else {
                completion(title: nil, errorMessage: nil)
            }
        })
    }
    
    private func flipWithDuration(duration: NSTimeInterval, view1: UIView, view2: UIView) {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(duration)
        UIView.setAnimationTransition(.FlipFromLeft, forView: view1, cache: true)
        UIView.commitAnimations()
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(duration)
        UIView.setAnimationTransition(.FlipFromLeft, forView: view2, cache: true)
        
        view1.hidden = !view1.hidden
        view2.hidden = !view2.hidden
        
        UIView.commitAnimations()
    }
}

extension LinksVC: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! LinkCell
        
        cell.delegate = self
        
        cell.showViewsForState(State.EnterLink)
    }
}

extension LinksVC: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! LinkCell
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
}

extension LinksVC: LinkCellDelegate {
    func didEnterURLString(URLString: String, cell: LinkCell) {
        if let URL = NSURL(string: URLString) {
            cell.makeViews(ViewsState.Disabled)
            
            self.getTitleFromURL(URL, completion: {
                (title: String?, errorMessage: String?) -> Void in
                cell.makeViews(ViewsState.Enabled)
                
                if let title = title {
                    println(title)
                    
                    if let indexPath = self.linksTableView.indexPathForCell(cell) {
                        let linkIndex = indexPath.row + 1
                        
                        cell.showViewsForState(State.Link)
                        cell.showLinkInfo(linkIndex: linkIndex, linkTitle: title)
                    }
                } else if let errorMessage = errorMessage {
                    UIAlertView(
                        title: nil
                    ,   message: errorMessage
                    ,   delegate: nil
                    ,   cancelButtonTitle: "OK"
                    ).show()
                    
                    cell.showViewsForState(State.NoLink)
                } else {
                    cell.showViewsForState(State.NoLink)
                }
            })
        }
    }
}
