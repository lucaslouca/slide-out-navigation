//
//  SidePanelViewController.swift
//  slide-out-navigation
//
//  Created by Lucas Louca on 20/03/15.
//  Copyright (c) 2015 Lucas Louca. All rights reserved.
//

import UIKit


@objc
protocol SidePanelViewControllerDelegate {
    func itemSelected()
}


class SidePanelViewController: UIViewController {
    var delegate: SidePanelViewControllerDelegate?
    
    @IBAction func closeButtonTapped(_ sender: AnyObject) {
        delegate?.itemSelected()
    }
    
}
