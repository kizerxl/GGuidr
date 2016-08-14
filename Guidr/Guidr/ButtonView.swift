//
//  ButtonView.swift
//  Guidr
//
//  Created by Flatiron School on 8/13/16.
//  Copyright © 2016 roundSteel. All rights reserved.
//

import UIKit

class ButtonView: UIView {
    
    var realButtonView: UIView!
    
    @IBOutlet weak var xButton: UIButton!
    @IBOutlet weak var checkButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.initialize()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        self.initialize()
    }
    
    convenience init() {
        self.init(frame: CGRectZero)
        
        self.initialize()
    }
    
    private func initialize() {
        loadButtonXib()
        addConstraints()
    }
    
    private func loadButtonXib() {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "ButtonView", bundle: bundle)
        realButtonView = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        addSubview(realButtonView)
    }
    
    private func addConstraints() {
        //put constraints on the newly added view
        realButtonView.translatesAutoresizingMaskIntoConstraints = false
        realButtonView.leftAnchor.constraintEqualToAnchor(self.leftAnchor).active = true
        realButtonView.rightAnchor.constraintEqualToAnchor(self.rightAnchor).active = true
        realButtonView.topAnchor.constraintEqualToAnchor(self.topAnchor).active = true
        realButtonView.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor).active = true

    }

}
