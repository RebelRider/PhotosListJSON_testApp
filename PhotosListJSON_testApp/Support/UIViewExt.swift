//
//  Ext.swift
//  PhotosListJSON_testApp
//
//  Created by Kirill Smirnov on 20.03.2024.
//

import UIKit


extension UIView {
    func anchor(top: NSLayoutYAxisAnchor? = nil,
                left: NSLayoutXAxisAnchor? = nil,
                bottom: NSLayoutYAxisAnchor? = nil,
                right: NSLayoutXAxisAnchor? = nil,
                spacingTop: CGFloat = 2,
                spacingLeft: CGFloat = 2,
                spacingBottom: CGFloat = 2,
                spacingRight: CGFloat = 2,
                width: CGFloat? = nil,
                height: CGFloat? = nil) {
        
        translatesAutoresizingMaskIntoConstraints = false
        if let top = top { topAnchor.constraint(equalTo: top, constant: spacingTop).isActive = true }
        if let left = left { leftAnchor.constraint(equalTo: left, constant: spacingLeft).isActive = true }
        if let bottom = bottom {  bottomAnchor.constraint(equalTo: bottom, constant: -spacingBottom).isActive = true }
        if let right = right { rightAnchor.constraint(equalTo: right, constant: -spacingRight).isActive = true }
        if let width = width { widthAnchor.constraint(equalToConstant: width).isActive = true }
        if let height = height { heightAnchor.constraint(equalToConstant: height).isActive = true }
    }
    
    func centerInSuperview() {
        translatesAutoresizingMaskIntoConstraints = false
        if let superview = superview {
            center(inView: superview)
        }
    }
    
    func center(inView view: UIView, yConstant: CGFloat? = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: yConstant!).isActive = true
    }
    
    func centerX(inView view: UIView, topAnchor: NSLayoutYAxisAnchor? = nil, spacingTop: CGFloat? = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        if let topAnchor = topAnchor {
            self.topAnchor.constraint(equalTo: topAnchor, constant: spacingTop!).isActive = true
        }
    }
    
    func centerY(inView view: UIView, leftAnchor: NSLayoutXAxisAnchor? = nil,
                 spacingLeft: CGFloat = 0, constant: CGFloat = 0) {
        
        translatesAutoresizingMaskIntoConstraints = false
        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: constant).isActive = true
        
        if let left = leftAnchor {
            anchor(left: left, spacingLeft: spacingLeft)
        }
    }
    
    func setSize(height: CGFloat, width: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
    func fillSuperview() {
        translatesAutoresizingMaskIntoConstraints = false
        guard let view = superview else { return }
        anchor(top: view.topAnchor, 
               left: view.leftAnchor,
               bottom: view.bottomAnchor, 
               right: view.rightAnchor)
    }
    
    // Fill the entire superview (according to the safeAreaLayoutGuide)
    func fillSuperviewSafe() {
        translatesAutoresizingMaskIntoConstraints = false
        guard let view = superview else { return }
        anchor(top: view.safeAreaLayoutGuide.topAnchor, 
               left: view.safeAreaLayoutGuide.leftAnchor,
               bottom: view.safeAreaLayoutGuide.bottomAnchor, 
               right: view.safeAreaLayoutGuide.rightAnchor)
    }
}
