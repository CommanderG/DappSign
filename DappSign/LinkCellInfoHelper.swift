//
//  LinkCellInfoHelper.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 2/25/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import Foundation

enum LinkCellType {
    case AddLink
    case EnterLink
    case Link
    case DeleteLink
}

struct LinkCellInfo {
    var row:  Int
    var link: Link?
    var type: LinkCellType
}

class LinkCellInfoHelper {
    internal class func linkCellInfoWithRow(
        row: Int,
        linkCellsInfo: [LinkCellInfo]
    ) -> LinkCellInfo? {
        for linkCellInfo in linkCellsInfo {
            if linkCellInfo.row == row {
                return linkCellInfo
            }
        }
        
        return nil
    }
    
    internal class func linkCellInfoWithType(
        type: LinkCellType,
        linkCellsInfo: [LinkCellInfo]
    ) -> LinkCellInfo? {
        for linkCellInfo in linkCellsInfo {
            if linkCellInfo.type == type {
                return linkCellInfo
            }
        }
        
        return nil
    }
    
    internal class func countLinkCellsInfoWithType(
        type: LinkCellType,
        linkCellsInfo: [LinkCellInfo]
    ) -> Int {
        var count = 0
        
        for linkCellInfo in linkCellsInfo {
            if linkCellInfo.type == type {
                ++count
            }
        }
        
        return count
    }
    
    internal class func deleteLinkCellInfoWithRow(
        row: Int,
        linkCellsInfo: [LinkCellInfo]
    ) -> [LinkCellInfo] {
        let newLinkCellsInfo = linkCellsInfo.filter({
            if $0.row == row {
                return false
            }
            
            return true
        })
        
        return newLinkCellsInfo
    }
    
    internal class func replaceLinkCellInfoWithRow(
        existingLinkCellInfoRow: Int,
        withLinkCellInfo newLinkCellInfo: LinkCellInfo,
        linkCellsInfo: [LinkCellInfo]
    ) -> [LinkCellInfo] {
        var newLinkCellsInfo = self.deleteLinkCellInfoWithRow(
            existingLinkCellInfoRow,
            linkCellsInfo: linkCellsInfo
        )
        
        newLinkCellsInfo.append(newLinkCellInfo)
        
        return newLinkCellsInfo
    }
    
    internal class func linkCellInfoWithMinRowGreaterThan(
        minRow: Int,
        linkCellsInfo: [LinkCellInfo]
    ) -> LinkCellInfo? {
        let linkCellsInfoFilteredByRow = linkCellsInfo.filter({
            if $0.row > minRow {
                return true
            }
            
            return false
        })
        
        var filteredLinkCellInfoWithMinRow = linkCellsInfoFilteredByRow.first
        
        if filteredLinkCellInfoWithMinRow != nil {
            for filteredLinkCellInfo in linkCellsInfoFilteredByRow {
                if filteredLinkCellInfo.row < filteredLinkCellInfoWithMinRow!.row {
                    filteredLinkCellInfoWithMinRow = filteredLinkCellInfo
                }
            }
        }
        
        return filteredLinkCellInfoWithMinRow
    }
    
    internal class func normalizeLinkCellsInfoByRows(
        linkCellsInfo: [LinkCellInfo]
    ) -> [LinkCellInfo] {
        var newLinkCellsInfo: [LinkCellInfo] = []
        
        for row in 0 ... linkCellsInfo.count - 1 {
            let existingLinkCellInfoWithCurrentRow = linkCellInfoWithRow(row,
                linkCellsInfo: linkCellsInfo
            )
            let linkCellInfoWithMinRowGreaterThanCurrentRow = linkCellInfoWithMinRowGreaterThan(row,
                linkCellsInfo: linkCellsInfo
            )
            
            if let existingLinkCellInfoWithCurrentRow = existingLinkCellInfoWithCurrentRow {
                newLinkCellsInfo.append(existingLinkCellInfoWithCurrentRow)
            } else if let existingLinkCellInfo = linkCellInfoWithMinRowGreaterThanCurrentRow {
                let newLinkCellInfo = LinkCellInfo(
                    row:  row,
                    link: existingLinkCellInfo.link,
                    type: existingLinkCellInfo.type
                )
                
                newLinkCellsInfo.append(newLinkCellInfo)
            } else {
                print("???. row = \(row), = \(linkCellsInfo)")
            }
        }
        
        return newLinkCellsInfo
    }
    
    internal class func inserLinkCellInfo(
        newLinkCellInfo: LinkCellInfo,
        linkCellsInfo: [LinkCellInfo]
    ) -> [LinkCellInfo] {
        var newLinkCellsInfo = linkCellsInfo.map({
            linkCellInfo -> LinkCellInfo in
            if linkCellInfo.row < newLinkCellInfo.row {
                return linkCellInfo
            } else {
                let linkCellInfoWithNewRow = LinkCellInfo(
                    row:  linkCellInfo.row + 1,
                    link: linkCellInfo.link,
                    type: linkCellInfo.type
                )
                
                return linkCellInfoWithNewRow
            }
        })
        
        newLinkCellsInfo.append(newLinkCellInfo)
        
        return newLinkCellsInfo
    }
}
