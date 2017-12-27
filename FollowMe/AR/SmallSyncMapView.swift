//
//  SmallSyncMapView.swift
//  FollowMe
//
//  Created by riverciao on 2017/12/27.
//  Copyright © 2017年 riverciao. All rights reserved.
//

import UIKit

class SmallSyncMapView: UIView {

    @IBOutlet var smallSyncMapView: UIView!
    @IBOutlet weak var testLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        
        Bundle.main.loadNibNamed("SmallSyncMapView", owner: self, options: nil)
        addSubview(smallSyncMapView)
        smallSyncMapView.frame = self.bounds
        smallSyncMapView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
    }

}
