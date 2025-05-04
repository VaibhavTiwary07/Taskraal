//
//  AppDelegate.swift
//  Taskraal
//
//  Created by Vaibhav  Tiwary on 03/03/25.
//

import UIKit
import CoreData
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Initialize Core Data by accessing the persistent container
        _ = CoreDataManager.shared.persistentContainer
        
        // Test Core Data setup
        testCoreData()
        
        // Initialize SchedulingService and set up notifications
        _ = SchedulingService.shared
        
        // Set up notification categories for task actions
        setupNotificationCategories()
        
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
        guard CoreDataManager.shared.createTask(
            title: "Test Task",
            details: "This is a test task",
            dueDate: Date().addingTimeInterval(86400), // Set due date to tomorrow
            priority: .medium,
            category: category
        ) != nil else {
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
    
    // Add a method to set up notification categories
    private func setupNotificationCategories() {
        let notificationCenter = UNUserNotificationCenter.current()
        
        // Create action for marking a task as complete
        let completeAction = UNNotificationAction(
            identifier: "COMPLETE_TASK",
            title: "Mark as Complete",
            options: [.foreground]
        )
        
        // Create action for snoozing a task
        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE_TASK",
            title: "Snooze (15 min)",
            options: []
        )
        
        // Create category for task notifications
        let taskCategory = UNNotificationCategory(
            identifier: "TASK_REMINDER",
            actions: [completeAction, snoozeAction],
            intentIdentifiers: [],
            options: []
        )
        
        // Register the category
        notificationCenter.setNotificationCategories([taskCategory])
        
        // Set delegate to handle notification responses
        notificationCenter.delegate = self
    }
}

// Add extension for UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    // Handle foreground notifications
    func userNotificationCenter(_ center: UNUserNotificationCenter, 
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show the notification even when app is in foreground
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .sound, .badge])
        } else {
            completionHandler([.alert, .sound, .badge])
        }
    }
    
    // Handle notification response
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let taskID = response.notification.request.identifier.replacingOccurrences(of: "taskraal-task-", with: "")
        
        switch response.actionIdentifier {
        case "COMPLETE_TASK":
            handleCompleteTaskAction(taskID: taskID)
        case "SNOOZE_TASK":
            handleSnoozeTaskAction(taskID: taskID)
        default:
            // Just open the app for the default action
            break
        }
        
        completionHandler()
    }
    
    // Handle complete task action
    private func handleCompleteTaskAction(taskID: String) {
        let context = CoreDataManager.shared.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Task")
        
        // Find the task by ID
        if let uuid = UUID(uuidString: taskID) {
            fetchRequest.predicate = NSPredicate(format: "id == %@", uuid as CVarArg)
            
            do {
                let tasks = try context.fetch(fetchRequest)
                if let task = tasks.first {
                    // Mark task as completed
                    task.setValue(true, forKey: "isCompleted")
                    
                    // Remove scheduling integrations
                    SchedulingService.shared.removeAllIntegrations(for: task)
                    
                    // Save context
                    try context.save()
                    
                    // Post notification to update UI
                    NotificationCenter.default.post(name: NSNotification.Name("TaskDataChanged"), object: nil)
                }
            } catch {
                print("Failed to complete task: \(error)")
            }
        }
    }
    
    // Handle snooze task action
    private func handleSnoozeTaskAction(taskID: String) {
        let context = CoreDataManager.shared.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Task")
        
        // Find the task by ID
        if let uuid = UUID(uuidString: taskID) {
            fetchRequest.predicate = NSPredicate(format: "id == %@", uuid as CVarArg)
            
            do {
                let tasks = try context.fetch(fetchRequest)
                if let task = tasks.first {
                    // Schedule notification 15 minutes from now
                    let snoozeDate = Date().addingTimeInterval(15 * 60) // 15 minutes
                    
                    // Create notification
                    let content = UNMutableNotificationContent()
                    content.title = "Snoozed Task Reminder"
                    content.body = task.value(forKey: "title") as? String ?? "Reminder for your task"
                    content.sound = .default
                    content.categoryIdentifier = "TASK_REMINDER"
                    
                    // Add category name if available
                    if let category = task.value(forKey: "category") as? NSManagedObject,
                       let categoryName = category.value(forKey: "name") as? String {
                        content.subtitle = categoryName
                    }
                    
                    // Create trigger
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 15 * 60, repeats: false)
                    
                    // Create request with same ID (replacing the previous one)
                    let request = UNNotificationRequest(
                        identifier: "taskraal-task-\(taskID)-snoozed",
                        content: content,
                        trigger: trigger
                    )
                    
                    // Add the notification request
                    UNUserNotificationCenter.current().add(request)
                }
            } catch {
                print("Failed to snooze task: \(error)")
            }
        }
    }
}
