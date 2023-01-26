//
//  PositionsRepository.swift
//  Positions
//
//  Created by Petrov Anton on 26.01.2023.
//

import CoreData
import OSLog

protocol PositionsRepository {
    func importPositions(_ items: [PositionDTO]) async throws
    func deletePosition(by itemIds: [NSManagedObjectID])
    func deletePosition(_ items: [Position]) async throws
}

struct PositionsRepositoryImpl: PositionsRepository {
    
    let persistenceController: PersistenceController
    
    private let logger = Logger(subsystem: "com.PAM.Positions", category: "Repository")
    
    func importPositions(_ items: [PositionDTO]) async throws {
        self.logger.debug("Start 0 insert positions")
        guard !items.isEmpty else { return }
        let bgContext = persistenceController.getNewBackgroundContext()
        
        bgContext.name = "Import Positions"
        bgContext.transactionAuthor = "Import Positions"
        
        try await bgContext.perform {
            self.logger.debug("Start insert positions")
            let batch = NSBatchInsertRequest(entity: Position.entity(), objects: items.map(\.dictionaryValue))
            if let result = try? bgContext.execute(batch),
               let batchResult = result as? NSBatchInsertResult,
               let success = batchResult.result as? Bool, success {
                self.logger.debug("Finish insert positions")
                return
            } else {
                self.logger.debug("Finish insert with error")
                throw PositionError.batchInsertError
            }
        }
    }
    
    func deletePosition(by itemIds: [NSManagedObjectID]) {
        self.logger.debug("Start 0 delete positions \(itemIds)")
        guard !itemIds.isEmpty else { return }
        let context = persistenceController.container.viewContext
        
        context.perform {
            self.logger.debug("Start delete positions")
            itemIds.forEach {
                let obj = context.object(with: $0)
                context.delete(obj)
                try? context.save()
            }
            self.logger.debug("Finish delete positions")
        }
    }
    
    func deletePosition(_ items: [Position]) async throws {
        guard !items.isEmpty else { return }
        let objectIDs = items.map(\.objectID)
        self.logger.debug("Start 0 delete positions \(objectIDs)")
        let bgContext = persistenceController.getNewBackgroundContext()
        
        bgContext.name = "Delete Positions"
        bgContext.transactionAuthor = "Delete Positions"
        
        try await bgContext.perform {
            // Execute the batch delete.
            self.logger.debug("Start delete positions")
            let batchDeleteRequest = NSBatchDeleteRequest(objectIDs: objectIDs)
            guard let fetchResult = try? bgContext.execute(batchDeleteRequest),
                  let batchDeleteResult = fetchResult as? NSBatchDeleteResult,
                  let success = batchDeleteResult.result as? Bool, success
            else {
                self.logger.debug("Failed to execute batch delete request.")
                throw PositionError.batchDeleteError
            }
            self.logger.debug("Finish delete positions")
        }
    }
}
