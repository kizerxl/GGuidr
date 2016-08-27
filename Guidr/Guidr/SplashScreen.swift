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
    var animate = true
    var circleView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        animateGary()
    }

    func setup() {
        view.backgroundColor = UIColor(red: 134/255, green: 36/255, blue: 27/255, alpha: 1)
        splashImage.image = UIImage(named: "garyNewStartImg1")
        splashImage.contentMode = .ScaleAspectFit;
        splashImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(splashImage)
        
        splashImage.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        splashImage.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor).active = true

        //fix the constraints and set aspect ratio correctly 
        splashImage.heightAnchor.constraintEqualToConstant(131.0).active = true
        splashImage.widthAnchor.constraintEqualToConstant(161.0).active = true
        
        circleView = UIView(frame: CGRectZero)
        view.insertSubview(circleView, belowSubview: splashImage)
        
        //put constraints on the circle view
        circleView.translatesAutoresizingMaskIntoConstraints = false
        circleView.centerXAnchor.constraintEqualToAnchor(splashImage.centerXAnchor).active = true
        circleView.centerYAnchor.constraintEqualToAnchor(splashImage.centerYAnchor).active = true
        circleView.heightAnchor.constraintEqualToConstant(200).active = true
        circleView.widthAnchor.constraintEqualToConstant(200).active = true
        
        //round the view
        circleView.layer.cornerRadius = 100
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func animateGary() {
        self.circleView.layer.masksToBounds = false
        
        UIView.animateWithDuration(0.5, delay: 0.5, options: .CurveEaseIn, animations: {
            self.circleView.layer.opacity = 1
            self.circleView.layer.addPulse({ builder in
                builder.borderColors = [UIColor.whiteColor().CGColor]
                builder.repeatCount = 1
            })
            self.circleView.layer.opacity = 0
        }) { _ in
            
            if self.animate {
                self.animateGary()
            }
        }
        
    }
    
    deinit {
        print("The screen just went bye bye")
    }

}
