//
//  CustomCell.swift
//  DappSign
//
//  Created by imandet on 07/04/15.
//  Copyright (c) 2015 DappSign. All rights reserved.
//

import UIKit

class CustomCell: UITableViewCell {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblParty: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    
    
    

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCell(strName: String,strTitle: String, strParty: String){
        self.lblName?.text  =  strName
        self.lblTitle?.text = strTitle
        self.lblParty?.text = strParty
        
        

    }

}
