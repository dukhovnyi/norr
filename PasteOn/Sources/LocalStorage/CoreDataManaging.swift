//
//  CoreDataManaging.swift
//  Pasteboard
//
//  Created by Yurii Dukhovnyi on 13.02.2023.
//

import CoreData
import Foundation

struct CoreDataManaging {

    let container: () -> NSPersistentContainer
    let save: () throws -> Void

    func fetch(request: NSFetchRequest<NSFetchRequestResult>) throws -> [NSFetchRequestResult] {
        try container().viewContext.fetch(request)
    }

    func fetch(fetchRequestTemplate name: String) throws -> [NSFetchRequestResult] {

        guard let request = container().managedObjectModel.fetchRequestTemplate(forName: name) else {
            assertionFailure("Fetch request template doesn't exist.")
            return []
        }

        return try fetch(request: request)
    }
}

extension CoreDataManaging {

    static func live(
        name: String
    ) -> Self {

        let container = NSPersistentContainer(name: name)
        container.loadPersistentStores { desc, error in
            if let error = error as NSError? {
                debugPrint("🔥 Unresolved error='\(error)', \(error.userInfo)")
            }
        }

        return .init(
            container: { container },
            save: {
                try container.viewContext.save()
            }
        )
    }
}
