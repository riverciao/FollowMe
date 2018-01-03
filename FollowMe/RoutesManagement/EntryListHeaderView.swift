//
//  EntryListHeaderView.swift
//  FollowMe
//
//  Created by riverciao on 2018/1/2.
//  Copyright © 2018年 riverciao. All rights reserved.
//

import UIKit

class EntryListHeaderView: UIView, Identifiable {

    // MARK: Property
    
    class var identifier: String { return String(describing: self) }
    
    @IBOutlet private(set) weak var titleLabel: UILabel!
    
    @IBOutlet private(set) weak var addButton: UIButton!
    
    // MARK: Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setUp()
        
    }
    
    // MARK: Set Up
    
    private func setUp() {
        
        self.backgroundColor = Palette.seaBlue
        
        titleLabel.text = ""
        titleLabel.textColor = .white
        titleLabel.font = UIFont(name: "ARCADECLASSIC", size: 36.0)
        
        addButton.setImage(
            UIImage(named: "icon_plus")!.withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        addButton.tintColor = .white
        
    }


}

// MARK: - Init

extension EntryListHeaderView {
    
    // swiftlint:disable force_cast
    class func create() -> EntryListHeaderView {
        
        return UIView.load(nibName: identifier) as! EntryListHeaderView
        
    }
    // swiftlint:enable force_cast
    
}

public protocol Identifiable {
    
    static var identifier: String { get }
    
}

public extension UIView {
    
    /**
     A convenience method loads a view from local xib file.
     
     - Author: Roy Hsu
     
     - Parameter nibName: The name of xib file.
     
     - Parameter bundle: The bundle xib file located. Default is nil.
     
     - Returns: The view instance.
     */
    
    public class func load(nibName name: String, bundle: Bundle? = nil) -> UIView? {
        
        return UINib.load(nibName: name, bundle: bundle) as? UIView
        
    }
    
}

public extension UINib {
    
    /**
     A convenience method loads a local xib file.
     
     - Author: Roy Hsu
     
     - Parameter nibName: The name of xib file.
     
     - Parameter bundle: The bundle xib file located. Default is nil.
     
     - Returns: The loaded instance.
     */
    
    public class func load(nibName name: String, bundle: Bundle? = nil) -> Any? {
        
        return
            UINib(nibName: name, bundle: bundle)
                .instantiate(withOwner: nil, options: nil)
                .first
        
    }
    
}
