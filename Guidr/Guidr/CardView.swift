//
//  CardView.swift
//  Guidr
//
//  Created by Jeff Spingeld on 6/1/16.
//  Copyright © 2016 roundSteel. All rights reserved.
//

import UIKit

class CardView: UIView {
    
    var title: String
    var date: NSDate
    var location: String
    var eventDescription: String
    
    override init(frame: CGRect) {
  
        self.title = ""
        self.date = NSDate()
        self.location = ""
        self.eventDescription = ""
        
        super.init(frame: frame)
        
        setup()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        self.title = ""
        self.date = NSDate()
        self.location = ""
        self.eventDescription = ""
        
        super.init(coder: aDecoder)
        
        setup()
        
    }

    convenience init(title: String, date: NSDate, location: String, eventDescription: String) {
        
        // Call default initializer
        self.init(frame: CGRectZero)
        
        // Set properties
        self.title = title
        self.date = date
        self.location = location
        self.eventDescription = eventDescription
        
    }
    
    func setup() {
        
        
        // Height and width
        self.translatesAutoresizingMaskIntoConstraints = false

        let screenHeight = UIScreen.mainScreen().bounds.height
        let screenWidth = UIScreen.mainScreen().bounds.width
//        
//        self.heightAnchor.constraintEqualToConstant(screenHeight * 1/3)
//        self.widthAnchor.constraintEqualToConstant(screenWidth * 3/4)
        self.frame = CGRect(x: 0, y: 0, width: screenWidth*3/4, height: screenHeight*1/3)
        print("Frame is: \(self.frame)") // Frame is (0, 0, 0, 0). Why?
        
        // Colors: silver background, purple text
        self.backgroundColor = UIColor.init(red: 189, green: 195, blue: 199, alpha: 1)
        let textColor = UIColor.purpleColor()
        
        // Rounded corners
        self.layer.cornerRadius = screenHeight * 1/3 * 0.1
        
        // Create labels
        // title
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = textColor
       
        // date
        let dateLabel = UILabel()
        dateLabel.text = NSDateFormatter().stringFromDate(date)
        dateLabel.textColor = textColor
        
        // location
        let locationLabel = UILabel()
        locationLabel.text = location
        locationLabel.textColor = textColor
        
        
        // description
        let descriptionLabel = UILabel()
        descriptionLabel.text = eventDescription
        descriptionLabel.textColor = textColor
        
    }


}
