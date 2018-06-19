//
//  LinkedToken_TableViewCell.swift
//  MiTokens
//
//  Created by Romain Penchenat on 23/05/2018.
//  Copyright © 2018 Romain Penchenat. All rights reserved.
//

import UIKit

class LinkedToken_TableViewCell: UITableViewCell {

    @IBOutlet weak var ui_amountLabel: Important_label!
    @IBOutlet weak var ui_priceLabel: Body_label!
    @IBOutlet weak var ui_linkLabel: Body_label!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
