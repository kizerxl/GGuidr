//
//  SplashScreen.swift
//  Guidr
//
//  Created by Flatiron School on 8/4/16.
//  Copyright © 2016 roundSteel. All rights reserved.
//

import UIKit


class SplashScreen: UIViewController {
    
    var splashImage = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        animateGary()
    }

    func setup() {
        view.backgroundColor = UIColor(red: 134/255, green: 36/255, blue: 27/255, alpha: 1)
        splashImage.image = UIImage(named: "garyStartImage")
        splashImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(splashImage)
        
        splashImage.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        splashImage.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor).active = true

        splashImage.heightAnchor.constraintEqualToConstant(234.0)
        splashImage.widthAnchor.constraintEqualToConstant(200.0)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func animateGary() {
        splashImage.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = false
        splashImage.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor).active = false
        
        UIView.animateWithDuration(1, delay: 0.1, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: .CurveEaseInOut, animations: {
            self.splashImage.transform = CGAffineTransformMakeScale(1.3, 1.3)
            
        }) { _ in
            self.splashImage.transform = CGAffineTransformIdentity
            self.splashImage.layer.addPulse { builder in
                builder.borderColors = [UIColor.whiteColor().CGColor]
                builder.backgroundColors = []
            }
            
            self.animateGary()
            
        }
    }

}
