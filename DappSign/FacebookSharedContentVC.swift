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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    internal func render() -> UIImage? {
        
        let imageWidth = self.containerViewWidthLC.constant
        let imageHeight = self.containerViewHeightLC.constant
        let horizontalImagesCountFloat = imageWidth / self.view.bounds.width
        let verticalImagesCountFloat = imageHeight / self.view.bounds.height
        
        let (horizontalImagesCountIntPart, horizontalImagesCountFracPart) = modf(horizontalImagesCountFloat)
        let (verticalImagesCountIntPart, verticalImagesCountFracPart) = modf(verticalImagesCountFloat)
        
        var horizontalImagesCount = Int(horizontalImagesCountIntPart)
        
        if horizontalImagesCountFracPart > 0.0 {
            ++horizontalImagesCount
        }
        
        var verticalImagesCount = Int(verticalImagesCountIntPart)
        
        if verticalImagesCountFracPart > 0.0 {
            ++verticalImagesCount
        }
        
        print(imageWidth, imageHeight)
        print(horizontalImagesCountFloat, verticalImagesCountFloat)
        print(modf(horizontalImagesCountFloat), modf(verticalImagesCountFloat))
        print(horizontalImagesCount, verticalImagesCount)
        
        
        
        
        
        let mainScreen = UIScreen.mainScreen()
        let scale = mainScreen.scale
        let size = CGSizeMake(imageWidth, imageHeight)
        let bgImg = self.bgImg(size)
        
        var imageCount = 0
        var resultImg = bgImg
        
        for y in 0 ..< verticalImagesCount {
            self.leftLC.constant = 0.0
            
            var h: CGFloat = 0.0
            
            if y == verticalImagesCount - 1 {
                h = self.view.bounds.height * verticalImagesCountFracPart
            } else {
                h = self.view.bounds.height
            }
            
            for x in 0 ..< horizontalImagesCount {
                print("left: \(self.leftLC.constant), top: \(self.topLC.constant)")
                
                var w: CGFloat = 0.0
                
                if x == horizontalImagesCount - 1 {
                    w = self.view.bounds.width * horizontalImagesCountFracPart
                } else {
                    w = self.view.bounds.width
                }
                
                let size = CGSizeMake(w, h)
                
                UIGraphicsBeginImageContextWithOptions(size, false, scale)
                
                if let context = UIGraphicsGetCurrentContext() {
                    self.view.layer.renderInContext(context)
                    
                    let img = UIGraphicsGetImageFromCurrentImageContext()
                    
                    UIGraphicsEndImageContext()
                    
                    let paths = NSSearchPathForDirectoriesInDomains(
                        NSSearchPathDirectory.DocumentDirectory,
                        NSSearchPathDomainMask.UserDomainMask,
                        true
                    )
                    let folderPath = paths.first
                    
                    if let resultImg_1 = resultImg {
                        let originX = CGFloat(x) * self.view.bounds.width
                        let originY = CGFloat(y) * self.view.bounds.height
                        let origin = CGPointMake(originX, originY)
                        
                        resultImg = self.addImage(img,
                            toBackgroundImage: resultImg_1,
                            origin: origin
                        )
                        
                        if let
                            resultImg_2 = resultImg,
                            folderPath = folderPath,
                            imageData = UIImagePNGRepresentation(resultImg_2) {
                                let imgPath = folderPath + "/res_img\(imageCount).png"
                                
                                imageData.writeToFile(imgPath, atomically: true)
                        }
                    }
                    
                    if let folderPath = folderPath, imageData = UIImagePNGRepresentation(img) {
                        let imgPath = folderPath + "/img\(imageCount).png"
                        
                        imageData.writeToFile(imgPath, atomically: true)
                        
                        print(imgPath)
                    }
                }
                
                ++imageCount
                
                self.leftLC.constant -= self.view.bounds.width
            }
            
            self.topLC.constant -= self.view.bounds.height
        }
        
        return nil
    }
    
    private func bgImg(size: CGSize) -> UIImage? {
        let rect = CGRectMake(0.0, 0.0, size.width, size.height)
        
        UIGraphicsBeginImageContext(size)
        
        let bgColor = UIColor.whiteColor()
        
        if let context = UIGraphicsGetCurrentContext() {
            CGContextSetFillColorWithColor(context, bgColor.CGColor)
            CGContextFillRect(context, rect)
            
            let img = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            
            return img
        }
        
        return nil
    }
    
    private func addImage(
        fgImg: UIImage,
        toBackgroundImage bgImg: UIImage,
        origin: CGPoint
    ) -> UIImage {
//        UIGraphicsBeginImageContextWithOptions(bgImg.size, false, 0.0)
//        
//        let bgImgRect = CGRectMake(0.0, 0.0, bgImg.size.width, bgImg.size.height)
//        
//        bgImg.drawInRect(bgImgRect)
//        
//        let fgImgRect = CGRectMake(origin.x, origin.y, fgImg.size.width, fgImg.size.height)
//        
//        fgImg.drawInRect(fgImgRect)
//        
//        let img = UIGraphicsGetImageFromCurrentImageContext()
//        
//        UIGraphicsEndImageContext()
//        
//        return img
        
        
        
        
        
        UIGraphicsBeginImageContextWithOptions(bgImg.size, false, 0.0)
        
        bgImg.drawInRect(CGRectMake(0.0, 0.0, bgImg.size.width, bgImg.size.height))
        fgImg.drawInRect(CGRectMake(origin.x, origin.y, fgImg.size.width, fgImg.size.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return newImage
        
        
        
        
    }
}
