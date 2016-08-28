//
//  SharedDisplayVC.swift
//  Guidr
//
//  Created by Flatiron School on 8/26/16.
//  Copyright © 2016 roundSteel. All rights reserved.
//

import UIKit

class SharedDisplayVC: UIViewController {

    var textView = UITextView(frame: CGRectZero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
        textView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
        textView.leftAnchor.constraintEqualToAnchor(view.leftAnchor).active = true
        textView.rightAnchor.constraintEqualToAnchor(view.rightAnchor).active = true
        textView.backgroundColor = UIColor(red: 218/255, green: 159/255, blue: 147/255, alpha: 1)
        textView.allowsEditingTextAttributes = false
        textView.scrollEnabled = true
        textView.textColor = UIColor.whiteColor()
        textView.font = UIFont(name: "Avenir Medium", size: 14)
        textView.textAlignment = .Center
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
