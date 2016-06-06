//
//  CardView.swift
//  Guidr
//
//  Created by Jeff Spingeld on 6/1/16.
//  Copyright © 2016 roundSteel. All rights reserved.
//

import UIKit

protocol DraggableViewDelegate {
    func cardSwipedLeft(card: UIView) -> Void
    func cardSwipedRight(card: UIView) -> Void
}

class CardView: UIView {
    
    var title: String
    var date: NSDate
    var location: String
    var eventDescription: String
    var originalPoint: CGPoint
    
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
//    var overlayView: OverlayView!
    var information: UILabel!
    var xFromCenter: Float!
    var yFromCenter: Float!
    
    override init(frame: CGRect) {
  
        self.title = ""
        self.date = NSDate()
        self.location = ""
        self.eventDescription = ""
        
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        self.title = ""
        self.date = NSDate()
        self.location = ""
        self.eventDescription = ""
        
        super.init(coder: aDecoder)
        
    }

    convenience init(title: String, date: NSDate, location: String, eventDescription: String) {
        
        // Call default initializer
        self.init(frame: CGRectZero)
        
        // Set properties
        self.title = title
        self.date = date
        self.location = location
        self.eventDescription = eventDescription
        
        setup()
        
    }
    
    func setup() {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        // Height and width
        let screenHeight = UIScreen.mainScreen().bounds.height
        let screenWidth = UIScreen.mainScreen().bounds.width
        self.heightAnchor.constraintEqualToConstant(screenHeight * 1/3).active = true
        self.widthAnchor.constraintEqualToConstant(screenWidth * 3/4).active = true
        
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
        var heightThing = 0 as CGFloat
        var widthCoord = 10 as CGFloat
        let labels = [titleLabel, dateLabel, locationLabel, descriptionLabel]
        
        for label: UILabel in labels {
            
            self.addSubview(label)

            label.translatesAutoresizingMaskIntoConstraints = false
            label.leftAnchor.constraintEqualToAnchor(self.leftAnchor, constant: 10).active = true
            label.topAnchor.constraintEqualToAnchor(self.topAnchor, constant: widthCoord).active = true
            
            if label == labels.first! {
                print("this should only print once")
                var heightThing = label.frame.height
            }
            
            
            widthCoord += heightThing + 20.0
            
        
        }
       
        layoutIfNeeded()
        
        
    }

//    func dragged(gestureRecognizer: UIPanGestureRecognizer){
////        
////        case Possible // the recognizer has not yet recognized its gesture, but may be evaluating touch events. this is the default state
////        
////        case Began // the recognizer has received touches recognized as the gesture. the action method will be called at the next turn of the run loop
////        case Changed // the recognizer has received touches recognized as a change to the gesture. the action method will be called at the next turn of the run loop
////        case Ended // the recognizer has received touches recognized as the end of the gesture. the action method will be called at the next turn of the run loop and the recognizer will be reset to UIGestureRecognizerStatePossible
////        case Cancelled // the recognizer has received touches resulting in the cancellation of the gesture. the action method will be called at the next turn of the run loop. the recognizer will be reset to UIGestureRecognizerStatePossible
////        
////        case Failed
//
//        
//        let xMove = gestureRecognizer.translationInView(self).x
//        let yMove = gestureRecognizer.translationInView(self).y
//        
//        switch gestureRecognizer.state {
//        case .Began :
//            self.originalPoint = self.center
//        case .Changed :
//            var rotationStrength = min(xMove/320, 1)
//        default:
//            <#code#>
//        }
//
//    
//    }
    
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
//            self.updateOverlay(CGFloat(xFromCenter))
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
    
//    func updateOverlay(distance: CGFloat) -> Void {
//        if distance > 0 {
//            overlayView.setMode(GGOverlayViewMode.GGOverlayViewModeRight)
//        } else {
//            overlayView.setMode(GGOverlayViewMode.GGOverlayViewModeLeft)
//        }
//        overlayView.alpha = CGFloat(min(fabsf(Float(distance))/100, 0.4))
//    }
    
    func afterSwipeAction() -> Void {
        let floatXFromCenter = Float(xFromCenter)
        if floatXFromCenter > ACTION_MARGIN {
            self.rightAction()
        } else if floatXFromCenter < -ACTION_MARGIN {
            self.leftAction()
        } else {
            UIView.animateWithDuration(0.3, animations: {() -> Void in
                self.center = self.originPoint
                self.transform = CGAffineTransformMakeRotation(0)
//                self.overlayView.alpha = 0
            })
        }
    }
    
    func rightAction() -> Void {
        let finishPoint: CGPoint = CGPointMake(500, 2 * CGFloat(yFromCenter) + self.originPoint.y)
        UIView.animateWithDuration(0.3,
                                   animations: {
                                    self.center = finishPoint
            }, completion: {
                (value: Bool) in
                self.removeFromSuperview()
        })
        delegate.cardSwipedRight(self)
    }
    
    func leftAction() -> Void {
        let finishPoint: CGPoint = CGPointMake(-500, 2 * CGFloat(yFromCenter) + self.originPoint.y)
        UIView.animateWithDuration(0.3,
                                   animations: {
                                    self.center = finishPoint
            }, completion: {
                (value: Bool) in
                self.removeFromSuperview()
        })
        delegate.cardSwipedLeft(self)
    }
    
    func rightClickAction() -> Void {
        let finishPoint = CGPointMake(600, self.center.y)
        UIView.animateWithDuration(0.3,
                                   animations: {
                                    self.center = finishPoint
                                    self.transform = CGAffineTransformMakeRotation(1)
            }, completion: {
                (value: Bool) in
                self.removeFromSuperview()
        })
        delegate.cardSwipedRight(self)
    }
    
    func leftClickAction() -> Void {
        let finishPoint: CGPoint = CGPointMake(-600, self.center.y)
        UIView.animateWithDuration(0.3,
                                   animations: {
                                    self.center = finishPoint
                                    self.transform = CGAffineTransformMakeRotation(1)
            }, completion: {
                (value: Bool) in
                self.removeFromSuperview()
        })
        delegate.cardSwipedLeft(self)
    }
    
}
