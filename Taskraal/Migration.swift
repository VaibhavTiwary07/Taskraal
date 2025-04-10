//
// Migration.swift
// Taskraal
//
// Created by Vaibhav Tiwary on 12/04/25.
//

/* 
 Core Data Model Updates for Scheduling Integration
 
 Updates needed to the Task entity:
 
 1. Add new attributes to the Task entity:
    - calendarEventIdentifier (String, optional)
    - reminderIdentifier (String, optional)
    - notificationIdentifier (String, optional)
 
 These identifiers will store references to the Calendar events, Reminders, and Notifications
 created for each task, allowing the app to update or delete them as needed when the task
 changes.
 
 How to perform these updates:
 
 1. Open the Core Data model editor (Taskraal.xcdatamodeld)
 2. Select the Task entity
 3. Add the following attributes:
    - calendarEventIdentifier (Type: String, Optional: YES)
    - reminderIdentifier (Type: String, Optional: YES)
    - notificationIdentifier (Type: String, Optional: YES)
 4. Save the model
 
 No migration code is needed since these are optional attributes being added to an existing
 model, which is a lightweight migration that Core Data can handle automatically.
 
 Note: The CoreDataManager should have the option to automatically perform lightweight migrations:
 
 ```swift
 let options = [
     NSMigratePersistentStoresAutomaticallyOption: true,
     NSInferMappingModelAutomaticallyOption: true
 ]
 
 container.loadPersistentStores(with: options) { ... }
 ```
 
 This ensures that when the app is updated with the new Core Data model, existing data will
 be migrated automatically without any additional code.
*/
