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
        managing: CoreDataManaging,
        preferencesManaging: PreferencesManaging
    ) -> Self {

        var cache = readFromDb(coreData: managing)
        let updateSubj = PassthroughSubject<Update, Never>()

        return Self(
            updates: { updateSubj.eraseToAnyPublisher() },
            cache: { cache.sorted { $0.createdAt > $1.createdAt} },
            save: { item in

                defer { 
                    try? managing.save()
                }

                updateSubj.send(.append(item))
                cache.append(item)

                // Add a new paste item to context
                managing.container().viewContext.addPaste(item)

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
                    let deletion = try managing.container().viewContext.fetch(fetchRequest)
                    deletion.forEach {
                        let paste = $0.asPaste()
                        cache.removeAll(where: { $0.id == paste.id })
                        updateSubj.send(.remove(paste))
                        managing.container().viewContext.delete($0)
                    }
                } catch {
                    print("🔥 can't delete items from CoreData. Error='\(error)'.")
                }
            },
            remove: { item in
                defer {
                    try? managing.save()
                }

                let fetchRequest = NSFetchRequest<PasteModel>(entityName: "PasteModel")
                fetchRequest.predicate = .init(format: "id == %@", item.id)

                do {
                    let deletion = try managing.container().viewContext.fetch(fetchRequest)
                    deletion.forEach {
                        let paste = $0.asPaste()
                        cache.removeAll(where: { $0.id == paste.id })
                        updateSubj.send(.remove(paste))
                        managing.container().viewContext.delete($0)
                    }
                } catch {
                    print("🔥 can't delete items from CoreData. Error='\(error)'.")
                }

            },
            clean: {
                Self.clean(managing: managing)
                updateSubj.send(.removeAll)
                cache.removeAll()
            },
            pin: { paste in
                guard let pasteModel = findFirst(paste: paste, managing: managing) else { return }
                pasteModel.isBolted = true
                var pinnedPaste = paste
                pinnedPaste.isBolted = true
                updateSubj.send(.update(pinnedPaste))
                try? managing.save()
            },
            unpin: { paste in
                guard let pasteModel = findFirst(paste: paste, managing: managing) else { return }
                pasteModel.isBolted = false
                var unpinnedPaste = paste
                unpinnedPaste.isBolted = false
                updateSubj.send(.update(unpinnedPaste))
                try? managing.save()
            }
        )
    }

    /// Read all paste models form db
    ///
    private static func readFromDb(coreData: CoreDataManaging) -> [Paste] {

        do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PasteModel")
            fetchRequest.sortDescriptors = [
                .init(key: "createdAt", ascending: true)
            ]
            return try coreData.fetch(request: fetchRequest)
                .compactMap { ($0 as? PasteModel)?.asPaste() }

        } catch {
            print("🔥 Initial cache has not been retrieved with error='\(error)'.")
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

    private static func clean(managing: CoreDataManaging) {

        do {
            let all = try managing.fetch(fetchRequestTemplate: "UserInitiatedCleanUp").compactMap { $0 as? PasteModel }
            all.forEach { managing.container().viewContext.delete($0) }
            try managing.container().viewContext.save()
        } catch {
            print("🔥 Clean has not been happen. Error='\(error)'.")
        }
    }

    private static func findFirst(paste: Paste, managing: CoreDataManaging) -> PasteModel? {

        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PasteModel")
            request.predicate = .init(format: "id = %@", paste.id)
            return try managing.fetch(request: request).first as? PasteModel
        } catch {
            print("🔥 Can't find paste with id='\(paste.id)'. Error='\(error)'.")
            return nil
        }
    }
}

private extension PasteModel {

    func asPaste() -> Paste {

        .init(
            id: self.id ?? UUID().uuidString,
            changeCount: Int(self.changeCount),
            createdAt: self.createdAt ?? .now,
            contents: mapToPasteContents(self.pasteContents ?? []),
            bundleUrl: self.bundleURL,
            isBolted: isBolted
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

extension NSManagedObjectContext {

    /// Converts `Paste` to `PasteModel` and add object to current context
    ///
    func addPaste(_ paste: Paste) {

        let newItem = PasteModel(context: self)
        newItem.createdAt = Date.now
        newItem.id = paste.id
        newItem.changeCount = Int64(paste.changeCount)
        newItem.bundleURL = paste.bundleUrl
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
