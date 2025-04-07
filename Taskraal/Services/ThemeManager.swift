//
//  ThemeManager.swift
//  Taskraal
//
//  Created by Vaibhav Tiwary on 07/04/25.
//

import UIKit

class ThemeManager {
    
    // MARK: - Shared Instance (Singleton)
    static let shared = ThemeManager()
    
    // MARK: - Properties
    private let userDefaults = UserDefaults.standard
    
    // Accent colors
    private let lightModeAccentColor = UIColor(red: 94/255, green: 132/255, blue: 226/255, alpha: 1.0) // Blue
    private let darkModeAccentColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1.0) // Green
    
    // MARK: - Initialization
    private init() {
        // Set up default dark mode setting if not already set
        if !userDefaults.contains(key: "isDarkModeEnabled") {
            userDefaults.set(false, forKey: "isDarkModeEnabled")
        }
        
        // Apply initial settings
        applyDarkModeSettings(isDarkModeEnabled)
    }
    
    // MARK: - Theme Management
    var isDarkModeEnabled: Bool {
        get { userDefaults.bool(forKey: "isDarkModeEnabled") }
        set { 
            userDefaults.set(newValue, forKey: "isDarkModeEnabled")
            applyDarkModeSettings(newValue)
        }
    }
    
    var currentThemeColor: UIColor {
        return isDarkModeEnabled ? darkModeAccentColor : lightModeAccentColor
    }
    
    // MARK: - Neumorphic Colors
    var backgroundColor: UIColor {
        return isDarkModeEnabled ? 
            UIColor.black : 
            UIColor.white
    }
    
    var containerBackgroundColor: UIColor {
        return isDarkModeEnabled ? 
            UIColor(red: 18/255, green: 18/255, blue: 18/255, alpha: 1.0) : // Dark shade for containers in dark mode
            UIColor.white
    }
    
    var tabBarBackgroundColor: UIColor {
        return isDarkModeEnabled ? 
            UIColor(red: 25/255, green: 25/255, blue: 25/255, alpha: 1.0) : // Slightly lighter shade for tab bar in dark mode
            UIColor.white
    }
    
    var textColor: UIColor {
        return isDarkModeEnabled ? 
            UIColor.white : 
            UIColor(red: 60/255, green: 80/255, blue: 100/255, alpha: 1.0)
    }
    
    var secondaryTextColor: UIColor {
        return isDarkModeEnabled ? 
            UIColor(red: 170/255, green: 170/255, blue: 180/255, alpha: 1.0) : 
            UIColor(red: 130/255, green: 140/255, blue: 150/255, alpha: 1.0)
    }
    
    // MARK: - Theme Application
    func applyDarkModeSettings(_ isDarkMode: Bool) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
        }
        
        notifyThemeChanged()
    }
    
    private func notifyThemeChanged() {
        NotificationCenter.default.post(name: NSNotification.Name("AppThemeChanged"), object: nil)
    }
    
    // MARK: - Helpers
    func getNeumorphicEffect(for view: UIView) -> (lightShadowColor: UIColor, darkShadowColor: UIColor, shadowRadius: CGFloat) {
        if isDarkModeEnabled {
            // Dark mode neumorphic effect with more pronounced shadows
            return (
                lightShadowColor: UIColor(red: 40/255, green: 40/255, blue: 40/255, alpha: 1.0),
                darkShadowColor: UIColor.black.withAlphaComponent(1.0),
                shadowRadius: 10
            )
        } else {
            // Light mode neumorphic effect with light gray shadows on white
            return (
                lightShadowColor: UIColor.white,
                darkShadowColor: UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1.0),
                shadowRadius: 8
            )
        }
    }
    
    // Get inset neumorphic effect for "pushed in" look
    func getInsetNeumorphicEffect(for view: UIView) -> (lightShadowColor: UIColor, darkShadowColor: UIColor, shadowRadius: CGFloat) {
        if isDarkModeEnabled {
            // Dark mode inset effect (reversed shadows for inset look)
            return (
                lightShadowColor: UIColor.black.withAlphaComponent(1.0),
                darkShadowColor: UIColor(red: 40/255, green: 40/255, blue: 40/255, alpha: 1.0),
                shadowRadius: 6
            )
        } else {
            // Light mode inset effect on white
            return (
                lightShadowColor: UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1.0),
                darkShadowColor: UIColor.white,
                shadowRadius: 4
            )
        }
    }
    
    // Apply theme to a view and its subviews
    func applyTheme(to view: UIView) {
        // Handle different view types
        if let button = view as? UIButton {
            if button.backgroundColor == nil {
                button.backgroundColor = backgroundColor
            }
            button.setTitleColor(textColor, for: .normal)
        } else if let label = view as? UILabel {
            label.textColor = textColor
        } else if let textField = view as? UITextField {
            textField.textColor = textColor
            textField.backgroundColor = backgroundColor
        } else if let textView = view as? UITextView {
            textView.textColor = textColor
            textView.backgroundColor = backgroundColor
        } else if let tableView = view as? UITableView {
            tableView.backgroundColor = backgroundColor
            tableView.separatorColor = secondaryTextColor.withAlphaComponent(0.3)
        } else if let segmentedControl = view as? UISegmentedControl {
            segmentedControl.backgroundColor = backgroundColor
            segmentedControl.selectedSegmentTintColor = currentThemeColor
        } else if let switchControl = view as? UISwitch {
            switchControl.onTintColor = currentThemeColor
        }
        
        // Apply to all subviews
        view.subviews.forEach { applyTheme(to: $0) }
    }
}

// MARK: - UserDefaults Extension
extension UserDefaults {
    func contains(key: String) -> Bool {
        return object(forKey: key) != nil
    }
}
