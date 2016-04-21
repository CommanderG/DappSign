//
//  MapGenerator.swift
//  SVGTest
//
//  Created by Oleksiy Kovtun on 8/31/15.
//  Copyright (c) 2015 Yanpix. All rights reserved.
//

import UIKit

class SVGMapGenerator: NSObject {
    internal class func generateEmptyMap() -> String? {
        return self.generate([:])
    }
    
    /**
    - returns: Path to the SVG file with the map.
    */
    internal class func generate(
        IDsFreqs: IDsFrequencies,
        minRadius: Double = 2.0,
        maxRadius: Double = 40.0,
        mapFillColor: String = "white",
        circleFillColor: String = "#3B98D8"
    ) -> String? {
        func getPaths() -> String {
            var str = ""
            let paths = SVGMapData.paths
            
            for idx in 0 ... paths.count - 1 {
                let path = paths[idx]
                
                str +=
                    "  <path\n"           +
                    "    d=\"\(path)\"\n" +
                    "    class=\"map\"/>"
                
                if idx < paths.count - 1 {
                    str += "\n"
                }
            }
            
            return str
        }
        
        func getCircles() -> String? {
            if minRadius < 0.0 {
                print("Error. minRadius \(minRadius) < 0.0")
                
                return nil
            }
            
            if maxRadius < 0.0 {
                print("Error. maxRadius \(maxRadius) < 0.0")
                
                return nil
            }
            
            if maxRadius <= minRadius {
                print("Error. maxRadius \(maxRadius) <= minRadius \(minRadius)")
                
                return nil
            }
            
            var str = ""
            
            if IDsFreqs.count == 0 {
                return str
            }
            
            let circles = SVGMapData.congrDstrsCircles.filter({
                return Array(IDsFreqs.keys).contains($0.id)
            })
            let maxFreq = Array(IDsFreqs.values).maxElement()!
            let radiusFactor = (maxRadius - minRadius) / Double(maxFreq)
            
            for idx in 0 ... circles.count - 1 {
                let circle = circles[idx]
                
                if let freq = IDsFreqs[circle.id] {
                    let r = minRadius + Double(freq) * radiusFactor
                    
                    str +=
                        "  <circle\n"                        +
                        "    class=\"congr-distr-center\"\n" +
                        "    id=\"\(circle.id)\"\n"          +
                        "    cx=\"\(circle.cx)\"\n"          +
                        "    cy=\"\(circle.cy)\"\n"          +
                        "    r=\"\(r)\" />"
                    
                    if idx < circles.count - 1 {
                        str += "\n"
                    }
                }
            }
            
            return str
        }
        
        var SVG =
        "<?xml version=\"1.0\"?>\n"                +
        "<svg\n"                                   +
        "  xmlns=\"http://www.w3.org/2000/svg\"\n" +
        "  version=\"1.0\"\n"                      +
        "  width=\"1241.7317\"\n"                  +
        "  height=\"720.55206\">\n"                +
        "  <style>\n"                              +
        "    path.map {\n"                         +
        "      fill: \(mapFillColor);\n"           +
        "    }\n"                                  +
        "    circle.congr-distr-center {\n"        +
        "      fill: \(circleFillColor);\n"        +
        "    }\n"                                  +
        "  </style>\n"                             +
        getPaths()                                 +
        "\n"
        
        if let circles = getCircles() {
            SVG += circles + "\n"
        }
        
        SVG += "</svg>"
        
        
        
        let dirs = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        
        if let docsDir = dirs.first {
            let path = docsDir + "/map.svg"
            var error: NSError? = nil
            
            do {
                try SVG.writeToFile(
                    path
                ,   atomically: true
                ,   encoding: NSUTF8StringEncoding
                )
            } catch let error1 as NSError {
                error = error1
            }
            
            if let err = error {
                print(err)
                
                return nil
            }
            
            return path
        }
        
        return nil
    }
    
    internal class func districtsCount() -> Int {
        return SVGMapData.congrDstrsCircles.count
    }
}
