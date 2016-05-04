//
//  DappMappViewHelper.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 5/4/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

class DappMappViewHelper {
    internal class func initMapWebView(mapWebView: UIWebView!, mapURLString: String?) {
        mapWebView.hidden = true
        
        var URLString: String? = nil
        
        if let mapURLString = mapURLString {
            URLString = mapURLString
        } else {
            URLString = SVGMapGenerator.generateEmptyMap()
        }
        
        if let URLString = URLString {
            mapWebView.hidden = false
            
            let URL = NSURL(fileURLWithPath: URLString)
            let request = NSURLRequest(URL: URL)
            
            mapWebView.loadRequest(request)
        }
    }
    
    internal class func handleWebViewDidFinishLoad(webView: UIWebView) {
        let scaleX = CGRectGetWidth(webView.bounds) / webView.scrollView.contentSize.width
        let scaleY = CGRectGetHeight(webView.bounds) / webView.scrollView.contentSize.height
        let scale = max(scaleX, scaleY)
        
        webView.scrollView.minimumZoomScale = scale
        webView.scrollView.maximumZoomScale = scale
        webView.scrollView.zoomScale = scale
        webView.scrollView.scrollEnabled = false
    }
    
    internal class func initDistrictLabels(
        topDistrictLabel topDistrictLabel: UILabel!,
        secondTopDistrictLabel: UILabel!,
        thirdTopDistrictLabel: UILabel!,
        dappMappInfo: DappMappInfo?
    ) {
        self.initDistrictLabel(topDistrictLabel,
            districtIndex: 1,
            district: dappMappInfo?.topDistrict
        )
        self.initDistrictLabel(secondTopDistrictLabel,
            districtIndex: 2,
            district: dappMappInfo?.secondTopDistrict
        )
        self.initDistrictLabel(thirdTopDistrictLabel,
            districtIndex: 3,
            district: dappMappInfo?.thirdTopDistrict
        )
    }
    
    // MARK: - private
    
    private class func initDistrictLabel(districtLabel: UILabel!,
        districtIndex: Int,
        district: String?
    ) {
        if let district = district {
            districtLabel.hidden = false
            districtLabel.text = "\(districtIndex). \(district)"
        } else {
            districtLabel.hidden = true
        }
    }
}
