//
//  CalendarVC.swift
//  Guidr
//
//  Created by Flatiron School on 8/18/16.
//  Copyright © 2016 roundSteel. All rights reserved.
//

import UIKit

class CalendarVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        print("Inside the calendar VC")
        let items = ["Going", "Not Going", "Conflicts"]

        view.backgroundColor = UIColor(red: 134/255, green: 36/255, blue: 27/255, alpha: 1)
        title = "Calendar"
        
        let customSC = UISegmentedControl(items: items)
        customSC.selectedSegmentIndex = 0
        
        let frame = UIScreen.mainScreen().bounds
        customSC.frame = CGRectMake(frame.minX + 10, frame.minY + 50,
                                    frame.width - 20, frame.height*0.1)
        customSC.addTarget(self, action: #selector(CalendarVC.testing(_:)), forControlEvents: .ValueChanged)
        
        view.addSubview(customSC)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func testing(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            view.backgroundColor = UIColor.blueColor()
        case 1:
            view.backgroundColor = UIColor.redColor()
        case 2:
            view.backgroundColor = UIColor.yellowColor()
        default: break
        
        }
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
