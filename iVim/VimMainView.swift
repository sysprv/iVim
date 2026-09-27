//
//  VimMainView.swift
//  iVim
//
//  Created by Terry Chou on 03/11/17.
//  Copyright © 2017 Boogaloo. All rights reserved.
//

import UIKit

final class VimMainView: UIView {
    private var top: NSLayoutConstraint!
    private var left: NSLayoutConstraint!
    private var right: NSLayoutConstraint!
    
    private func constraint(for subview: UIView, attribute: NSLayoutConstraint.Attribute) -> NSLayoutConstraint {
        let c = NSLayoutConstraint(item: subview, attribute: attribute,
                                   relatedBy: .equal, toItem: self,
                                   attribute: attribute, multiplier: 1.0,
                                   constant: 0.0)
        c.priority = UILayoutPriority(750)
        
        return c
    }
    
    func addShellView(_ v: UIView) {
        v.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(v)
        self.top = self.constraint(for: v, attribute: .top)
        // stay above the on-screen keyboard (incl. the extended bar,
        // its input accessory view); also covers the bottom safe area
        let bottom = v.bottomAnchor.constraint(equalTo: self.keyboardLayoutGuide.topAnchor)
        bottom.priority = UILayoutPriority(750)
        self.left = self.constraint(for: v, attribute: .left)
        self.right = self.constraint(for: v, attribute: .right)
        self.addConstraints([self.top, bottom, self.left, self.right])
        self.layoutIfNeeded()
    }
    
    @available(iOS 11, *)
    private func updateSubview() {
        let insets = self.safeAreaInsets
        self.top.constant = insets.top
        self.left.constant = insets.left
        self.right.constant = -insets.right
    }
    
    @available(iOS 11.0, *)
    override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        self.updateSubview()
    }
}

