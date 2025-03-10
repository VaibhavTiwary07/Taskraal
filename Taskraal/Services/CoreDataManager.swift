//
//  CoreDataManager.swift
//  Taskraal
//
//  Created by Vaibhav  Tiwary on 10/03/25.
//

import Foundation
import CoreData

class CoreDataManager{
    static let shared = CoreDataManager()
    
    private init(){
        
    }
    
    lazy var persistenceCointainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Taskraal")
        container.loadPersistentStores{ description,error in
            if let error = error{
                fatalError("Unable to load persistent store:\(error)")
            }
        }
        
        return container;
    }()
    
    var viewContext: NSManagedObjectContext{
        return persistenceCointainer.viewContext
    }
    
    func saveContext(){
        let context =  persistenceCointainer.viewContext
        if context.hasChanges{
            do{
                try context.save()
            }catch{
                let nserror = error as NSError
                fatalError("Unresolved error\(nserror),\(nserror.userInfo)")
            }
            
        }
    }
}
