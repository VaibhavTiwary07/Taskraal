//
//  AppDelegate.swift
//  Taskraal
//
//  Created by Vaibhav  Tiwary on 03/03/25.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Initialize Core Data by accessing the persistent container
        _ = CoreDataManager.shared.persistentContainer
        
        // Test Core Data setup
        testCoreData()
        
        if #available(iOS 13.0, *) {
            // Scene Delegate will handle window setup
        } else {
            window = UIWindow(frame: UIScreen.main.bounds)
            window?.rootViewController = OnboardingViewController()
            window?.makeKeyAndVisible()
        }
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Save changes when app terminates
        CoreDataManager.shared.saveContext()
    }
    
    func testCoreData() {
        // Create a test category using CoreDataManager
        guard let category = CoreDataManager.shared.createCategory(
            name: "Test Category",
            colorHex: "#FF5733"
        ) else {
            print("Failed to create test category")
            return
        }
        
        // Create a test task using CoreDataManager
        guard let task = CoreDataManager.shared.createTask(
            title: "Test Task",
            details: "This is a test task",
            dueDate: Date().addingTimeInterval(86400), // Set due date to tomorrow
            priority: .medium,
            category: category
        ) else {
            print("Failed to create test task")
            return
        }
        
        // Test fetching tasks
        let tasks = CoreDataManager.shared.fetchTasks()
        print("Successfully fetched \(tasks.count) tasks")
        
        if let task = tasks.first {
            print("Task title: \(task.value(forKey: "title") as? String ?? "No title")")
            if let categoryObj = task.value(forKey: "category") as? NSManagedObject {
                print("Task category: \(categoryObj.value(forKey: "name") as? String ?? "No name")")
            } else {
                print("Task has no category")
            }
        }
    }
}
