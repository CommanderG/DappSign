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
    
    var users: [PFUser]? = []
    var hashtags: [PFObject]? = []
    var dapps: [PFObject]? = []
    
    let cellIdentifier = "cell"
    let dappCellIdentifier = "dappCell"
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let font = UIFont(name: "Exo-Regular", size: 18.0) {
            self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: font]
        }
        
        if let font = UIFont(name: "Exo-Regular", size: 16.0) {
            self.navigationItem.leftBarButtonItem?.setTitleTextAttributes(
                [NSFontAttributeName: font],
                forState: .Normal
            )
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if countElements(self.searchBar.text) > 0 {
            self.searchText(self.searchBar.text)
        }
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
        
        if indexPath.section == Section.Users.rawValue {
            let profileNavigationController =
                self.storyboard?.instantiateViewControllerWithIdentifier("profileNavigationController") as? UINavigationController
            
            if profileNavigationController == nil {
                return
            }
            
            let profileViewController = profileNavigationController?.viewControllers.first as? ProfileViewController
            
            if profileViewController == nil {
                return
            }
            
            if let user = self.users?[indexPath.row] {
                profileViewController?.user = user
                
                self.presentViewController(profileNavigationController!, animated: true, completion: nil)
            }
        } else {
            let dappsNavigationController =
                self.storyboard?.instantiateViewControllerWithIdentifier("dappsNavigationController") as? UINavigationController
            
            if dappsNavigationController == nil {
                return
            }
            
            let dappsViewController = dappsNavigationController!.viewControllers.first as? DappsViewController
            
            if dappsViewController == nil {
                return
            }
            
            if indexPath.section == Section.Hashtags.rawValue {
                if let hashtag = self.hashtags?[indexPath.row] {
                    self.tableView.userInteractionEnabled = false
                    
                    let currentUser = PFUser.currentUser()
                    
                    Requests.downloadDappsNotSwipedByUser(currentUser, hashtag: hashtag, completion: {
                        (dapps: [PFObject]?, error: NSError?) -> Void in
                        self.tableView.userInteractionEnabled = true
                        
                        if let error = error {
                            let alertView = UIAlertView(
                                title: "Error",
                                message: error.localizedDescription,
                                delegate: nil,
                                cancelButtonTitle: "OK"
                            )
                            
                            alertView.show()
                            
                            return
                        }
                        
                        if let dapps = dapps {
                            if dapps.count == 0 {
                                let alertView = UIAlertView(
                                    title: "Error",
                                    message: "There are no dapps with such hashtag",
                                    delegate: nil,
                                    cancelButtonTitle: "OK"
                                )
                                
                                alertView.show()
                                
                                return
                            }
                            
                            let dappsInfo = DappsInfo(
                                hashtag: self.hashtags![indexPath.row],
                                dapps: dapps
                            )
                            
                            dappsViewController!.dappsInfo = dappsInfo
                            
                            self.presentViewController(dappsNavigationController!,
                                animated: true,
                                completion: nil
                            )
                        } else {
                            let alertView = UIAlertView(
                                title: "Error",
                                message: "There are no dapps with such hashtag",
                                delegate: nil,
                                cancelButtonTitle: "OK"
                            )
                            
                            alertView.show()
                        }
                    })
                }
            } else if indexPath.section == Section.Dapps.rawValue {
                if let dapp = self.dapps?[indexPath.row] {
                    dappsViewController!.dappsInfo = DappsInfo(hashtag: nil, dapps: [dapp])
                    
                    self.presentViewController(dappsNavigationController!,
                        animated: true,
                        completion: nil
                    )
                }
            }
        }
    }
    
    // MARK: - @IBActions
    
    @IBAction func close(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: -
    
    private func searchText(searchText: String) {
        Requests.downloadUsersWithNameWhichContains(searchText, completion: {
            (users: [PFUser], error: NSError!) -> Void in
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

extension SearchTableViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if countElements(searchBar.text) > 0 {
            self.searchText(searchBar.text)
        }
    }
}
