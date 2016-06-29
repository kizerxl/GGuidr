//
//  DraggableViewBackground.swift
//  TinderSwipeCardsSwift
//
//  Created by Gao Chao on 4/30/15.
//  Copyright (c) 2015 gcweb. All rights reserved.
//

import Foundation
import UIKit

protocol CalendarDelegate {
    func addEventToCalendar(card:CardView)
}

class DraggableViewBackground: UIView, DraggableViewDelegate {
    var cardContentArray: [[String]]!
    var allCards: [CardView]!
    
    let MAX_BUFFER_SIZE = 2
    let CARD_HEIGHT: CGFloat = 386
    let CARD_WIDTH: CGFloat = 290
    
    var cardsLoadedIndex: Int!
    var loadedCards: [CardView]!
    var menuButton: UIButton!
    var messageButton: UIButton!
    var checkButton: UIButton!
    var xButton: UIButton!
    var calDelegate: CalendarDelegate!
    
    
    var calendarOfCurrentYear: NSCalendar!
    var currentDate: NSDate!
    var currentMonth: Int!
    var currentYear: Int!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("start loading this bitch up")

        super.layoutSubviews()
        self.setupView()
        self.setupDateChecking()
        allCards = []
        loadedCards = []
        cardContentArray = []
        print("MIDWAY loading this bitch up")
        cardsLoadedIndex = 0
//        self.loadCards()
        print("end loading this bitch up")

    }
    
    convenience init(){
 
        self.init(frame: CGRect.zero)
        
        let screenHeight = UIScreen.mainScreen().bounds.height
        let screenWidth = UIScreen.mainScreen().bounds.width
        self.heightAnchor.constraintEqualToConstant(screenHeight).active = true
        self.widthAnchor.constraintEqualToConstant(screenWidth).active = true

    }
        
        
        
    
    func setupView() -> Void {
//        self.backgroundColor = UIColor.whiteColor()
        self.backgroundColor = UIColor.purpleColor()

//
//        xButton = UIButton(frame: CGRectMake((self.frame.size.width - CARD_WIDTH)/2 + 35, self.frame.size.height/2 + CARD_HEIGHT/2 + 10, 100, 75))
//        xButton.setImage(UIImage(named: "xMark"), forState: UIControlState.Normal)
//        xButton.addTarget(self, action: "swipeLeft", forControlEvents: UIControlEvents.TouchUpInside)
//        
//        checkButton = UIButton(frame: CGRectMake(self.frame.size.width/2 + CARD_WIDTH/2 - 85, self.frame.size.height/2 + CARD_HEIGHT/2 + 10, 90, 75))
        
        xButton = UIButton()
        checkButton = UIButton()

        checkButton.setImage(UIImage(named: "newCheck"), forState: UIControlState.Normal)
        checkButton.addTarget(self, action: #selector(DraggableViewBackground.swipeRight), forControlEvents: UIControlEvents.TouchUpInside)
        
        xButton.setImage(UIImage(named: "newX"), forState: UIControlState.Normal)
        xButton.addTarget(self, action: #selector(DraggableViewBackground.swipeLeft), forControlEvents: UIControlEvents.TouchUpInside)
        
        self.addSubview(xButton)
        self.addSubview(checkButton)
        
        // check button constraints
        checkButton.translatesAutoresizingMaskIntoConstraints = false
//        checkButton.centerXAnchor.constraintEqualToAnchor(self.centerXAnchor, constant: checkButton.bounds.width).active = true
        checkButton.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor, constant: -100).active = true
        checkButton.widthAnchor.constraintEqualToConstant(100).active = true
        checkButton.heightAnchor.constraintEqualToConstant(86).active = true
        checkButton.rightAnchor.constraintEqualToAnchor(self.rightAnchor, constant: -100).active = true

        // x button constraints
        xButton.translatesAutoresizingMaskIntoConstraints = false
//        xButton.centerXAnchor.constraintEqualToAnchor(self.centerXAnchor, constant: -self.checkButton.bounds.width).active = true
        xButton.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor, constant: -100).active = true
        xButton.widthAnchor.constraintEqualToConstant(100).active = true
        xButton.heightAnchor.constraintEqualToConstant(86).active = true
        xButton.leftAnchor.constraintEqualToAnchor(self.leftAnchor, constant: 100).active = true


        layoutIfNeeded()

    }
    
    func createDraggableViewWithDataAtIndex(index: NSInteger) -> CardView {
//        let draggableView = CardView(frame: CGRectMake((self.frame.size.width - CARD_WIDTH)/2, (self.frame.size.height - CARD_HEIGHT)/2, CARD_WIDTH, CARD_HEIGHT))
        
        let currentCard = cardContentArray[index]
        
        let draggableView = CardView(title: currentCard.count > 1 ? currentCard[1] : "(no title)",
                                         date: formatDate(currentCard[0]),
                                         location: currentCard.count > 2 ? currentCard[2] : "(no location given)",
                                         eventDescription: currentCard.count > 3 ? currentCard[3] : "(no description)")
        
        
        
        draggableView.delegate = self
        return draggableView
    }
    
    func loadCards() -> Void {
        print("loading cards......")
        print("size of cardContentArray is \(cardContentArray.count)")
        
        if cardContentArray.count > 0 {
            print("starting the official loading of the cards mein")

            let numLoadedCardsCap = cardContentArray.count > MAX_BUFFER_SIZE ? MAX_BUFFER_SIZE : cardContentArray.count
            for i in 0 ..< cardContentArray.count {
                let newCard: CardView = self.createDraggableViewWithDataAtIndex(i)
                allCards.append(newCard)
                print("All cards count: \(allCards.count)")
                if i < numLoadedCardsCap {
                    loadedCards.append(newCard)
                    print("Loaded cards count: \(loadedCards.count)")

                }
            }
            
            for i in 0 ..< loadedCards.count {
                print("We are in the ACTUAL loading of the cards!!!!!!")
                
                let card1 = loadedCards[i]

                // Put first card above the view; each subsequent card goes below the preceding one
                if i > 0 {
                    print("added a card above the view!")
                    self.insertSubview(card1, belowSubview: loadedCards[i - 1])
                    let card2 = loadedCards[i - 1]
                    card2.translatesAutoresizingMaskIntoConstraints = false
                    card2.centerXAnchor.constraintEqualToAnchor(self.superview!.centerXAnchor).active = true
                    card2.centerYAnchor.constraintEqualToAnchor(self.superview!.centerYAnchor).active = true
                } else {
                    self.addSubview(card1)
                }
                
                card1.translatesAutoresizingMaskIntoConstraints = false
                card1.centerXAnchor.constraintEqualToAnchor(self.superview!.centerXAnchor).active = true
                card1.centerYAnchor.constraintEqualToAnchor(self.superview!.centerYAnchor).active = true
                layoutIfNeeded()
                print("card added. Frame: \(card1.frame)")
                
            }
            print("Cards loaded: \(cardsLoadedIndex)")
            cardsLoadedIndex! += 1
        }
    }
    
    func cardSwiped(card: CardView) -> Void {

        print("just swiped!!!")

        loadedCards.removeAtIndex(0)
        
        if cardsLoadedIndex < allCards.count {
            print("haven't run out of cards yet")
            loadedCards.append(allCards[cardsLoadedIndex])
            cardsLoadedIndex = cardsLoadedIndex + 1
            let card1 = loadedCards[MAX_BUFFER_SIZE - 1]
            self.insertSubview(card1, aboveSubview: self)
            self.insertSubview(card1, belowSubview: loadedCards[MAX_BUFFER_SIZE - 2])
            card1.translatesAutoresizingMaskIntoConstraints = false
            card1.centerXAnchor.constraintEqualToAnchor(self.superview!.centerXAnchor).active = true
            card1.centerYAnchor.constraintEqualToAnchor(self.superview!.centerYAnchor).active = true
            layoutIfNeeded()

        } else {
            print("ran out of cards")
        }
    
    }
    func cardSwipedLeft(card: CardView) -> Void {
        cardSwiped(card)
    }
    func cardSwipedRight(card: CardView) -> Void {
        cardSwiped(card)
        
        // Add the event to the calendar
        calDelegate.addEventToCalendar(card)

    }
    
    func swipeRight() -> Void {
        if loadedCards.count <= 0 {
            return
        }
        let dragView: CardView = loadedCards[0]
        dragView.overlayView.setMode(GGOverlayViewMode.GGOverlayViewModeRight)
        UIView.animateWithDuration(0.2, animations: {
            () -> Void in
            dragView.overlayView.alpha = 1
        })
        dragView.rightClickAction()
    }
    
    func swipeLeft() -> Void {
        if loadedCards.count <= 0 {
            return
        }
        let dragView: CardView = loadedCards[0]
        dragView.overlayView.setMode(GGOverlayViewMode.GGOverlayViewModeLeft)
        UIView.animateWithDuration(0.2, animations: {
            () -> Void in
            dragView.overlayView.alpha = 1
        })
        dragView.leftClickAction()
    }
    
    internal func addCardsContent(cardsArray: [[String]]) {
        print("Getting into the draggable background array add!")
        self.cardContentArray = cardsArray
        print("This is what the cards array looks like: \(self.cardContentArray)")
        self.loadCards()
    }
    
    
    func formatDate(dateString: String) -> NSDate {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d" /* find out and place date format from http://userguide.icu-project.org/formatparse/datetime */
        var date = dateFormatter.dateFromString(dateString)
        
        //correct date with correct year
        date = correctYearForDate(date!)
        
        return date!
    }
    
    func setupDateChecking() {
        currentDate = NSDate()
        calendarOfCurrentYear = NSCalendar.currentCalendar()
        
        let components = calendarOfCurrentYear.components([.Month, .Year], fromDate: currentDate)
        
        currentMonth = components.month
        currentYear = components.year
    }
    
    func correctYearForDate(eventDate: NSDate) -> NSDate {
        var correctYear = currentYear
        var newDate: NSDate!
        
        let components = calendarOfCurrentYear.components([.Month, .Day, .Year], fromDate: eventDate)
        let eventMonth = components.month
    
        if eventMonth < currentMonth {
            correctYear! += 1 //this is one year up
        }
        
        components.setValue(correctYear, forComponent: .Year)
        newDate = calendarOfCurrentYear.dateFromComponents(components)
        
        return newDate
    }
    

}