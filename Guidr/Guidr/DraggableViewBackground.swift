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
    var buttonView: ButtonView!
    
    
    var calendarOfCurrentYear: NSCalendar!
    var currentDate: NSDate!
    var currentMonth: Int!
    var currentYear: Int!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        super.layoutSubviews()
        self.setupView()
        self.setupDateChecking()
        allCards = []
        loadedCards = []
        cardContentArray = []
        cardsLoadedIndex = 0
        self.loadCards()

    }
    
    convenience init(){
        self.init(frame: CGRect.zero)
    }

    func setupView() -> Void {
        
//        xButton = UIButton()
//        checkButton = UIButton()
//
//        checkButton.setImage(UIImage(named: "newCheck"), forState: UIControlState.Normal)
//        checkButton.addTarget(self, action: #selector(DraggableViewBackground.swipeRight), forControlEvents: UIControlEvents.TouchUpInside)
//        
//        xButton.setImage(UIImage(named: "newX"), forState: UIControlState.Normal)
//        xButton.addTarget(self, action: #selector(DraggableViewBackground.swipeLeft), forControlEvents: UIControlEvents.TouchUpInside)
//        
//        self.addSubview(xButton)
//        self.addSubview(checkButton)
//        
//        // check button constraints
//        checkButton.translatesAutoresizingMaskIntoConstraints = false
////        checkButton.centerXAnchor.constraintEqualToAnchor(self.centerXAnchor, constant: checkButton.bounds.width).active = true
//        checkButton.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor, constant: -100).active = true
//        checkButton.widthAnchor.constraintEqualToConstant(100).active = true
//        checkButton.heightAnchor.constraintEqualToConstant(86).active = true
//        checkButton.rightAnchor.constraintEqualToAnchor(self.rightAnchor, constant: -100).active = true
//
//        // x button constraints
//        xButton.translatesAutoresizingMaskIntoConstraints = false
////        xButton.centerXAnchor.constraintEqualToAnchor(self.centerXAnchor, constant: -self.checkButton.bounds.width).active = true
//        xButton.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor, constant: -100).active = true
//        xButton.widthAnchor.constraintEqualToConstant(100).active = true
//        xButton.heightAnchor.constraintEqualToConstant(86).active = true
//        xButton.leftAnchor.constraintEqualToAnchor(self.leftAnchor, constant: 100).active = true


//        layoutIfNeeded()
        buttonView = ButtonView()
        addSubview(buttonView)
        addButtonViewConstraints()
        buttonView.checkButton.addTarget(self, action: #selector(DraggableViewBackground.swipeRight), forControlEvents: UIControlEvents.TouchUpInside)
        buttonView.xButton.addTarget(self, action: #selector(DraggableViewBackground.swipeLeft), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func createDraggableViewWithDataAtIndex(index: NSInteger) -> CardView {
        
        let currentCard = cardContentArray[index]
        
//        let draggableView = CardView(title: currentCard.count > 1 ? currentCard[1] : "(no title)",
//                                         date: formatDate(currentCard[0]),
//                                         location: currentCard.count > 2 ? currentCard[2] : "(no location given)",
//                                         eventDescription: currentCard.count > 3 ? currentCard[3] : "(no description)")
        let draggableView = CardView(event: currentCard)
        
        
        draggableView.delegate = self
        return draggableView
    }
    
    func loadCards() -> Void {
        
        if cardContentArray.count > 0 {

            let numLoadedCardsCap = cardContentArray.count > MAX_BUFFER_SIZE ? MAX_BUFFER_SIZE : cardContentArray.count
            for i in 0 ..< cardContentArray.count {
                let newCard: CardView = self.createDraggableViewWithDataAtIndex(i)
                allCards.append(newCard)
                if i < numLoadedCardsCap {
                    loadedCards.append(newCard)

                }
            }
            
            for i in 0 ..< loadedCards.count {
                
                let card1 = loadedCards[i]

                // Put first card above the view; each subsequent card goes below the preceding one
                if i > 0 {
                    self.insertSubview(card1, belowSubview: loadedCards[i - 1])
                } else {
                    self.addSubview(card1)
                }
                
                addCorrectConstraints(card1)
                
                layoutIfNeeded()
                
            }
            cardsLoadedIndex! += 1
        }
    }
    
    func cardSwiped(card: CardView) -> Void {


        loadedCards.removeAtIndex(0)
        
        if cardsLoadedIndex < allCards.count {
            loadedCards.append(allCards[cardsLoadedIndex])
            cardsLoadedIndex = cardsLoadedIndex + 1
            let card1 = loadedCards[MAX_BUFFER_SIZE - 1]
            self.insertSubview(card1, aboveSubview: self)
            self.insertSubview(card1, belowSubview: loadedCards[MAX_BUFFER_SIZE - 2])
            addCorrectConstraints(card1)
            
            layoutIfNeeded()

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
        print("Swipped right!!!!!!")
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
        self.cardContentArray = cardsArray
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
    
    //helper method for setting constraints on the passed in card view
    func addCorrectConstraints(card: CardView) {
        card.translatesAutoresizingMaskIntoConstraints = false
        card.leftAnchor.constraintEqualToAnchor(self.leftAnchor, constant: 10).active = true
        card.rightAnchor.constraintEqualToAnchor(self.rightAnchor, constant: -10).active = true
        card.topAnchor.constraintEqualToAnchor(self.topAnchor, constant: 5).active = true
        card.heightAnchor.constraintEqualToAnchor(self.heightAnchor, constant: -150).active = true
    }
    
    //helper method for setting constraints on the buttonSet (aka ButtonView)
    func addButtonViewConstraints() {
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        buttonView.leftAnchor.constraintEqualToAnchor(self.leftAnchor).active = true
        buttonView.rightAnchor.constraintEqualToAnchor(self.rightAnchor).active = true
        buttonView.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor).active = true
        buttonView.heightAnchor.constraintEqualToConstant(100).active = true
//        buttonView.topAnchor.constraintEqualToAnchor(self.topAnchor).active = true
    }
    
}