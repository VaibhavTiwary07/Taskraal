//
//  MainTabBarController.swift
//  Taskraal
//
//  Created by Vaibhav  Tiwary on 12/03/25.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    // MARK: - Properties
    private let neumorphicBackgroundColor = UIColor(red: 235/255, green: 240/255, blue: 245/255, alpha: 1.0)
    private let accentColor = UIColor(red: 94/255, green: 132/255, blue: 226/255, alpha: 1.0) // Vibrant blue
    private let unselectedColor = UIColor(red: 160/255, green: 170/255, blue: 180/255, alpha: 1.0)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        customizeTabBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyNeumorphicEffect()
    }
    
    // MARK: - Setup
    func setupTabs() {
        let tasksVC = TasksViewController()
        let categoriesVC = CategoriesViewController()
        let settingsVC = SettingsViewController()
        
        // Configure each view controller
        configureController(tasksVC, title: "Tasks", navBarColor: neumorphicBackgroundColor)
        configureController(categoriesVC, title: "Categories", navBarColor: neumorphicBackgroundColor)
        configureController(settingsVC, title: "Settings", navBarColor: neumorphicBackgroundColor)
        
        // Create navigation controllers
        let tasksNavController = createNavController(for: tasksVC, title: "Tasks",
                                                    image: "checklist", selectedImage: "checklist.fill")
        let categoriesNavController = createNavController(for: categoriesVC, title: "Categories",
                                                         image: "folder", selectedImage: "folder.fill")
        let settingsNavController = createNavController(for: settingsVC, title: "Settings",
                                                       image: "gear", selectedImage: "gear.fill")
        
        setViewControllers([tasksNavController, categoriesNavController, settingsNavController], animated: true)
    }
    
    private func configureController(_ viewController: UIViewController, title: String, navBarColor: UIColor) {
        viewController.title = title
        viewController.view.backgroundColor = neumorphicBackgroundColor
    }
    
    private func createNavController(for rootViewController: UIViewController, title: String,
                                    image: String, selectedImage: String) -> UINavigationController {
        let navController = UINavigationController(rootViewController: rootViewController)
        
        // Configure navigation bar appearance
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = neumorphicBackgroundColor
            appearance.titleTextAttributes = [.foregroundColor: UIColor(red: 70/255, green: 90/255, blue: 110/255, alpha: 1.0)]
            appearance.shadowColor = .clear // Remove navigation bar shadow
            
            navController.navigationBar.standardAppearance = appearance
            navController.navigationBar.scrollEdgeAppearance = appearance
        } else {
            navController.navigationBar.barTintColor = neumorphicBackgroundColor
            navController.navigationBar.tintColor = accentColor
            navController.navigationBar.titleTextAttributes = [.foregroundColor: UIColor(red: 70/255, green: 90/255, blue: 110/255, alpha: 1.0)]
            navController.navigationBar.shadowImage = UIImage() // Remove navigation bar shadow
        }
        
        // Configure tab bar item
        navController.tabBarItem = UITabBarItem(title: title,
                                              image: UIImage(systemName: image)?.withRenderingMode(.alwaysTemplate),
                                              selectedImage: UIImage(systemName: selectedImage)?.withRenderingMode(.alwaysTemplate))
        
        return navController
    }
    
    private func customizeTabBar() {
        // Set tab bar's background color
        tabBar.barTintColor = .clear
        tabBar.backgroundImage = UIImage()
        tabBar.shadowImage = UIImage()
        
        // Set icon colors
        tabBar.tintColor = accentColor
        tabBar.unselectedItemTintColor = unselectedColor
        
        // Modern appearance for iOS 15+
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithTransparentBackground()
            
            // Set icon colors
            appearance.stackedLayoutAppearance.selected.iconColor = accentColor
            appearance.stackedLayoutAppearance.normal.iconColor = unselectedColor
            
            // Set text colors
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: accentColor]
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: unselectedColor]
            
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        }
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
        container.backgroundColor = neumorphicBackgroundColor
        
        // Make it slightly larger than the tab bar with rounded corners at the top
        container.frame = CGRect(x: 8,
                               y: tabBar.frame.origin.y - 10,
                               width: tabBar.frame.width - 16,
                               height: tabBar.frame.height + 10)
        
        // Add rounded corners
        container.layer.cornerRadius = 25
        container.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner] // Top corners only
        
        // Create subtle inner shadow effect
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        container.layer.shadowOpacity = 0.08
        container.layer.shadowRadius = 6
        
        // Create light highlight at the top
        let highlightLayer = CAGradientLayer()
        highlightLayer.frame = CGRect(x: 0, y: 0, width: container.frame.width, height: 1)
        highlightLayer.colors = [
            UIColor.white.withAlphaComponent(0.5).cgColor,
            UIColor.white.withAlphaComponent(0.0).cgColor
        ]
        highlightLayer.startPoint = CGPoint(x: 0, y: 0)
        highlightLayer.endPoint = CGPoint(x: 0, y: 1)
        container.layer.addSublayer(highlightLayer)
        
        // Create a subtle line above the tab bar for separation
        let separatorView = UIView()
        separatorView.frame = CGRect(x: 25,
                                    y: 12,
                                    width: container.frame.width - 50,
                                    height: 4)
        separatorView.backgroundColor = unselectedColor.withAlphaComponent(0.2)
        separatorView.layer.cornerRadius = 2
        container.addSubview(separatorView)
        
        // Add small indicator lights for selected tab
        for i in 0...2 {
            let indicatorLight = UIView()
            indicatorLight.frame = CGRect(x: (container.frame.width / 3) * CGFloat(i) + (container.frame.width / 6) - 3,
                                        y: 12,
                                        width: 6,
                                        height: 6)
            indicatorLight.layer.cornerRadius = 3
            indicatorLight.backgroundColor = i == selectedIndex ? accentColor : .clear
            indicatorLight.tag = 1000 + i
            container.addSubview(indicatorLight)
        }
        
        // Insert behind tab bar
        tabBarSuperview.insertSubview(container, belowSubview: tabBar)
        
        // Add glass-like reflection
        let glassLayer = CAGradientLayer()
        glassLayer.frame = container.bounds
        glassLayer.cornerRadius = 25
        glassLayer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        glassLayer.colors = [
            UIColor.white.withAlphaComponent(0.05).cgColor,
            UIColor.clear.cgColor
        ]
        glassLayer.locations = [0.0, 0.5]
        glassLayer.startPoint = CGPoint(x: 0, y: 0)
        glassLayer.endPoint = CGPoint(x: 0, y: 1)
        container.layer.addSublayer(glassLayer)
    }
    
    // MARK: - Tab Selection
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        // Update indicator lights
        if let container = view.viewWithTag(999) {
            for i in 0...2 {
                if let indicator = container.viewWithTag(1000 + i) {
                    indicator.backgroundColor = i == selectedIndex ? accentColor : .clear
                    
                    // Add animation
                    if i == selectedIndex {
                        indicator.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                        UIView.animate(withDuration: 0.5,
                                      delay: 0,
                                      usingSpringWithDamping: 0.6,
                                      initialSpringVelocity: 0.5,
                                      options: [],
                                      animations: {
                            indicator.transform = .identity
                        })
                    }
                }
            }
        }
    }
}
