//
//  MainTabBarController.swift
//  Taskraal
//
//  Created by Vaibhav  Tiwary on 12/03/25.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    // MARK: - Properties
    private let themeManager = ThemeManager.shared
    private let unselectedColor = UIColor(red: 160/255, green: 170/255, blue: 180/255, alpha: 1.0)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        customizeTabBar()
        setupNotificationObservers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyNeumorphicEffect()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup
    func setupTabs() {
        let tasksVC = TasksViewController()
        let categoriesVC = CategoriesViewController()
        let settingsVC = SettingsViewController()
        
        // Configure each view controller
        configureController(tasksVC, title: "Tasks")
        configureController(categoriesVC, title: "Categories")
        configureController(settingsVC, title: "Settings")
        
        // Create navigation controllers
        let tasksNavController = createNavController(for: tasksVC, title: "Tasks",
                                                    image: "checklist", selectedImage: "checklist.fill")
        let categoriesNavController = createNavController(for: categoriesVC, title: "Categories",
                                                         image: "folder", selectedImage: "folder.fill")
        let settingsNavController = createNavController(for: settingsVC, title: "Settings",
                                                       image: "gear", selectedImage: "gear.fill")
        
        setViewControllers([tasksNavController, categoriesNavController, settingsNavController], animated: true)
    }
    
    private func configureController(_ viewController: UIViewController, title: String) {
        viewController.title = title
        viewController.view.backgroundColor = themeManager.backgroundColor
    }
    
    private func createNavController(for rootViewController: UIViewController, title: String,
                                    image: String, selectedImage: String) -> UINavigationController {
        let navController = UINavigationController(rootViewController: rootViewController)
        
        // Configure navigation bar using ThemeManager
        themeManager.applyThemeToNavigationBar(navController)
        
        // Configure tab bar item
        navController.tabBarItem = UITabBarItem(title: title,
                                              image: UIImage(systemName: image)?.withRenderingMode(.alwaysTemplate),
                                              selectedImage: UIImage(systemName: selectedImage)?.withRenderingMode(.alwaysTemplate))
        
        return navController
    }
    
    private func customizeTabBar() {
        // Use ThemeManager to apply tab bar theme
        themeManager.applyThemeToTabBar(tabBar)
        
        // Set tab bar's background clear for neumorphic effect
        tabBar.barTintColor = .clear
        tabBar.backgroundImage = UIImage()
        tabBar.shadowImage = UIImage()
    }
    
    private func applyNeumorphicEffect() {
        guard let tabBarSuperview = tabBar.superview else { return }
        
        // Remove any existing effect view
        tabBarSuperview.subviews.forEach { subview in
            if subview.tag == 999 {
                subview.removeFromSuperview()
            }
        }
        
        // Create the neo-neumorphic container
        let container = UIView()
        container.tag = 999
        container.backgroundColor = themeManager.tabBarBackgroundColor
        
        // Make it slightly larger than the tab bar with rounded corners at the top
        container.frame = CGRect(x: 8,
                               y: tabBar.frame.origin.y - 10,
                               width: tabBar.frame.width - 16,
                               height: tabBar.frame.height + 10)
        
        // Add rounded corners
        container.layer.cornerRadius = 25
        container.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner] // Top corners only
        
        // Create subtle inner shadow effect - adapted for dark mode
        if themeManager.isDarkModeEnabled {
            // Darker shadow for dark mode
            container.layer.shadowColor = UIColor.black.cgColor
            container.layer.shadowOffset = CGSize(width: 0, height: 2)
            container.layer.shadowOpacity = 0.7
            container.layer.shadowRadius = 6
            
            // Add inner glow for dark mode - simplified dark gray highlight
            let innerShadow = CALayer()
            innerShadow.frame = container.bounds.insetBy(dx: 2, dy: 2)
            innerShadow.backgroundColor = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1.0).cgColor
            innerShadow.cornerRadius = 23
            container.layer.addSublayer(innerShadow)
        } else {
            // Light mode shadows
            container.layer.shadowColor = UIColor.black.cgColor
            container.layer.shadowOffset = CGSize(width: 0, height: 2)
            container.layer.shadowOpacity = 0.08
            container.layer.shadowRadius = 6
            
            // Create light highlight at the top
            let topHighlight = UIView()
            topHighlight.frame = CGRect(x: 0, y: 0, width: container.frame.width, height: 1)
            topHighlight.backgroundColor = UIColor.white.withAlphaComponent(0.5)
            container.addSubview(topHighlight)
        }
        
        // Create a subtle line above the tab bar for separation
        let separatorView = UIView()
        separatorView.frame = CGRect(x: 25,
                                    y: 12,
                                    width: container.frame.width - 50,
                                    height: 4)
        separatorView.backgroundColor = themeManager.isDarkModeEnabled ? 
            UIColor.darkGray.withAlphaComponent(0.5) : 
            themeManager.secondaryTextColor.withAlphaComponent(0.2)
        separatorView.layer.cornerRadius = 2
        container.addSubview(separatorView)
        
        // Add indicator lights for selected tab
        for i in 0...3 {
            let indicatorLight = UIView()
            indicatorLight.frame = CGRect(x: (container.frame.width / 4) * CGFloat(i) + (container.frame.width / 8) - 3,
                                        y: 12,
                                        width: 6,
                                        height: 6)
            indicatorLight.layer.cornerRadius = 3
            indicatorLight.backgroundColor = i == selectedIndex ? themeManager.currentThemeColor : .clear
            indicatorLight.tag = 1000 + i
            container.addSubview(indicatorLight)
        }
        
        // Insert behind tab bar
        tabBarSuperview.insertSubview(container, belowSubview: tabBar)
    }
    
    // MARK: - Tab Selection
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        // Update indicator lights with animation
        if let container = view.viewWithTag(999) {
            // Batch update indicators
            UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction], animations: {
                for i in 0...3 {
                    if let indicator = container.viewWithTag(1000 + i) {
                        // Only animate the selected indicator
                        if i == self.selectedIndex {
                            indicator.backgroundColor = self.themeManager.currentThemeColor
                            indicator.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                            UIView.animate(withDuration: 0.3, delay: 0.1, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: [], animations: {
                                indicator.transform = .identity
                            }, completion: nil)
                        } else {
                            indicator.backgroundColor = .clear
                        }
                    }
                }
            }, completion: nil)
        }
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleThemeChanged),
            name: ThemeManager.themeChangedNotification,
            object: nil
        )
    }
    
    @objc private func handleThemeChanged() {
        // Apply theme using ThemeManager
        themeManager.applyThemeToTabBar(tabBar)
        
        // Update each navigation controller
        viewControllers?.forEach { vc in
            if let navController = vc as? UINavigationController {
                themeManager.applyThemeToNavigationBar(navController)
            }
        }
        
        // Force refresh the tab bar neumorphic effect
        applyNeumorphicEffect()
    }
}
