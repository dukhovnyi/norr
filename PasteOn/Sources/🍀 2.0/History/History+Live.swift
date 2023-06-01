//
//  History+Live.swift
//  PasteOn
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

                defer { updatePublisher.send(.remove([item.id])) }

                let request = PasteModel.fetchRequest()
                request.predicate = .init(format: "id = %@", item.id)

                let deleteRequest = NSBatchDeleteRequest(fetchRequest: request as! NSFetchRequest<NSFetchRequestResult>)

                do {
                    try coreData.context.execute(deleteRequest)
                    try coreData.context.saveIfNeeded()
                } catch {
                    debugPrint("🔥 Removing item='\(item.id)' has been failed with error='\(error)'.")
                }
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
