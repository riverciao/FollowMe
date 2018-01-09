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
    
    /// fadeOut timer
    fileprivate var fadeOutTimer = Timer()
    /// showing timer
    fileprivate var showingTimer = Timer()
    
    
    /**
     Init view
     
     - parameter frame: view frame
     
     - returns: view
     */
    override init(frame: CGRect) {
        super.init(frame: frame)
        
//        var frame = self.bounds
//        frame.origin.y = frame.size.height
//        frame.size.height = 0
//        self.backgroundColor = UIColor.clear
    }
    
    /**
     Init view with wave color
     
     - parameter frame: view frame
     - parameter color: real wave color
     
     - returns: view
     */
    public convenience init(frame: CGRect, startingAlpha: CGFloat, showingTime: TimeInterval) {
        self.init(frame: frame)
        
        self.startingAlpha = startingAlpha
        self.showingTime = showingTime
        
        setupTimer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    private func setupTimer() {
        showingTimer = Timer.scheduledTimer(timeInterval: showingTime, target: self, selector: #selector(callFadeOutTimer), userInfo: nil, repeats: false)
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
