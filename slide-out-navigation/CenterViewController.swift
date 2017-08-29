//
//  CenterViewController.swift
//  slide-out-navigation
//
// This UIViewController is set as the Initial View Controller (see Main.storyboard)
//
//
//  Created by Lucas Louca on 20/03/15.
//  Copyright (c) 2015 Lucas Louca. All rights reserved.


import UIKit

@objc
protocol CenterViewControllerDelegate {
    @objc optional func toggleSidePanel()
    @objc optional func collapseSidePanel()
}

class CenterViewController: UIViewController, SidePanelViewControllerDelegate {
    var delegate: CenterViewControllerDelegate?

    @IBAction func menuButtonTapped(_ sender: AnyObject) {
        delegate?.toggleSidePanel?()
    }
    
    func itemSelected() {
        delegate?.collapseSidePanel?()
    }
}
