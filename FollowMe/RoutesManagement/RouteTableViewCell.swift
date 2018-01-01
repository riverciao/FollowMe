//
//  RouteTableViewCell.swift
//  FollowMe
//
//  Created by riverciao on 2017/12/29.
//  Copyright © 2017年 riverciao. All rights reserved.
//

import UIKit

class RouteTableViewCell: UITableViewCell {

    
    @IBOutlet weak var routeImageView: UIImageView!
    @IBOutlet weak var routeName: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var shareButtonOutlet: UIButton!
    @IBAction func shareButton(_ sender: Any) {
    }
    
    var indexPath = IndexPath()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.backgroundColor = Palette.mystic
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupRouteImageView()
        setupShareButtonOutlet()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupRouteImageView() {
        routeImageView.translatesAutoresizingMaskIntoConstraints = false
        routeImageView.layer.masksToBounds = true
        routeImageView.layer.cornerRadius = 15
    }
    
    func setupShareButtonOutlet() {
        let shareImage = #imageLiteral(resourceName: "icon-share")
        let tintedImage = shareImage.withRenderingMode(.alwaysTemplate)
        shareButtonOutlet.setImage(tintedImage, for: .normal)
        shareButtonOutlet.tintColor = Palette.abbey
    }
    
}
