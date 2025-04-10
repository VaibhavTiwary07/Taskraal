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
        
        // Set background color and corner radius directly
        self.backgroundColor = finalBackgroundColor
        self.layer.cornerRadius = cornerRadius
        
        // Remove any existing shadow effect
        layer.shadowOpacity = 0
        layer.masksToBounds = false
        
        // Apply optimized shadow
        layer.shadowColor = finalDarkShadow.cgColor
        layer.shadowOffset = CGSize(width: shadowOffset/2, height: shadowOffset/2)
        layer.shadowOpacity = 0.25
        layer.shadowRadius = finalShadowRadius/2
        
        // Create a shadowPath for better performance
        updateShadowPathIfNeeded()
        
        // Clean up any existing neumorphic views
        subviews.filter { $0.tag == 1001 || $0.tag == 1002 }.forEach { $0.removeFromSuperview() }
        
        // Tag the view to track it has neumorphic effect applied
        tag = (tag == 0) ? 2001 : tag
    }
    
    // Helper method to update shadow path when bounds change
    private func updateShadowPathIfNeeded() {
        if bounds.size != .zero && layer.shadowOpacity > 0 {
            let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
            layer.shadowPath = shadowPath
        }
    }
    
    // Helper to update shadow paths when layout changes
    @objc private func handleLayoutChanged() {
        updateShadowPathIfNeeded()
    }
    
    // This method should be called in viewDidLayoutSubviews of the view controller
    func updateNeumorphicShadowPaths() {
        // Update this view's shadow path
        updateShadowPathIfNeeded()
        
        // Update subviews with tag 2001 (views with neumorphic effect)
        subviews.filter { $0.tag == 2001 }.forEach { $0.updateShadowPathIfNeeded() }
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
        
        // Set background color and corner radius directly
        self.backgroundColor = finalBackgroundColor
        self.layer.cornerRadius = cornerRadius
        
        // Clean up any existing effects
        layer.shadowOpacity = 0
        layer.borderWidth = 0
        
        // Apply subtle border for inset effect
        layer.borderWidth = 1.0
        
        // Create a gradient border color
        let isDarkMode = themeManager.isDarkModeEnabled
        if isDarkMode {
            // For dark mode, use darker borders
            layer.borderColor = finalDarkShadow.withAlphaComponent(0.3).cgColor
        } else {
            // For light mode, use subtle gray border
            layer.borderColor = UIColor.lightGray.withAlphaComponent(0.2).cgColor
        }
        
        // Clean up any existing neumorphic views
        subviews.filter { $0.tag == 1001 || $0.tag == 1002 }.forEach { $0.removeFromSuperview() }
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
        
        // Set shadow path for better performance
        let lightShadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        lightShadow.shadowPath = lightShadowPath
        lightShadow.name = "optimizedShadow"
        
        // Create dark shadow (bottom-right)
        let darkShadow = CALayer()
        darkShadow.frame = bounds
        darkShadow.cornerRadius = cornerRadius
        darkShadow.backgroundColor = bgColor.cgColor
        darkShadow.shadowColor = darkShadowColor.cgColor
        darkShadow.shadowOffset = CGSize(width: shadowOffset, height: shadowOffset)
        darkShadow.shadowOpacity = 1
        darkShadow.shadowRadius = shadowRadius
        
        // Set shadow path for better performance
        let darkShadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        darkShadow.shadowPath = darkShadowPath
        darkShadow.name = "optimizedShadow"
        
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
        
        // Instead of using multiple complex shadow layers, use a single CALayer with proper styling
        let containerLayer = CALayer()
        containerLayer.frame = bounds
        containerLayer.cornerRadius = cornerRadius
        containerLayer.backgroundColor = bgColor.cgColor
        containerLayer.masksToBounds = false
        containerLayer.name = "optimizedContainer"
        
        // Add inner shadow effect using border and gradient
        let borderWidth: CGFloat = 1.0
        containerLayer.borderWidth = borderWidth
        
        // Create a gradient layer for the inner shadow effect
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds.insetBy(dx: borderWidth, dy: borderWidth)
        gradientLayer.cornerRadius = cornerRadius - borderWidth
        gradientLayer.colors = [
            darkShadowColor.withAlphaComponent(0.4).cgColor,
            bgColor.cgColor,
            lightShadowColor.withAlphaComponent(0.4).cgColor
        ]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.name = "optimizedGradient"
        
        // Add gradient layer inside the container
        containerLayer.addSublayer(gradientLayer)
        
        // Add the container to the view's layer
        layer.addSublayer(containerLayer)
        
        // Add a subtle border gradient for the inner shadow effect
        let borderGradient = CAGradientLayer()
        borderGradient.frame = bounds
        borderGradient.cornerRadius = cornerRadius
        borderGradient.colors = [
            darkShadowColor.withAlphaComponent(0.6).cgColor,
            lightShadowColor.withAlphaComponent(0.6).cgColor
        ]
        borderGradient.startPoint = CGPoint(x: 0, y: 0)
        borderGradient.endPoint = CGPoint(x: 1, y: 1)
        borderGradient.opacity = 0.5
        borderGradient.name = "borderGradient"
        
        // Create a mask to show only the border
        let maskLayer = CAShapeLayer()
        let maskPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        let innerPath = UIBezierPath(roundedRect: bounds.insetBy(dx: borderWidth, dy: borderWidth), cornerRadius: cornerRadius - borderWidth)
        maskPath.append(innerPath.reversing())
        maskLayer.path = maskPath.cgPath
        maskLayer.fillRule = .evenOdd
        
        borderGradient.mask = maskLayer
        
        // Add the border gradient on top
        layer.addSublayer(borderGradient)
    }
}

// MARK: - UIColor Extensions for Hex Conversion
extension UIColor {
//    static func fromHex(_ hex: String) -> UIColor? {
//        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
//        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
//        
//        var rgb: UInt64 = 0
//        
//        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
//        
//        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
//        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
//        let blue = CGFloat(rgb & 0x0000FF) / 255.0
//        
//        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
//    }
//    
//    // Additional convenience method to get a hex string from a UIColor
//    var hexString: String? {
//        guard let components = self.cgColor.components else { return nil }
//        
//        let r = Float(components[0])
//        let g = Float(components[1])
//        let b = Float(components[2])
//        
//        return String(format: "#%02lX%02lX%02lX", 
//                    lroundf(r * 255), 
//                    lroundf(g * 255), 
//                    lroundf(b * 255))
//    }
}
