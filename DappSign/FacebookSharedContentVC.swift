//
//  FacebookSharedContentVC.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 5/24/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

class FacebookSharedContentVC: UIViewController {
    @IBOutlet weak var topLC: NSLayoutConstraint!
    @IBOutlet weak var leftLC: NSLayoutConstraint!
    @IBOutlet weak var containerViewWidthLC: NSLayoutConstraint!
    @IBOutlet weak var containerViewHeightLC: NSLayoutConstraint!
    
    private var dappSignVC: DappSignVC? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    internal func showDapp(dapp: PFObject) {
        self.dappSignVC?.showDappObject(dapp)
    }
    
    internal func render() -> UIImage? {
        let viewWidth = self.containerViewWidthLC.constant
        let viewHeight = self.containerViewHeightLC.constant
        let viewVisibleWidth = self.view.bounds.width
        let viewVisibleHeight = self.view.bounds.height
        let horizontalImagesCountFloat = viewWidth / viewVisibleWidth
        let verticalImagesCountFloat = viewHeight / viewVisibleHeight
        let (horizImgsIntPart, horizImgsFracPart) = modf(horizontalImagesCountFloat)
        let (vertImgsIntPart, vertImgsFracPart) = modf(verticalImagesCountFloat)
        
        var horizontalImagesCount = Int(horizImgsIntPart)
        
        if horizImgsFracPart > 0.0 {
            ++horizontalImagesCount
        }
        
        var verticalImagesCount = Int(vertImgsIntPart)
        
        if vertImgsFracPart > 0.0 {
            ++verticalImagesCount
        }
        
        let mainScreen = UIScreen.mainScreen()
        let scale = mainScreen.scale
        let size = CGSizeMake(viewWidth, viewHeight)
        let whiteColor = UIColor.whiteColor()
        var resultImg = self.getImageWith(size, andColor: whiteColor)
        
        if resultImg == nil {
            return nil
        }
        
        for verticalImageIndex in 0 ..< verticalImagesCount {
            self.leftLC.constant = 0.0
            
            var viewImageHeight = viewVisibleHeight
            
            if verticalImageIndex == verticalImagesCount - 1 {
                viewImageHeight *= vertImgsFracPart
            }
            
            for horizontalImageIndex in 0 ..< horizontalImagesCount {
                var viewImageWidth = viewVisibleWidth
                
                if horizontalImageIndex == horizontalImagesCount - 1 {
                    viewImageWidth *= horizImgsFracPart
                }
                
                let size = CGSizeMake(viewImageWidth, viewImageHeight)
                
                if let
                    viewImage = self.getViewImage(size, scale: scale),
                    currentResultImg = resultImg {
                        let viewImageOriginX = CGFloat(horizontalImageIndex) * viewVisibleWidth
                        let viewImageOriginY = CGFloat(verticalImageIndex) * viewVisibleHeight
                        let viewImageOrigin = CGPointMake(viewImageOriginX, viewImageOriginY)
                        
                        resultImg = self.addImage(viewImage,
                            atPosition: viewImageOrigin,
                            toBackgroundImage: currentResultImg
                        )
                } else {
                    self.topLC.constant = 0.0
                    self.leftLC.constant = 0.0
                    
                    return nil
                }
                
                self.leftLC.constant -= viewVisibleWidth
            }
            
            self.topLC.constant -= viewVisibleHeight
        }
        
        if let resultImg = resultImg {
            let facebookResultImg = self.resizeImageForFacebook(resultImg)
            
            return facebookResultImg
        }
        
        return resultImg
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let segueIdentifier = segue.identifier {
            switch segueIdentifier {
            case DappSignVC.embedSegueID:
                self.dappSignVC = segue.destinationViewController as? DappSignVC
            case _:
                break
            }
        }
    }
    
    // MARK: - private
    
    private func getViewImage(size: CGSize, scale: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        
        if let context = UIGraphicsGetCurrentContext() {
            self.view.layer.renderInContext(context)
            
            let viewImage = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            
            return viewImage
        }
        
        return nil
    }
    
    private func getImageWith(size: CGSize, andColor color: UIColor) -> UIImage? {
        let rect = CGRectMake(0.0, 0.0, size.width, size.height)
        
        UIGraphicsBeginImageContext(size)
        
        if let context = UIGraphicsGetCurrentContext() {
            CGContextSetFillColorWithColor(context, color.CGColor)
            CGContextFillRect(context, rect)
            
            let image = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            
            return image
        }
        
        return nil
    }
    
    private func addImage(
        fgImg: UIImage,
        atPosition fgImgOrigin: CGPoint,
        toBackgroundImage bgImg: UIImage
    ) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bgImg.size, false, 0.0)
        
        let bgImgRect = CGRectMake(0.0, 0.0, bgImg.size.width, bgImg.size.height)
        let fgImgRect = CGRectMake(
            fgImgOrigin.x,
            fgImgOrigin.y,
            fgImg.size.width,
            fgImg.size.height
        )
        
        bgImg.drawInRect(bgImgRect)
        fgImg.drawInRect(fgImgRect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    private func resizeImageForFacebook(image: UIImage) -> UIImage {
        // https://www.facebook.com/help/266520536764594
        
        let resultImageWidthInPixels = image.size.width * image.scale
        let facebookImageWidthInPixels: CGFloat = 960.0
        let scale = facebookImageWidthInPixels / resultImageWidthInPixels
        let transform = CGAffineTransformMakeScale(scale, scale)
        let size = CGSizeApplyAffineTransform(image.size, transform)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        let rect = CGRect(origin: CGPointZero, size: size)
        
        image.drawInRect(rect)
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
}
