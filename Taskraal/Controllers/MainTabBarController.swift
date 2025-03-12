//
//  MainTabBarController.swift
//  Taskraal
//
//  Created by Vaibhav  Tiwary on 12/03/25.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        customizeTabBar()

        
    }
    
    func setupTabs(){
        let tasksVC =  TasksViewController()
        let categoriesVC = CategoriesViewController()
        let settingsVC =  SettingsViewController()
        
        
        let tasksNavController = UINavigationController(rootViewController: tasksVC)
        let categoriesNavController = UINavigationController(rootViewController: categoriesVC)
        let settingNavController = UINavigationController(rootViewController: settingsVC)
        
        tasksVC.title = "Tasks"
        categoriesVC.title = "Categories"
        settingsVC.title = "Settings"
        
        tasksNavController.tabBarItem = UITabBarItem(title: "Tasks", image: UIImage(systemName: "checklist"),selectedImage: UIImage(systemName: "checklist.fill"))
        categoriesNavController.tabBarItem = UITabBarItem(title: "Categories", image: UIImage(systemName: "folder"),selectedImage: UIImage(systemName: "folder.fill"))
        tasksNavController.tabBarItem = UITabBarItem(title: "Tasks", image: UIImage(systemName: "gear"),selectedImage: UIImage(systemName: "gear.fill"))
        
        setViewControllers([tasksNavController,categoriesNavController,settingNavController], animated: true)
        
    }
    
    private func customizeTabBar() {
        // Customize tab bar appearance with tranquil colors
        tabBar.tintColor = UIColor(red: 162/255, green: 213/255, blue: 242/255, alpha: 1.0) // Soft Blue
        tabBar.unselectedItemTintColor = UIColor(red: 168/255, green: 216/255, blue: 185/255, alpha: 1.0) // Muted Green
        
        // Set the tab bar background color to a light, calming shade
        tabBar.barTintColor = UIColor(red: 245/255, green: 245/255, blue: 220/255, alpha: 1.0) // Soft Beige
        
        // Add a subtle shadow for depth
        tabBar.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor // Very light black shadow
        tabBar.layer.shadowOpacity = 0.1
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -1)
        tabBar.layer.shadowRadius = 2
        
        // Optional: Add a blur effect for a modern, tranquil look
        let blurEffect = UIBlurEffect(style: .extraLight)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = tabBar.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tabBar.insertSubview(blurView, at: 0)
        
        // Optional: Add a thin top border for a polished look
        let topBorder = CALayer()
        topBorder.frame = CGRect(x: 0, y: 0, width: tabBar.frame.width, height: 0.5)
        topBorder.backgroundColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 0.3).cgColor // Light grey border
        tabBar.layer.addSublayer(topBorder)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
