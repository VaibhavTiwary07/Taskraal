//
//  CoreDataManager.swift
//  Taskraal
//
//  Created by Vaibhav Tiwary on 04/04/25.
//

import Foundation
import CoreData

class CoreDataManager {
    
    // MARK: - Shared Instance (Singleton)
    static let shared = CoreDataManager()
    
    // MARK: - Initialization
    private init() {}
    
    // MARK: - Core Data Stack
    lazy var persistentContainer: NSPersistentContainer = {
        // Make sure "Taskraal" matches your .xcdatamodeld filename
        let container = NSPersistentContainer(name: "Taskraal")
        
        // Set up the description to enable automatic migrations
        let description = NSPersistentStoreDescription()
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        
        // Set the persistent store descriptions
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // You can handle errors here - typically you'd want to
                // inform the user that something went wrong
                print("Core Data store failed to load: \(error.localizedDescription)")
                print("Detailed error: \(error), \(error.userInfo)")
            }
        })
        
        // For better performance with background operations
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return container
    }()
    
    // MARK: - Core Data Context
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Core Data Saving
    func saveContext() {
        let context = viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                print("Could not save Core Data context: \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Task Functions
    func createTask(title: String, details: String? = nil, dueDate: Date? = nil, priority: PriorityLevel = .medium, category: NSManagedObject? = nil) -> NSManagedObject? {
        let context = viewContext
        
        guard let taskEntity = NSEntityDescription.entity(forEntityName: "Task", in: context) else {
            print("Failed to get Task entity")
            return nil
        }
        
        let task = NSManagedObject(entity: taskEntity, insertInto: context)
        
        // Set task properties
        task.setValue(UUID(), forKey: "id")
        task.setValue(title, forKey: "title")
        task.setValue(details, forKey: "details")
        task.setValue(dueDate, forKey: "dueDate")
        task.setValue(Date(), forKey: "createdAt")
        task.setValue(false, forKey: "isCompleted")
        task.setValue(Int16(priority.rawValue), forKey: "priorityLevel")
        
        if let category = category {
            task.setValue(category, forKey: "category")
        }
        
        // Save the context
        saveContext()
        return task
    }
    
    func fetchTasks(completed: Bool? = nil, category: NSManagedObject? = nil) -> [NSManagedObject] {
        let context = viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Task")
        
        // Add predicates if needed
        var predicates: [NSPredicate] = []
        
        if let completed = completed {
            predicates.append(NSPredicate(format: "isCompleted == %@", NSNumber(value: completed)))
        }
        
        if let category = category {
            predicates.append(NSPredicate(format: "category == %@", category))
        }
        
        if !predicates.isEmpty {
            let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            fetchRequest.predicate = compoundPredicate
        }
        
        // Sort the results
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "isCompleted", ascending: true),
            NSSortDescriptor(key: "dueDate", ascending: true),
            NSSortDescriptor(key: "createdAt", ascending: false)
        ]
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching tasks: \(error)")
            return []
        }
    }
    
    func updateTask(_ task: NSManagedObject, title: String? = nil, details: String? = nil,
                    dueDate: Date? = nil, priority: PriorityLevel? = nil,
                    isCompleted: Bool? = nil, category: NSManagedObject? = nil) {
        
        if let title = title {
            task.setValue(title, forKey: "title")
        }
        
        if let details = details {
            task.setValue(details, forKey: "details")
        }
        
        if let dueDate = dueDate {
            task.setValue(dueDate, forKey: "dueDate")
        }
        
        if let priority = priority {
            task.setValue(Int16(priority.rawValue), forKey: "priorityLevel")
        }
        
        if let isCompleted = isCompleted {
            task.setValue(isCompleted, forKey: "isCompleted")
        }
        
        if let category = category {
            task.setValue(category, forKey: "category")
        }
        
        saveContext()
    }
    
    func deleteTask(_ task: NSManagedObject) {
        viewContext.delete(task)
        saveContext()
    }
    
    // MARK: - Category Functions
    func createCategory(name: String, colorHex: String = "#0A84FF") -> NSManagedObject? {
        let context = viewContext
        
        guard let categoryEntity = NSEntityDescription.entity(forEntityName: "Category", in: context) else {
            print("Failed to get Category entity")
            return nil
        }
        
        let category = NSManagedObject(entity: categoryEntity, insertInto: context)
        
        // Set category properties
        category.setValue(UUID(), forKey: "id")
        category.setValue(name, forKey: "name")
        category.setValue(colorHex, forKey: "colorHex")
        
        // Save the context
        saveContext()
        return category
    }
    
    func fetchCategories() -> [NSManagedObject] {
        let context = viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Category")
        
        // Sort by name
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching categories: \(error)")
            return []
        }
    }
    
    func updateCategory(_ category: NSManagedObject, name: String? = nil, colorHex: String? = nil) {
        if let name = name {
            category.setValue(name, forKey: "name")
        }
        
        if let colorHex = colorHex {
            category.setValue(colorHex, forKey: "colorHex")
        }
        
        saveContext()
    }
    
    func deleteCategory(_ category: NSManagedObject) {
        viewContext.delete(category)
        saveContext()
    }
    
    // MARK: - Helper Functions
    func count(for entityName: String, predicate: NSPredicate? = nil) -> Int {
        let context = viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        fetchRequest.predicate = predicate
        
        do {
            return try context.count(for: fetchRequest)
        } catch {
            print("Error counting \(entityName): \(error)")
            return 0
        }
    }
    
    func markTaskAsCompleted(_ task: NSManagedObject, isCompleted: Bool) {
        // Set completion status
        task.setValue(isCompleted, forKey: "isCompleted")
        
        // If marking as completed, set the completion date
        if isCompleted {
            task.setValue(Date(), forKey: "completedAt")
        } else {
            // If marking as incomplete, remove the completion date
            task.setValue(nil, forKey: "completedAt")
        }
        
        // Save context
        saveContext()
    }
}
