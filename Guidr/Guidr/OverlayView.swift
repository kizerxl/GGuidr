//
//  OverlayView.swift
//  TinderSwipeCardsSwift
//
//  Created by Gao Chao on 4/30/15.
//  Copyright (c) 2015 gcweb. All rights reserved.
//

import Foundation
import UIKit

enum GGOverlayViewMode {
    case GGOverlayViewModeLeft
    case GGOverlayViewModeRight
}
// let's tweak the colors, size
class OverlayView: UIView{
    var _mode: GGOverlayViewMode! = GGOverlayViewMode.GGOverlayViewModeLeft
    var imageView: UIImageView!
    var xValue: CGFloat!
    var yValue: CGFloat!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.redColor()
        imageView = UIImageView(image: UIImage(named: "smileYES"))
        imageView.contentMode = .ScaleAspectFit
        setCoords("left")
        imageView.frame = CGRectMake(xValue, yValue, 300, 300)
        self.addSubview(imageView)
    }
    
    func setMode(mode: GGOverlayViewMode) -> Void {
        if _mode == mode {
            return
        }
        _mode = mode
        
        if _mode == GGOverlayViewMode.GGOverlayViewModeLeft {
            setCoords("left")
            imageView.image = UIImage(named: "smileNO")
            self.backgroundColor = UIColor.redColor() //change overlay bg custom color here
            imageView.frame = CGRectMake(xValue, yValue, 300, 300)
            
        } else {
            setCoords()
            imageView.image = UIImage(named: "smileYES")
            self.backgroundColor = UIColor.greenColor() //change overlay bg custom color here
            imageView.frame = CGRectMake(xValue, yValue, 300, 300)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }

    // I want to refactor this...
    func setCoords(direction: String = "right") {
        
        if direction == "left" {
            xValue = 0
            yValue = 0
        }
        else {
            xValue = 0 + imageView.frame.width/4
            yValue = 0
        }
    }
    
    
    
    
    
    
    
    
    
    
}