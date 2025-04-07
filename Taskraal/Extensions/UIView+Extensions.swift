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
                            lightShadowColor: UIColor? = nil,
                            darkShadowColor: UIColor? = nil,
                            shadowOffset: CGFloat = 7,
                            shadowRadius: CGFloat? = nil,
                            backgroundColor: UIColor? = nil) {
        
        // Get theme-based settings
        let themeManager = ThemeManager.shared
        let themeEffect = themeManager.getNeumorphicEffect(for: self)
        
        // Use provided values or theme defaults
        let finalLightShadow = lightShadowColor ?? themeEffect.lightShadowColor
        let finalDarkShadow = darkShadowColor ?? themeEffect.darkShadowColor
        let finalShadowRadius = shadowRadius ?? themeEffect.shadowRadius
        let finalBackgroundColor = backgroundColor ?? themeManager.backgroundColor
        
        // Set background color for the neumorphic effect
        self.backgroundColor = finalBackgroundColor
        
        // Set corner radius
        self.layer.cornerRadius = cornerRadius
        
        // Remove existing shadows
        self.layer.shadowOpacity = 0
        layer.sublayers?.filter { $0.name == "neumorphicShadow" }.forEach { $0.removeFromSuperlayer() }
        
        // Instead of using CALayer with inner shadow, use the main layer's shadow
        // Create a neumorphic container that will handle the shadows
        let neumorphicView = NeumorphicView(frame: bounds)
        neumorphicView.tag = 1001 // Tag to identify it later
        neumorphicView.translatesAutoresizingMaskIntoConstraints = false
        neumorphicView.backgroundColor = .clear
        
        // Remove any existing neumorphic view
        subviews.filter { $0.tag == 1001 }.forEach { $0.removeFromSuperview() }
        
        // Insert at the bottom
        insertSubview(neumorphicView, at: 0)
        
        // Add constraints to make it resize with parent
        NSLayoutConstraint.activate([
            neumorphicView.topAnchor.constraint(equalTo: topAnchor),
            neumorphicView.leadingAnchor.constraint(equalTo: leadingAnchor),
            neumorphicView.trailingAnchor.constraint(equalTo: trailingAnchor),
            neumorphicView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // Configure the neumorphic view with the shadow parameters
        neumorphicView.configure(
            cornerRadius: cornerRadius,
            lightShadowColor: finalLightShadow,
            darkShadowColor: finalDarkShadow,
            shadowOffset: shadowOffset,
            shadowRadius: finalShadowRadius,
            backgroundColor: finalBackgroundColor
        )
        
        // Force layout to ensure shadows are properly displayed
        setNeedsLayout()
    }
    
    func addInsetNeumorphicEffect(cornerRadius: CGFloat = 10,
                                 lightShadowColor: UIColor? = nil,
                                 darkShadowColor: UIColor? = nil,
                                 shadowOffset: CGFloat = 5,
                                 shadowRadius: CGFloat? = nil,
                                 backgroundColor: UIColor? = nil) {
        
        // Get theme-based settings
        let themeManager = ThemeManager.shared
        let themeEffect = themeManager.getInsetNeumorphicEffect(for: self)
        
        // Use provided values or theme defaults
        let finalLightShadow = lightShadowColor ?? themeEffect.lightShadowColor
        let finalDarkShadow = darkShadowColor ?? themeEffect.darkShadowColor
        let finalShadowRadius = shadowRadius ?? themeEffect.shadowRadius
        let finalBackgroundColor = backgroundColor ?? themeManager.backgroundColor
        
        // Set background color
        self.backgroundColor = finalBackgroundColor
        
        // Set corner radius
        self.layer.cornerRadius = cornerRadius
        
        // Remove existing shadows
        self.layer.shadowOpacity = 0
        layer.sublayers?.filter { $0.name == "neumorphicShadow" }.forEach { $0.removeFromSuperlayer() }
        
        // Create a neumorphic container that will handle the shadows
        let neumorphicView = InsetNeumorphicView(frame: bounds)
        neumorphicView.tag = 1002 // Tag to identify it later
        neumorphicView.translatesAutoresizingMaskIntoConstraints = false
        neumorphicView.backgroundColor = .clear
        
        // Remove any existing neumorphic view
        subviews.filter { $0.tag == 1002 }.forEach { $0.removeFromSuperview() }
        
        // Insert at the bottom
        insertSubview(neumorphicView, at: 0)
        
        // Add constraints to make it resize with parent
        NSLayoutConstraint.activate([
            neumorphicView.topAnchor.constraint(equalTo: topAnchor),
            neumorphicView.leadingAnchor.constraint(equalTo: leadingAnchor),
            neumorphicView.trailingAnchor.constraint(equalTo: trailingAnchor),
            neumorphicView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // Configure the neumorphic view with the shadow parameters
        neumorphicView.configure(
            cornerRadius: cornerRadius,
            lightShadowColor: finalLightShadow,
            darkShadowColor: finalDarkShadow,
            shadowOffset: shadowOffset,
            shadowRadius: finalShadowRadius,
            backgroundColor: finalBackgroundColor
        )
        
        // Force layout to ensure shadows are properly displayed
        setNeedsLayout()
    }
    
    // Apply theming to this view and all its subviews
    func applyTheme() {
        ThemeManager.shared.applyTheme(to: self)
    }
}

// MARK: - Custom Neumorphic View Classes
class NeumorphicView: UIView {
    // Shadow properties
    private var cornerRadius: CGFloat = 10
    private var lightShadowColor: UIColor = .white
    private var darkShadowColor: UIColor = UIColor(white: 0.8, alpha: 1.0)
    private var shadowOffset: CGFloat = 7
    private var shadowRadius: CGFloat = 8
    private var bgColor: UIColor = .white
    
    func configure(
        cornerRadius: CGFloat,
        lightShadowColor: UIColor,
        darkShadowColor: UIColor,
        shadowOffset: CGFloat,
        shadowRadius: CGFloat,
        backgroundColor: UIColor
    ) {
        self.cornerRadius = cornerRadius
        self.lightShadowColor = lightShadowColor
        self.darkShadowColor = darkShadowColor
        self.shadowOffset = shadowOffset
        self.shadowRadius = shadowRadius
        self.bgColor = backgroundColor
        
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Clear any existing layers
        layer.sublayers?.removeAll()
        
        // Create light shadow (top-left)
        let lightShadow = CALayer()
        lightShadow.frame = bounds
        lightShadow.cornerRadius = cornerRadius
        lightShadow.backgroundColor = bgColor.cgColor
        lightShadow.shadowColor = lightShadowColor.cgColor
        lightShadow.shadowOffset = CGSize(width: -shadowOffset, height: -shadowOffset)
        lightShadow.shadowOpacity = 1
        lightShadow.shadowRadius = shadowRadius
        
        // Create dark shadow (bottom-right)
        let darkShadow = CALayer()
        darkShadow.frame = bounds
        darkShadow.cornerRadius = cornerRadius
        darkShadow.backgroundColor = bgColor.cgColor
        darkShadow.shadowColor = darkShadowColor.cgColor
        darkShadow.shadowOffset = CGSize(width: shadowOffset, height: shadowOffset)
        darkShadow.shadowOpacity = 1
        darkShadow.shadowRadius = shadowRadius
        
        // Add shadow layers
        layer.addSublayer(lightShadow)
        layer.addSublayer(darkShadow)
    }
}

class InsetNeumorphicView: UIView {
    // Shadow properties
    private var cornerRadius: CGFloat = 10
    private var lightShadowColor: UIColor = .white
    private var darkShadowColor: UIColor = UIColor(white: 0.8, alpha: 1.0)
    private var shadowOffset: CGFloat = 5
    private var shadowRadius: CGFloat = 4
    private var bgColor: UIColor = .white
    
    func configure(
        cornerRadius: CGFloat,
        lightShadowColor: UIColor,
        darkShadowColor: UIColor,
        shadowOffset: CGFloat,
        shadowRadius: CGFloat,
        backgroundColor: UIColor
    ) {
        self.cornerRadius = cornerRadius
        self.lightShadowColor = lightShadowColor
        self.darkShadowColor = darkShadowColor
        self.shadowOffset = shadowOffset
        self.shadowRadius = shadowRadius
        self.bgColor = backgroundColor
        
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Clear any existing layers
        layer.sublayers?.removeAll()
        
        // Create inner shadow layers
        let innerShadowLayer = CALayer()
        innerShadowLayer.frame = bounds
        innerShadowLayer.cornerRadius = cornerRadius
        innerShadowLayer.backgroundColor = bgColor.cgColor
        innerShadowLayer.shadowColor = darkShadowColor.cgColor
        innerShadowLayer.shadowOffset = CGSize(width: -shadowOffset, height: -shadowOffset)
        innerShadowLayer.shadowOpacity = 1
        innerShadowLayer.shadowRadius = shadowRadius
        innerShadowLayer.masksToBounds = true
        
        let innerShadowLayer2 = CALayer()
        innerShadowLayer2.frame = bounds
        innerShadowLayer2.cornerRadius = cornerRadius
        innerShadowLayer2.backgroundColor = bgColor.cgColor
        innerShadowLayer2.shadowColor = lightShadowColor.cgColor
        innerShadowLayer2.shadowOffset = CGSize(width: shadowOffset, height: shadowOffset)
        innerShadowLayer2.shadowOpacity = 1
        innerShadowLayer2.shadowRadius = shadowRadius
        innerShadowLayer2.masksToBounds = true
        
        // Add inner shadow layers
        layer.addSublayer(innerShadowLayer)
        layer.addSublayer(innerShadowLayer2)
    }
}
