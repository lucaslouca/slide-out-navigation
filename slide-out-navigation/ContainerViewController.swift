//
//  ContainerViewController.swift
//  slide-out-navigation
//
//  Created by Lucas Louca on 20/03/15.
//  Copyright (c) 2015 Lucas Louca. All rights reserved.
//

import UIKit
import QuartzCore

enum SlideOutState {
    case Collapsed
    case Expanded
}

class ContainerViewController: UIViewController, CenterViewControllerDelegate, UIGestureRecognizerDelegate {
    var centerNavigationController: UINavigationController!
    var centerViewController: CenterViewController!
    var leftViewController: SidePanelViewController?
    let centerPanelExpandedOffset: CGFloat = 60
    var currentState: SlideOutState = .Collapsed {
        didSet {
            let shouldShowShadow = currentState != .Collapsed
            showShadowForCenterViewController(shouldShowShadow)
        }
    }
    
    /**
    Initialisation:
    
    1. Get the centerViewController from the Storyboard.
    2. Set self as the centerViewController's CenterViewControllerDelegate delegate.
    3. Wrap the centerViewController in a UINavigationController, so we can push views to it and display bar button items in the navigation bar.
    4. Add the UINavigationController as a child of this view controller.
    5. Add a PanGestureRecognizer to the UINavigationController.
    
    :see: https://developer.apple.com/library/ios/documentation/UIKit/Reference/UINavigationController_Class/
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        centerViewController = UIStoryboard.centerViewController()
        centerViewController.delegate = self
        
        // Wrap the centerViewController in a navigation controller
        centerNavigationController = UINavigationController(rootViewController: centerViewController)
        view.addSubview(centerNavigationController.view)
        addChildViewController(centerNavigationController)
        
        centerNavigationController.didMoveToParentViewController(self)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
        centerNavigationController.view.addGestureRecognizer(panGestureRecognizer)
        
    }
    
    /**
    Apply or remove shadow from centerNavigationController's view
    
    :param: shouldShowShadow a boolean indicating if a shadow should be applied to the centerNavigationController's view
    
    */
    func showShadowForCenterViewController(shouldShowShadow: Bool) {
        if (shouldShowShadow) {
            centerNavigationController.view.layer.shadowOpacity = 0.8
        } else {
            centerNavigationController.view.layer.shadowOpacity = 0.0
        }
    }
    
    // MARK: CenterViewController delegate methods
    /**
    Hides the side panel if it is expanded.
    */
    func collapseSidePanel() {
        switch (currentState) {
        case .Expanded:
            toggleSidePanel()
        default:
            break
        }
    }
    
    /**
    Shows the side panel if not already expanded or hides the side panel if it is already expanded.
    */
    func toggleSidePanel() {
        let notAlreadyExpanded = (currentState != .Expanded)
        
        if notAlreadyExpanded {
            addPanelViewController()
        }
        
        animatePanel(shouldExpand: notAlreadyExpanded)
    }
    
    /**
    Gets the SidePanelViewController from Storyboard and adds it as a child to this controller. It also
    sets the centerViewController as the sidepanel's SidePanelViewControllerDelegate.
    */
    func addPanelViewController() {
        if (leftViewController == nil) {
            leftViewController = UIStoryboard.leftViewController()
            leftViewController!.delegate = centerViewController
            
            view.insertSubview(leftViewController!.view, atIndex: 0)
            
            addChildViewController(leftViewController!)
            leftViewController!.didMoveToParentViewController(self)
        }
    }
    
    
    /**
    Expands or hides the side panel with animation.
    
    :param: shouldExpand a boolean indicating if the side panel should be expanded
    
    */
    func animatePanel(#shouldExpand: Bool) {
        if (shouldExpand) {
            currentState = .Expanded
            
            animateCenterPanelXPosition(targetPosition: CGRectGetWidth(centerNavigationController.view.frame) - centerPanelExpandedOffset)
        } else {
            animateCenterPanelXPosition(targetPosition: 0) { finished in
                self.currentState = .Collapsed
                
                self.leftViewController!.view.removeFromSuperview()
                self.leftViewController = nil;
            }
        }
    }
    
    /**
    Moves the centerNavigationController's view to the target position
    
    :param: targetPosition a CGFloat indicating where the view's origin.x position should move
    :param: completion an optional completion closure that should be executed when the animation is done
    */
    func animateCenterPanelXPosition(#targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
            self.centerNavigationController.view.frame.origin.x = targetPosition
            }, completion: completion)
    }
    
    
    // MARK: Gesture recognizer

    /**
    Handles pans of horizontal movements. Shows the side panel if the gesture is from left to right and no
    side panel is expanded. Hides the side panel if it is already expanded (horizontal movement from right to left).
    
    :param: recognizer UIPanGestureRecognizer
    */
    func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        let gestureIsDraggingFromLeftToRight = (recognizer.velocityInView(view).x > 0)
        
        switch(recognizer.state) {
        case .Began:
            if (currentState == .Collapsed) {
                if (gestureIsDraggingFromLeftToRight) {
                    addPanelViewController()
                }
                
                showShadowForCenterViewController(true)
            }
        case .Changed:
            if (gestureIsDraggingFromLeftToRight || (currentState == .Expanded)) {
                recognizer.view!.center.x = recognizer.view!.center.x + recognizer.translationInView(view).x
                recognizer.setTranslation(CGPointZero, inView: view)
            }
        case .Ended:
            if (leftViewController != nil) {
                // animate the side panel open or closed based on whether the view has moved more or less than halfway
                let hasMovedGreaterThanHalfway = recognizer.view!.center.x > view.bounds.size.width
                animatePanel(shouldExpand: hasMovedGreaterThanHalfway)
            }
        default:
            break
        }
    }
    
    
}

/**
UIStoryboard enabling easier access for our view controllers and story board.
*/
private extension UIStoryboard {
    class func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()) }
    
    class func leftViewController() -> SidePanelViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("LeftViewController") as? SidePanelViewController
    }
    
    class func centerViewController() -> CenterViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("CenterViewController") as? CenterViewController
    }
}
