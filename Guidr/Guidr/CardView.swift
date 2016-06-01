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
        let screenHeight = UIScreen.mainScreen().bounds.height
        let screenWidth = UIScreen.mainScreen().bounds.width
        self.frame.size = CGSize(width: screenWidth*3/4, height: screenHeight*1/3)
        
        // Colors: silver background, purple text
        self.backgroundColor = UIColor.init(red: 189/255, green: 195/255, blue: 199/255, alpha: 1)
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
        
        // Add labels
        var heightCoord = 0
        var widthCoord = 0
    

        for label: UILabel in [titleLabel, dateLabel, locationLabel, descriptionLabel] {
            self.addSubview(label)
            //label.frame = CGRect(origin: CGPoint((x: heightCoord += 10,  y: widthCoord += 10), size: CGSize(width: 150, height: 30))
            label.frame = CGRect(origin: CGPoint(x: heightCoord + 10, y: widthCoord + 10), size: CGSize(width: 150, height: 30))
            heightCoord += 10
            widthCoord += 10
            
        }
        
        
    }


}
