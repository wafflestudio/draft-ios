//
//  RoomInfoTableViewCell.swift
//  draft
//
//  Created by JSKeum on 2020/07/13.
//  Copyright © 2020 JSKeum. All rights reserved.
//

import UIKit

class RoomInfoTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBOutlet weak var label: UILabel! {
        didSet {
            label.font = .systemFont(ofSize: 17)
        }
    }
    
}
