//
//  CardView.swift
//  Guidr
//
//  Created by Jeff Spingeld on 6/1/16.
//  Copyright © 2016 roundSteel. All rights reserved.
//

import UIKit

protocol DraggableViewDelegate {
    func cardSwipedLeft(card: CardView) -> Void
    func cardSwipedRight(card: CardView) -> Void
}

class CardView: UIView {
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventAddress: UILabel!
    @IBOutlet weak var eventDesc: UILabel!
    @IBOutlet weak var eventPrice: UILabel!
    @IBOutlet weak var eventDate: UILabel!
    @IBOutlet weak var eventTime: UILabel!
    
    var title: String
    var date: NSDate
    var location: String
    var eventDescription: String
    var originalPoint: CGPoint
    var customCardView: UIView!
    var urlString: String!
    
    @IBAction func moreInfoTapped(sender: AnyObject) {
        //open up the webview here 
        
    }
    
    //for tinder
    let ACTION_MARGIN: Float = 120      //%%% distance from center where the action applies. Higher = swipe further in order for the action to be called
    let SCALE_STRENGTH: Float = 4       //%%% how quickly the card shrinks. Higher = slower shrinking
    let SCALE_MAX:Float = 0.93          //%%% upper bar for how much the card shrinks. Higher = shrinks less
    let ROTATION_MAX: Float = 1         //%%% the maximum rotation allowed in radians.  Higher = card can keep rotating longer
    let ROTATION_STRENGTH: Float = 320  //%%% strength of rotation. Higher = weaker rotation
    let ROTATION_ANGLE: Float = 3.14/8  //%%% Higher = stronger rotation angle
    
    var delegate: DraggableViewDelegate!
    var panGestureRecognizer: UIPanGestureRecognizer!
    var originPoint: CGPoint!
    var overlayView: OverlayView!
    var information: UILabel!
    var xFromCenter: Float!
    var yFromCenter: Float!
    
