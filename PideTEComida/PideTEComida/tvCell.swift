//
//  tvCell.swift
//  PideTEComida
//
//  Created by Aldo Reyna Gomez on 11/20/17.
//  Copyright © 2017 Aldo Reyna Gomez. All rights reserved.
//

import UIKit

class tvCell: UITableViewCell {

    @IBOutlet weak var tvComida: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
