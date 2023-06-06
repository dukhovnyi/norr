//
//  History+Live.swift
//  noor
//
//  Created by Yurii Dukhovnyi on 30.04.2023.
//

import Combine
import CoreData
import Foundation

extension History {

    static func live(
        persistentContainerName name: String
    ) -> Self {

        let coreData = CoreDataManager(name: name)
        let updatePublisher = PassthroughSubject<Update, Never>()

        return History(
            updates: { updatePublisher.eraseToAnyPublisher() },
            fetchAll: {
                fetchAll(coreData: coreData)
            },
            append: { item in

                defer { updatePublisher.send(.append([item])) }

                coreData.context.addPaste(item)
                do {
                    try coreData.context.saveIfNeeded()
                } catch {
                    debugPrint("🔥 Saving item='\(item.id)' has been failed with error='\(error)'.")
                }

            },
            remove: { item in
                let ids = Self.remove(coreData: coreData, predicate: .init(format: "id = %@", item.id))
                updatePublisher.send(.remove(ids))
            },
            removeWithPredicate: { predicate in
                let ids = Self.remove(coreData: coreData, predicate: predicate)
                updatePublisher.send(.remove(ids))
            },
            update: { item in

                let request = PasteModel.fetchRequest()
                request.predicate = .init(format: "id = %@", item.id)

                do {
                    let items = try coreData.context.fetch(request)
                    items.forEach {
                        $0.isBolted = item.isBolted
                    }
                    let saveResult = try coreData.context.saveIfNeeded()
                    if !saveResult {
                        debugPrint("⚠️ Updating item='\(item.id)', context has not been saved.")
                    }

                    updatePublisher.send(.update(items.map { $0.asPaste() }))
                } catch {
                    debugPrint("🔥 Updating item='\(item.id)' has been failed with error='\(error)'.")
                }
            },
            wipe: {
                do {
                    updatePublisher.send(.removeAll)
                    try coreData.wipe()
                } catch {
                    debugPrint("🔥 Wiping data has been failed with error='\(error)'.")
                }
            }
        )
    }

    static func fetchAll(coreData: CoreDataManager) -> [Paste] {

        let request: NSFetchRequest<PasteModel> = PasteModel.fetchRequest()
        request.sortDescriptors = [.init(key: "createdAt", ascending: false)]
        do {
            return try coreData.context.fetch(request).map { $0.asPaste() }
        } catch {
            debugPrint("🔥 Fetching items has been failed with error='\(error)'.")
            return []
        }
    }

    static func remove(coreData: CoreDataManager, predicate: NSPredicate) -> [String] {

        let request: NSFetchRequest<PasteModel> = PasteModel.fetchRequest()
        request.predicate = predicate
        do {
            let result = try coreData.context.fetch(request)
            let ids = result.compactMap(\.id)
            result.forEach { coreData.context.delete($0) }
            try coreData.context.saveIfNeeded()

            return ids
        } catch {
            debugPrint("🔥 Fetching items has been failed with error='\(error)'.")
            return []
        }
    }
}

extension NSManagedObjectContext {

    /// Only performs a save if there are changes to commit.
    /// - Returns: `true` if a save was needed. Otherwise, `false`.
    @discardableResult func saveIfNeeded() throws -> Bool {
        guard hasChanges else { return false }
        try save()
        return true
    }
}

private extension PasteModel {

    func asPaste() -> Paste {

        .init(
            id: self.id ?? UUID().uuidString,
            changeCount: Int(self.changeCount),
            createdAt: self.createdAt ?? .now,
            contents: mapToPasteContents(self.pasteContents ?? []),
            bundleId: self.bundleId,
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
        newItem.bundleId = paste.bundleId
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
