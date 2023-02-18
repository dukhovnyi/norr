//
//  CoreDataStack.swift
//  Pasteboard
//
//  Created by Yurii Dukhovnyi on 13.02.2023.
//

import CoreData
import Foundation

class CoreDataStack {

    init(modelName: String = "PasteboardHistory") {
        self.modelName = modelName
    }

    lazy var managedContext: NSManagedObjectContext = self.storeContainer.viewContext

    func saveContext() {

        guard managedContext.hasChanges else {
            print("No changes detected.")
            return
        }

        do {

            try managedContext.save()

        } catch let error as NSError {

            print("Unresolved error \(error), \(error.userInfo)")
        }
    }

    // MARK: - Private

    private let modelName: String

    private lazy var storeContainer: NSPersistentContainer = {

        let container = NSPersistentContainer(name: modelName)
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
}
