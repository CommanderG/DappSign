//
//  DappMappVC.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 4/8/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

class DappMappVC: UIViewController {
    internal static let storyboardID = "dappMappVC"
    
    @IBOutlet weak var districtsLabel: UILabel!
    @IBOutlet weak var webView:        UIWebView!
    @IBOutlet weak var percentsView:   PercentsView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layer.cornerRadius = 12.0
        self.view.layer.borderColor = UIColor.whiteColor().CGColor
        self.view.layer.borderWidth = 2.0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    internal func showInformationAboutDapp(dapp: PFObject) {
        let SVGMapURL = SVGMapGenerator.generate([:])
        
        // placeholders
        self.initDistrictsLabelTextWithDistricsOnTheMapCount(0)
        self.showMapWithURL(SVGMapURL)
        self.percentsView.showPercents(0)
        
        Requests.percents(dapp, completion: {
            (usersDapped: [PFUser:Bool]?, error: NSError?) -> Void in
            if let usersDapped = usersDapped {
                if usersDapped.count >= 20 {
                    self.downloadDataForMapAndShowIt(usersDapped, dapp: dapp)
                } else {
                    self.generateRandomMapAndShowIt()
                }
            }
        })
    }
    
    // MARK: - private
    
    private func downloadDataForMapAndShowIt(usersDapped: [PFObject:Bool], dapp: PFObject) {
        let dapps = Array(usersDapped.values)
        
        CongressionalDistrictsIDs.getIDsFrequenciesForDapp(dapp, completion: {
            (IDsFreqs: IDsFrequencies?) -> Void in
            if let IDsFreqs_ = IDsFreqs {
                let SVGMapURL = SVGMapGenerator.generate(IDsFreqs_)
                let dappedCount = Array(usersDapped.keys).filter({
                    let currentUser = PFUser.currentUser()
                    
                    if let
                        currentUserCongrDistrID = currentUser["congressionalDistrictID"] as? String,
                        userCongrDistrID = $0["congressionalDistrictID"] as? String {
                            if $0.objectId == currentUser.objectId {
                                // the back end hasn't been updated yet
                                return true
                            } else if currentUserCongrDistrID == userCongrDistrID {
                                if let dapped = usersDapped[$0] as Bool? {
                                    if dapped == true {
                                        return true
                                    }
                                }
                            }
                    }
                    
                    return false
                }).count
                
                var percents = 0 as UInt
                
                if dappedCount > 0 && dapps.count > 0 {
                    percents = UInt(roundf(Float(dappedCount) / Float(dapps.count) * 100))
                }
                
                self.showMapWithURL(SVGMapURL)
                self.percentsView.showPercents(percents)
            }
        })
    }
    
    private func generateRandomMapAndShowIt() {
        var dappsCount = UInt(10 + arc4random_uniform(20))
        var IDsFreqs = CongressionalDistrictsIDs.getRandomIDsFreqs(dappsCount)
        let districtsOnTheMap = IDsFreqs.count
        
        self.initDistrictsLabelTextWithDistricsOnTheMapCount(districtsOnTheMap)
        
        var percents: UInt = 0
        let SVGMapURL = SVGMapGenerator.generate(IDsFreqs)
        
        if let
            user = PFUser.currentUser(),
            congrDistrID = user["congressionalDistrictID"] as? String {
                let additionalFreq = UInt(1 + arc4random_uniform(4))
                var dappTotalViews: UInt = 1
                var dappDapps: UInt = 1
                
                if let freq = IDsFreqs[congrDistrID] as UInt? {
                    IDsFreqs[congrDistrID] = freq + additionalFreq
                    
                    dappTotalViews = freq + additionalFreq
                } else {
                    IDsFreqs[congrDistrID] = additionalFreq
                    
                    dappTotalViews = additionalFreq
                }
                
                dappDapps = UInt(arc4random_uniform(UInt32(dappTotalViews)))
                
                if dappDapps == 0 {
                    dappDapps = 1
                } else if dappDapps > dappTotalViews {
                    dappDapps = dappTotalViews
                }
                
                percents = UInt(roundf(Float(dappDapps) / Float(dappTotalViews) * 100))
                
                dappsCount += additionalFreq
        }
        
        self.showMapWithURL(SVGMapURL)
        self.percentsView.showPercents(percents)
    }
    
    private func initDistrictsLabelTextWithDistricsOnTheMapCount(districtsOnTheMapCount: Int) {
        let totalDistrictsCount = SVGMapGenerator.districtsCount()
        
        self.districtsLabel.text = "\(districtsOnTheMapCount)/\(totalDistrictsCount) " +
                                   "Districts support this petition."
    }
    
    private func showMapWithURL(SVGMapURLPath: String?) {
        self.webView.hidden = true
        
        if let mapURLPath = SVGMapURLPath {
            let URL = NSURL(fileURLWithPath: mapURLPath)
            let request = NSURLRequest(URL: URL)
            
            self.webView.loadRequest(request)
            self.webView.hidden = false
        }
    }
}

extension DappMappVC: UIWebViewDelegate {
    func webViewDidFinishLoad(webView: UIWebView) {
        let scaleX = CGRectGetWidth(webView.bounds) / webView.scrollView.contentSize.width
        let scaleY = CGRectGetHeight(webView.bounds) / webView.scrollView.contentSize.height
        let scale = max(scaleX, scaleY)
        
        webView.scrollView.minimumZoomScale = scale
        webView.scrollView.maximumZoomScale = scale
        webView.scrollView.zoomScale = scale
        webView.scrollView.scrollEnabled = false
    }
}