    override init(frame: CGRect) {
  
        self.title = ""
        self.date = NSDate()
        self.location = ""
        self.eventDescription = ""
        self.originalPoint = CGPointMake(0, 0)
        
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.init(red: 189/255, green: 195/255, blue: 199/255, alpha: 1)
        self.panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(CardView.beingDragged(_:)))
        self.addGestureRecognizer(panGestureRecognizer)
        overlayView = OverlayView(frame: CGRectMake(self.frame.size.width/2-100, 0, 100, 100))
        overlayView.alpha = 0
        self.addSubview(overlayView)

        
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        self.title = ""
        self.date = NSDate()
        self.location = ""
        self.eventDescription = ""
        self.originalPoint = CGPointMake(0, 0)

        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.blackColor()
        
    }

    convenience init(title: String, date: NSDate, location: String, eventDescription: String) {
        
        // Call default initializer
        self.init(frame: CGRectZero)
        
        // Set properties
        self.title = title
        self.date = date
        self.location = location
        self.eventDescription = eventDescription

        
//        setup() < --- for running the old test card
        addCardView()
    }
    
    // This uses an event object as an array
    convenience init(event: [String]) {
        self.init(frame: CGRectZero)
        
        addCardView()
        
        /*
         So the eventCount can be either 6 or 7 
         if it's 6 that means that there is no description and the urlString is at idx 3
         else if it's 7 there is a description and the urlString is at idx 4
        */
        
        var eventCopy = event
        let eventCount = eventCopy.count
        var eventDetails = [eventDate, eventTitle, eventAddress, eventDesc, eventPrice, eventTime]

        // There is no description
        if eventCount == 6 {
            urlString = eventCopy.removeAtIndex(3)
            eventDetails[3].text = "No Description"
            eventDetails.removeAtIndex(3)
        } else {
            urlString = eventCopy.removeAtIndex(4)
        }
        
        for i in 0..<eventDetails.count {
            eventDetails[i].text = eventCopy[i]
        }
 
    }
    
    
    func setup() {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        // Height and width
        let screenHeight = UIScreen.mainScreen().bounds.height
        let screenWidth = UIScreen.mainScreen().bounds.width
        self.heightAnchor.constraintEqualToConstant(screenHeight * 0.50).active = true
        self.widthAnchor.constraintEqualToConstant(screenWidth * 0.90).active = true
        
        // Colors: silver background, purple text
//        self.backgroundColor = UIColor.init(red: 189/255, green: 195/255, blue: 199/255, alpha: 1)
        
        //make a black outline for the card + clear bg
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.greenColor().CGColor
        self.backgroundColor = UIColor.redColor()
//        self.backgroundColor = UIColor(patternImage: UIImage(named:"YES")!)
        
        let textColor = UIColor.blackColor()
        
        // Rounded corners
        self.layer.cornerRadius = screenHeight * 1/3 * 0.1
        
        // Create labels
        
        // title
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = textColor
        titleLabel.font = UIFont(name: "Copperplate", size: 35)
        titleLabel.textAlignment = .Center
        
       
        // date
        let dateLabel = UILabel()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "• EEEE, MMMM d, Y •"
        dateLabel.text = dateFormatter.stringFromDate(date)
        dateLabel.textAlignment = .Center
        dateLabel.font = UIFont(name: "Avenir-Light", size: 15)
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
        let labelHeightDistance = 10 as CGFloat
        let labels = [titleLabel, dateLabel, locationLabel, descriptionLabel]
        
        var previousLabel: UILabel!
        
        for label: UILabel in labels {
            
            self.addSubview(label)
            
            label.translatesAutoresizingMaskIntoConstraints = false
            label.leftAnchor.constraintEqualToAnchor(self.leftAnchor, constant: 10).active = true
            label.rightAnchor.constraintEqualToAnchor(self.rightAnchor, constant: -20).active = true
            label.numberOfLines = 0
            label.lineBreakMode = .ByWordWrapping
            label.enabled = true
            label.textColor = UIColor.whiteColor()
            
            if label == labels.first! {
                label.topAnchor.constraintEqualToAnchor(self.topAnchor, constant: labelHeightDistance).active = true
            }
            else{
                label.topAnchor.constraintEqualToAnchor(previousLabel.bottomAnchor, constant: labelHeightDistance).active = true
            }
            
            previousLabel = label
        
        }
        
        //add more info button here or so?
        
       
        layoutIfNeeded()
        
        
        overlayView = OverlayView(frame: CGRectMake(self.frame.size.width/2-100, 0, 100, 100))
        overlayView.alpha = 0
        self.addSubview(overlayView)
        
        xFromCenter = 0
        yFromCenter = 0
        
        
    }
    
    func beingDragged(gestureRecognizer: UIPanGestureRecognizer) -> Void {
        xFromCenter = Float(gestureRecognizer.translationInView(self).x)
        yFromCenter = Float(gestureRecognizer.translationInView(self).y)
        
        switch gestureRecognizer.state {
        case UIGestureRecognizerState.Began:
            self.originPoint = self.center
        case UIGestureRecognizerState.Changed:
            let rotationStrength: Float = min(xFromCenter/ROTATION_STRENGTH, ROTATION_MAX)
            let rotationAngle = ROTATION_ANGLE * rotationStrength
            let scale = max(1 - fabsf(rotationStrength) / SCALE_STRENGTH, SCALE_MAX)
            
            self.center = CGPointMake(self.originPoint.x + CGFloat(xFromCenter), self.originPoint.y + CGFloat(yFromCenter))
            
            let transform = CGAffineTransformMakeRotation(CGFloat(rotationAngle))
            let scaleTransform = CGAffineTransformScale(transform, CGFloat(scale), CGFloat(scale))
            self.transform = scaleTransform
            self.updateOverlay(CGFloat(xFromCenter))
        case UIGestureRecognizerState.Ended:
            self.afterSwipeAction()
        case UIGestureRecognizerState.Possible:
            fallthrough
        case UIGestureRecognizerState.Cancelled:
            fallthrough
        case UIGestureRecognizerState.Failed:
            fallthrough
        default:
            break
        }
    }
    
    func updateOverlay(distance: CGFloat) -> Void {
        if distance > 0 {
            overlayView.setMode(GGOverlayViewMode.GGOverlayViewModeRight)
        } else {
            overlayView.setMode(GGOverlayViewMode.GGOverlayViewModeLeft)
        }
        overlayView.alpha = CGFloat(min(fabsf(Float(distance))/100, 0.4))
    }
    
    func afterSwipeAction() -> Void {
        let floatXFromCenter = Float(xFromCenter)
        if floatXFromCenter > ACTION_MARGIN {
            self.actionForDirection("right")
        } else if floatXFromCenter < -ACTION_MARGIN {
            self.actionForDirection("left")
        } else {
            UIView.animateWithDuration(0.3, animations: {() -> Void in
                self.center = self.originPoint
                self.transform = CGAffineTransformMakeRotation(0)
                self.overlayView.alpha = 0
                self.layoutIfNeeded()
            })
        }
    }
    
    func actionForDirection(direction: String) {
       UIView.animateWithDuration(0.5) {
            self.removeFromSuperview()
        }
        
        if direction == "left" {
            delegate.cardSwipedLeft(self)
        }
        else {
            delegate.cardSwipedRight(self)
        }
    }

    func rightClickAction() -> Void {
        let transform = CGAffineTransformMakeRotation(CGFloat(ROTATION_MAX * 0.75))
        let scaleTransform = CGAffineTransformScale(transform, CGFloat(SCALE_MAX), CGFloat(SCALE_MAX))
        
        UIView.animateKeyframesWithDuration(0.5, delay: 0, options: [], animations: {
            
            UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0.5) {
                self.transform = scaleTransform
                self.center.x += self.center.x
                self.center.y -= self.center.y
                self.alpha = 0
                self.layoutIfNeeded()
            }
            
        }) { (value: Bool) in
            self.removeFromSuperview()
        }
        delegate.cardSwipedRight(self)
    }
    
    func leftClickAction() -> Void {
        let transform = CGAffineTransformMakeRotation(CGFloat(ROTATION_MAX * 0.75))
        let scaleTransform = CGAffineTransformScale(transform, CGFloat(SCALE_MAX), CGFloat(SCALE_MAX))
        
        UIView.animateKeyframesWithDuration(0.5, delay: 0, options: [], animations: {
            
            UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0.5) {
                self.transform = scaleTransform
                self.center.x -= self.center.x
                self.center.y -= self.center.y
                self.alpha = 0
                self.layoutIfNeeded()
            }
            
        }) { (value: Bool) in
            self.removeFromSuperview()
        }
        delegate.cardSwipedLeft(self)
    }
    
    func addCardView() {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "CardView", bundle: bundle)
        customCardView = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        addSubview(customCardView)
        
        //put constraints on the newly added view
        customCardView.translatesAutoresizingMaskIntoConstraints = false
        customCardView.leftAnchor.constraintEqualToAnchor(self.leftAnchor).active = true
        customCardView.rightAnchor.constraintEqualToAnchor(self.rightAnchor).active = true
        customCardView.topAnchor.constraintEqualToAnchor(self.topAnchor).active = true
        customCardView.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor).active = true
        
    }

}
