//
//  RoomCell.swift
//  Draft
//
//  Created by JSKeum on 2020/11/06.
//  Copyright © 2020 JSKeum. All rights reserved.
//

import UIKit

class RoomCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet var avatars: [UIImageView]!
    @IBOutlet weak var numOfParticipants: UILabel!
    
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var time: UILabel!
}
