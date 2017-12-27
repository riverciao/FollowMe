//
//  LocationSearchTableViewCell.swift
//  FollowMe
//
//  Created by riverciao on 2017/12/27.
//  Copyright © 2017年 riverciao. All rights reserved.
//

import UIKit

class LocationSearchTableViewCell: UITableViewCell {

    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var pinImageView: UIImageView!
    @IBOutlet weak var distanceLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        pinImageView.image = #imageLiteral(resourceName: "pin")
        pinImageView.contentMode = .scaleAspectFit
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
