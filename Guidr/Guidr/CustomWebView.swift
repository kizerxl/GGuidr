//
//  CustomWebView.swift
//  Guidr
//
//  Created by Flatiron School on 8/15/16.
//  Copyright © 2016 roundSteel. All rights reserved.
//

import UIKit
import WebKit

class CustomWebView: UIView {
    
    weak var webView: WKWebView!
    var removeButton: UIButton!

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
        addWebViewConstraints()
        addRemoveButton()
    }
    
    func initialize() {
        webView = WKWebView(frame: CGRectZero)
    }
    
    func addWebViewConstraints() {
        addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.leftAnchor.constraintEqualToAnchor(self.leftAnchor).active = true
        webView.rightAnchor.constraintEqualToAnchor(self.rightAnchor).active = true
        webView.topAnchor.constraintEqualToAnchor(self.topAnchor).active = true
        webView.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor).active = true
    }
    
    func addRemoveButton() {
        removeButton = UIButton(frame: CGRectZero);
        addSubview(removeButton)
        removeButton.translatesAutoresizingMaskIntoConstraints = false
        removeButton.heightAnchor.constraintEqualToConstant(43).active = true
        removeButton.widthAnchor.constraintEqualToConstant(50).active = true
        removeButton.rightAnchor.constraintEqualToAnchor(self.rightAnchor, constant: -10).active = true
        removeButton.topAnchor.constraintEqualToAnchor(self.topAnchor, constant: 10).active = true
        removeButton.setImage((UIImage (named: "newX")) , forState: .Normal)
        removeButton.alpha = 0.7
        removeButton.addTarget(self.superview, action: #selector(CustomWebView.removeCustomWebView), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func removeCustomWebView() {
        removeFromSuperview()
    }

}
