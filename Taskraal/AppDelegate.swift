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
    
    func testCoreData() {
        let context = CoreDataManager.shared.viewContext
        
        // Create a test category
        let category = TaskCategory(context: context)
        category.id = UUID()
        category.name = "Test Category"
        category.colorHex = "#FF5733"
        category.dateCreated = Date()
        
        // Create a test task
        // Create a test task
        let task = TaskItem(context: context)
        task.id = UUID()
        task.title = "Test Task"
        task.taskDescription = "This is a test task"
        task.priority = 1 // Medium priority
        task.isCompleted = false
        task.dateCreated = Date()
        task.lastModified = Date()
        task.dueDate = Date().addingTimeInterval(86400) // Set due date to tomorrow
        task.category = category
        
        // Save the context
        CoreDataManager.shared.saveContext()
        
        // Test fetching
        let fetchRequest: NSFetchRequest<TaskItem> = TaskItem.fetchRequest()
        do {
            let tasks = try context.fetch(fetchRequest)
            print("Successfully fetched \(tasks.count) tasks")
            if let task = tasks.first {
                print("Task title: \(task.title ?? "No title")")
                print("Task category: \(task.category?.name ?? "No category")")
            }
        } catch {
            print("Error fetching tasks: \(error)")
        }
    }
}
