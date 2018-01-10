//
//  FadingOutView.swift
//  FollowMe
//
//  Created by riverciao on 2018/1/9.
//  Copyright © 2018年 riverciao. All rights reserved.
//

import UIKit

class FadingOutView: UIView {

    /// starting view alpha (default: 0.5)
    open var startingAlpha: CGFloat = 0.5 {
        didSet {
            self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: startingAlpha)
        }
    }
    /// view showing time (default: 5)
    open var showingTime: TimeInterval = 5 {
        didSet {
            showingTimer = Timer.scheduledTimer(timeInterval: showingTime, target: self, selector: #selector(callFadeOutTimer), userInfo: nil, repeats: false)
        }
    }
    /// view fading out time (default: 0.1)
    open var fadingTimeInterval: TimeInterval = 0.1
    /// view fading out alpha per viewFadingTimeInterval (default: 0.1)
    open var viewFadingOutAlpha: CGFloat = 0.1
    /// cornerRadius of fade out view (default: 10)
    open var cornerRadius: CGFloat = 10 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    /// notice label text that shows on fading out view
    open var noticeText: String = "" {
        didSet {
            noticeLabel.text = noticeText
        }
    }
    /// font size of notice label text (default: 18)
    open var noticeTextFontSize: CGFloat = 18 {
        didSet {
            noticeLabel.font = UIFont.systemFont(ofSize: noticeTextFontSize)
        }
    }
    
    /// fadeOut timer
    fileprivate var fadeOutTimer = Timer()
    /// showing timer
    fileprivate var showingTimer = Timer()
    /// noticeLabel
    fileprivate lazy var noticeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .white
        label.text = noticeText
        label.numberOfLines = 0
        return label
    }()
    
    
    /**
     Init view with fade out effect
     
     - parameter frame: view frame
     - parameter startingAlpha: alpha of the background color of fade out view(black)
     - parameter showingTime: fade out view will last for this period of time
     - parameter noticeText: text on the fading out view. With default color(white) and default font(system). Can adjust font size by calling noticeTextFontSize
     
     - returns: view
     */
    init(frame: CGRect, startingAlpha: CGFloat, showingTime: TimeInterval, noticeText: String) {
        
        self.startingAlpha = startingAlpha
        self.showingTime = showingTime
        self.noticeText = noticeText
        
        super.init(frame: frame)
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: startingAlpha)
        self.layer.cornerRadius = cornerRadius
        setupNoticeLabel()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    ///Srart to show the Fade Out View
    open func start() {
        showingTimer = Timer.scheduledTimer(timeInterval: showingTime, target: self, selector: #selector(callFadeOutTimer), userInfo: nil, repeats: false)
    }
    
    private func setupNoticeLabel() {
        self.addSubview(noticeLabel)
        
        noticeLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        noticeLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        noticeLabel.widthAnchor.constraint(equalToConstant: self.bounds.width * 0.9).isActive = true
        noticeLabel.heightAnchor.constraint(equalToConstant: self.bounds.height * 0.9).isActive = true
    }

    @objc private func callFadeOutTimer() {
        fadeOutTimer = Timer.scheduledTimer(timeInterval: fadingTimeInterval, target: self, selector: #selector(fadeOut), userInfo: nil, repeats: true)
    }

    @objc private func fadeOut() {

        if startingAlpha > 0 {
            startingAlpha -= viewFadingOutAlpha
            self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: startingAlpha)
        } else if startingAlpha <= 0 {
            self.isHidden = true
            fadeOutTimer.invalidate()
        }
    }
    

}
