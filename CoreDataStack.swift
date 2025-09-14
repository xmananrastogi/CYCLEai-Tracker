//
//  CoreDataStack.swift
//  CYCLEai-Tracker
//
//  Created by Manan Rastogi on 15/09/25.
//

import Foundation
import CoreData

class CoreDataStack {
    
    // MARK: - Properties
    
    /// The persistent container that encapsulates the Core Data stack in the application.
    let container: NSPersistentContainer
    
    /// A convenient accessor for the main thread's managed object context.
    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    // MARK: - Initializer
    
    /// Private initializer to set up the persistent container.
    /// - Parameter modelName: The name of your `.xcdatamodeld` file.
    init(modelName: String = "CYCLEai_Tracker") {
        container = NSPersistentContainer(name: modelName)
    }
    
    // MARK: - Methods
    
    /// Loads the persistent stores. This must be called before the stack can be used.
    func loadPersistentStore() {
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                // This is a critical error. In a production app, you would
                // handle this more gracefully than crashing.
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }

    /// Saves changes in the main context if there are any.
    func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                let nserror = error as NSError
                // This is a critical error.
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
