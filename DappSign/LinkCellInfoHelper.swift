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
                count += 1
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
    
    internal class func linkCellInfoWithMinRow(linkCellsInfo: [LinkCellInfo]) -> LinkCellInfo? {
        var linkCellInfoWithMinRow = linkCellsInfo.first
        
        if linkCellInfoWithMinRow != nil {
            for linkCellInfo in linkCellsInfo {
                if linkCellInfo.row < linkCellInfoWithMinRow!.row {
                    linkCellInfoWithMinRow = linkCellInfo
                }
            }
        }
        
        return linkCellInfoWithMinRow
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
        // TODO: refactor
        var updatedLinkCellsInfo = linkCellsInfo
        
        if let linkCellInfoWithMinRow = self.linkCellInfoWithMinRow(linkCellsInfo) {
            if linkCellInfoWithMinRow.row > 0 {
                updatedLinkCellsInfo = updatedLinkCellsInfo.map({
                    linkCellInfo -> LinkCellInfo in
                    let newLinkCellInfoRow = linkCellInfo.row - linkCellInfoWithMinRow.row
                    
                    let newLinkCellInfo = LinkCellInfo(
                        row:  newLinkCellInfoRow,
                        link: linkCellInfo.link,
                        type: linkCellInfo.type
                    )
                    
                    return newLinkCellInfo
                })
            }
        }
        
        var newLinkCellsInfo: [LinkCellInfo] = []
        let maxRow = updatedLinkCellsInfo.count - 1
        
        for row in 0 ... maxRow {
            let existingLinkCellInfoWithCurrentRow = linkCellInfoWithRow(row,
                linkCellsInfo: updatedLinkCellsInfo
            )
            let linkCellInfoWithMinRowGreaterThanCurrentRow = linkCellInfoWithMinRowGreaterThan(row,
                linkCellsInfo: updatedLinkCellsInfo
            )
            
            if let existingLinkCellInfoWithCurrentRow = existingLinkCellInfoWithCurrentRow {
                newLinkCellsInfo.append(existingLinkCellInfoWithCurrentRow)
                
                updatedLinkCellsInfo = self.deleteLinkCellInfoWithRow(row,
                    linkCellsInfo: updatedLinkCellsInfo
                )
            } else if let existingLinkCellInfo = linkCellInfoWithMinRowGreaterThanCurrentRow {
                updatedLinkCellsInfo = self.deleteLinkCellInfoWithRow(existingLinkCellInfo.row,
                    linkCellsInfo: updatedLinkCellsInfo
                )
                
                let newLinkCellInfo = LinkCellInfo(
                    row:  row,
                    link: existingLinkCellInfo.link,
                    type: existingLinkCellInfo.type
                )
                
                newLinkCellsInfo.append(newLinkCellInfo)
            } else {
                print("???. row = \(row), = \(updatedLinkCellsInfo)")
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
