//
//  UIView+Extensions.swift
//  Taskraal
//
//  Created by Vaibhav  Tiwary on 04/03/25.
//
import UIKit
import Foundation

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }
    
    func anchor(top: NSLayoutYAxisAnchor? = nil,
                leading: NSLayoutXAxisAnchor? = nil,
                bottom: NSLayoutYAxisAnchor? = nil,
                trailing: NSLayoutXAxisAnchor? = nil,
                paddingTop: CGFloat = 0,
                paddingLeading: CGFloat = 0,
                paddingBottom: CGFloat = 0,
                paddingTrailing: CGFloat = 0,
                width: CGFloat? = nil,
                height: CGFloat? = nil) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let leading = leading {
            leadingAnchor.constraint(equalTo: leading, constant: paddingLeading).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        
        if let trailing = trailing {
            trailingAnchor.constraint(equalTo: trailing, constant: -paddingTrailing).isActive = true
        }
        
        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    func centerX(in view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func centerY(in view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    func setCornerRadius(_ radius: CGFloat) {
        layer.cornerRadius = radius
        layer.masksToBounds = true
    }
}
// UIView+Neumorphic.swift

extension UIView {
    func addNeumorphicEffect(cornerRadius: CGFloat = 10,
                            lightShadowColor: UIColor = UIColor.white.withAlphaComponent(0.7),
                            darkShadowColor: UIColor = UIColor.black.withAlphaComponent(0.15),
                            shadowOffset: CGFloat = 7,
                            shadowRadius: CGFloat = 8,
                            backgroundColor: UIColor = UIColor(red: 240/255, green: 243/255, blue: 245/255, alpha: 1)) {
        
        // Set background color for the neumorphic effect
        self.backgroundColor = backgroundColor
        
        // Set corner radius
        self.layer.cornerRadius = cornerRadius
        
        // Remove existing shadows
        self.layer.shadowOpacity = 0
        layer.sublayers?.filter { $0.name == "neumorphicShadow" }.forEach { $0.removeFromSuperlayer() }
        
        // Create light shadow (top-left)
        let lightShadow = CALayer()
        lightShadow.name = "neumorphicShadow"
        lightShadow.frame = self.bounds
        lightShadow.cornerRadius = cornerRadius
        lightShadow.backgroundColor = backgroundColor.cgColor
        lightShadow.shadowColor = lightShadowColor.cgColor
        lightShadow.shadowOffset = CGSize(width: -shadowOffset, height: -shadowOffset)
        lightShadow.shadowOpacity = 1
        lightShadow.shadowRadius = shadowRadius
        
        // Create dark shadow (bottom-right)
        let darkShadow = CALayer()
        darkShadow.name = "neumorphicShadow"
        darkShadow.frame = self.bounds
        darkShadow.cornerRadius = cornerRadius
        darkShadow.backgroundColor = backgroundColor.cgColor
        darkShadow.shadowColor = darkShadowColor.cgColor
        darkShadow.shadowOffset = CGSize(width: shadowOffset, height: shadowOffset)
        darkShadow.shadowOpacity = 1
        darkShadow.shadowRadius = shadowRadius
        
        // Add shadows to the view's layer
        self.layer.insertSublayer(lightShadow, at: 0)
        self.layer.insertSublayer(darkShadow, at: 0)
    }
    
    func addInsetNeumorphicEffect(cornerRadius: CGFloat = 10,
                                 lightShadowColor: UIColor = UIColor.black.withAlphaComponent(0.15),
                                 darkShadowColor: UIColor = UIColor.white.withAlphaComponent(0.7),
                                 shadowOffset: CGFloat = 5,
                                 shadowRadius: CGFloat = 3,
                                 backgroundColor: UIColor = UIColor(red: 240/255, green: 243/255, blue: 245/255, alpha: 1)) {
        
        // Set background color
        self.backgroundColor = backgroundColor
        
        // Set corner radius
        self.layer.cornerRadius = cornerRadius
        
        // Remove existing shadows
        self.layer.shadowOpacity = 0
        layer.sublayers?.filter { $0.name == "neumorphicShadow" }.forEach { $0.removeFromSuperlayer() }
        
        // Create inner shadows (inset effect)
        let innerShadowLayer = CALayer()
        innerShadowLayer.name = "neumorphicShadow"
        innerShadowLayer.frame = bounds
        innerShadowLayer.cornerRadius = cornerRadius
        innerShadowLayer.backgroundColor = backgroundColor.cgColor
        innerShadowLayer.shadowColor = darkShadowColor.cgColor
        innerShadowLayer.shadowOffset = CGSize(width: -shadowOffset, height: -shadowOffset)
        innerShadowLayer.shadowOpacity = 1
        innerShadowLayer.shadowRadius = shadowRadius
        innerShadowLayer.masksToBounds = true
        
        let innerShadowLayer2 = CALayer()
        innerShadowLayer2.name = "neumorphicShadow"
        innerShadowLayer2.frame = bounds
        innerShadowLayer2.cornerRadius = cornerRadius
        innerShadowLayer2.backgroundColor = backgroundColor.cgColor
        innerShadowLayer2.shadowColor = lightShadowColor.cgColor
        innerShadowLayer2.shadowOffset = CGSize(width: shadowOffset, height: shadowOffset)
        innerShadowLayer2.shadowOpacity = 1
        innerShadowLayer2.shadowRadius = shadowRadius
        innerShadowLayer2.masksToBounds = true
        
        // Add inner shadow layers
        self.layer.insertSublayer(innerShadowLayer, at: 0)
        self.layer.insertSublayer(innerShadowLayer2, at: 0)
    }
}
