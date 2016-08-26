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
    var text = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
        textView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
        textView.leftAnchor.constraintEqualToAnchor(view.leftAnchor).active = true
        textView.rightAnchor.constraintEqualToAnchor(view.rightAnchor).active = true
        textView.backgroundColor = UIColor(red: 134/255, green: 36/255, blue: 27/255, alpha: 1)
        textView.allowsEditingTextAttributes = false
        textView.scrollEnabled = true
        textView.textColor = UIColor.blackColor()
        textView.text = text
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
