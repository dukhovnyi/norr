//
//  HistoryManaging+CoreData.swift
//  Pasteboard
//
//  Created by Yurii Dukhovnyi on 17.02.2023.
//

import Combine
import CoreData
import Foundation

extension HistoryManaging {

    static func coreData(
        preferencesManaging: PreferencesManaging
    ) -> Self {

        let coreData = CoreDataStack()
        var cache = readFromDb(moc: coreData.managedContext)
        let updateSubj = PassthroughSubject<Update, Never>()

        return Self(
            update: { updateSubj.eraseToAnyPublisher() },
            cache: { cache },
            save: { item in

                defer { coreData.saveContext() }

                updateSubj.send(.insert(item))
                cache.insert(item, at: 0)

                // Add a new paste item to context
                coreData.managedContext.addPaste(item)

                let storageCapacity = preferencesManaging.current().storageCapacity
                // verify is allowed capacity achieved
                guard storageCapacity < cache.count else { return }

                // create fetch request for all entity, sort them ascending, and set
                //  limit for item over capacity.
                let fetchRequest = NSFetchRequest<PasteModel>(entityName: "PasteModel")
                fetchRequest.sortDescriptors = [
                    .init(key: "createdAt", ascending: true)
                ]
                fetchRequest.fetchLimit = cache.count - storageCapacity

                do {
                    let deletion = try coreData.managedContext.fetch(fetchRequest)

                    print("found \(deletion.count) \(deletion.map { $0.asPaste().stringRepresentation })")
                    deletion.forEach {
                        let paste = $0.asPaste()
                        cache.removeAll(where: { $0.id == paste.id })
                        updateSubj.send(.remove(paste))
                        coreData.managedContext.delete($0)
                    }
                } catch {
                    print("🔥 can't delete items from CoreData. Error='\(error)'.")
                }
            },
            clean: {
                Self.clean(moc: coreData.managedContext)
                updateSubj.send(.removeAll)
                cache.removeAll()
            }
        )
    }

    /// Read all paste models form db
    ///
    private static func readFromDb(moc: NSManagedObjectContext) -> [Paste] {

        do {

            let fetchRequest = NSFetchRequest<PasteModel>(entityName: "PasteModel")
            fetchRequest.sortDescriptors = [
                .init(key: "createdAt", ascending: false)
            ]
            return try moc.fetch(fetchRequest).map { $0.asPaste() }

        } catch {
            print("Initial cache has not been retrieved with error='\(error)'.")
            return []
        }
    }

    /// Saves paste into db
    ///
    private static func savePaste(
        paste: Paste,
        moc: NSManagedObjectContext,
        save: () throws -> Void
    ) {

        do {
            moc.addPaste(paste)
            try save()
        } catch {
            print("🔥 Items have not been saved to context. Error='\(error)'.")
        }
    }

    private static func clean(moc: NSManagedObjectContext) {

        let fetchRequest = NSFetchRequest<PasteModel>(entityName: "PasteModel")

        do {
            let all = try moc.fetch(fetchRequest)
            all.forEach { moc.delete($0) }
            try moc.save()
        } catch {
            print("🔥 Clean has not been happen. Error='\(error)'.")
        }
    }
}

private extension PasteModel {

    func asPaste() -> Paste {

        .init(
            id: self.id ?? UUID().uuidString,
            changeCount: Int(self.changeCount),
            createdAt: self.createdAt ?? .now,
            contents: mapToPasteContents(self.pasteContents ?? [])
        )
    }

    func mapToPasteContents(_ set: NSSet) -> [Paste.Content] {

        set.compactMap {
            guard
                let item = $0 as? PasteContentModel,
                let rawType = item.type
            else { return nil }
            return .init(type: .init(rawType), value: item.data)
        }
    }
}

private extension NSManagedObjectContext {

    /// Converts `Paste` to `PasteModel` and add object to current context
    ///
    func addPaste(_ paste: Paste) {

        let newItem = PasteModel(context: self)
        newItem.createdAt = Date.now
        newItem.id = paste.id
        newItem.changeCount = Int64(paste.changeCount)
        paste.contents.forEach {
            let content = PasteContentModel(context: self)
            content.type = $0.type.rawValue
            content.data = $0.value
            newItem.addToPasteContents(content)
        }
    }
}

public extension NSManagedObject {

    convenience init(context: NSManagedObjectContext) {
        let name = String(describing: type(of: self))
        let entity = NSEntityDescription.entity(forEntityName: name, in: context)!
        self.init(entity: entity, insertInto: context)
    }

}
