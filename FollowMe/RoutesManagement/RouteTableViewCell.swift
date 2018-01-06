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
    @IBOutlet weak var routeName: UIButton!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var shareButtonOutlet: UIButton!
    @IBAction func shareButton(_ sender: Any) {
    }
    @IBOutlet weak var bottomSeparatorLineView: UIView!
    
    var indexPath = IndexPath()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.backgroundColor = Palette.mystic
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupRouteImageView()
        setupShareButtonOutlet()
        setupRoutesLabel()
        setupBottomsSeparator()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupRoutesLabel() {
        routeName.titleLabel?.font = UIFont(name: "ChalkboardSE-Regular", size: 22)
        distance.font = UIFont(name: "ChalkboardSE-Regular", size: 17)
    }
    
    func setupBottomsSeparator() {
        bottomSeparatorLineView.backgroundColor = Palette.silverSand
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
        shareButtonOutlet.tintColor = Palette.duckBeak
    }
    
}

