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
    
    lazy var routeNameTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = .blue
        textField.text = "123"
        textField.font = UIFont.systemFont(ofSize: 20)
        textField.textColor = .white
        return textField
    }()
    
    lazy var saveButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .red
        return button
    }()
    
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
        setupRouteNameTextField()
        setupSaveButton()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupRoutesLabel() {
        routeName.titleLabel?.font = UIFont(name: "ChalkboardSE-Regular", size: 22)
        distance.font = UIFont(name: "ChalkboardSE-Regular", size: 17)
    }
    
    func setupRouteNameTextField() {
        self.contentView.addSubview(routeNameTextField)
        
        routeNameTextField.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10).isActive = true
        routeNameTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        routeNameTextField.widthAnchor.constraint(equalToConstant: 100).isActive = true
        routeNameTextField.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        routeNameTextField.addTarget(self, action: #selector(showSaveButton), for: .editingDidBegin)
        routeNameTextField.addTarget(self, action: #selector(hideSaveButton), for: .editingDidEnd)
    }
    
    func setupSaveButton() {
        self.contentView.addSubview(saveButton)
        
        saveButton.rightAnchor.constraint(equalTo: routeNameTextField.leftAnchor, constant: -5).isActive = true
        saveButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        saveButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
        saveButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        saveButton.isHidden = true
    }
    
    @objc func showSaveButton() {
        saveButton.isHidden = false
    }
    
    @objc func hideSaveButton() {
        saveButton.isHidden = true
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

