//
//  SearchTableViewController.swift
//  DappSign
//
//  Created by Admin on 3/19/15.
//  Copyright (c) 2015 DappSign. All rights reserved.
//

import UIKit

class SearchTableViewController: UITableViewController {
    enum Section: Int {
        case Users = 0
        case Hashtags = 1
        case Dapps = 2
    }
    
    var users:[PFObject]? = []
    var hashtags:[PFObject]? = []
    var dapps:[PFObject]? = []
    
    let cellIdentifier = "cell"
    let dappCellIdentifier = "dappCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - <UITableViewDataSource>
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == Section.Users.rawValue {
            return "Users"
        } else if section == Section.Hashtags.rawValue {
            return "Hashtags"
        }
        
        return "Dapps"
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == Section.Users.rawValue {
            if let count = self.users?.count {
                return count
            }
            
            return 0
        } else if section == Section.Hashtags.rawValue {
            if let count = self.hashtags?.count {
                return count
            }
            
            return 0
        }
        
        // Section.Dapps.rawValue
        if let count = self.dapps?.count {
            return count
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == Section.Dapps.rawValue {
            let cell = tableView.dequeueReusableCellWithIdentifier(self.dappCellIdentifier,
                forIndexPath: indexPath) as DappCardCell
            
            if let dapp = self.dapps?[indexPath.row] {
                cell.dappStatementLabel.text = dapp["dappStatement"] as? String
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifier,
                forIndexPath: indexPath) as UITableViewCell
            
            if indexPath.section == Section.Users.rawValue {
                if let user = self.users?[indexPath.row] {
                    cell.textLabel?.text = user["name"] as? String
                }
            } else if indexPath.section == Section.Hashtags.rawValue {
                if let hashtag = self.hashtags?[indexPath.row] {
                    cell.textLabel?.text = hashtag["name"] as? String
                }
            }
            
            return cell
        }
    }
    
    // MARK: - <UITableViewDelegate>
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: - @IBActions
    
    @IBAction func close(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension SearchTableViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        println(searchBar.text)
        
        let searchText = searchBar.text
        
        Requests.downloadUsersWithNameWhichContains(searchText, completion: {
            (users: [PFObject], error: NSError!) -> Void in
            if error != nil {
                println(error)
                
                return
            }
            
            self.users = users
            
            self.tableView.reloadSections(
                NSIndexSet(index: Section.Users.rawValue),
                withRowAnimation: .None
            )
        })
        
        Requests.downloadHashtagsWithNameWhichContains(searchText, completion: {
            (hashtags: [PFObject], error: NSError!) -> Void in
            if error != nil {
                println(error)
                
                return
            }
            
            self.hashtags = hashtags
            
            self.tableView.reloadSections(
                NSIndexSet(index: Section.Hashtags.rawValue),
                withRowAnimation: .None
            )
        })
        
        Requests.downloadDappsWithStatementWhichContains(searchText,
            notSwipedByUser: PFUser.currentUser()) {
                (dapps: [PFObject], error: NSError!) -> Void in
                if error != nil {
                    println(error)
                    
                    return
                }
                
                self.dapps = dapps
                
                self.tableView.reloadSections(
                    NSIndexSet(index: Section.Dapps.rawValue),
                    withRowAnimation: .None
                )
        }
    }
}
