//
//  PositionsUseCase.swift
//  Positions
//
//  Created by Petrov Anton on 26.01.2023.
//

import CoreData
import OSLog

protocol PositionsUseCase {
    
    
    func uploadPositions() async throws
    func deletePosition(by itemIds: [NSManagedObjectID])
    func deletePosition(_ items: [Position]) async throws
}

struct PositionsUseCaseImpl: PositionsUseCase {
    
    let positionsRepository: PositionsRepository
    let positionsProvider: PositionsProvider
    
    private let logger = Logger(subsystem: "com.PAM.Positions", category: "PositionsUseCase")
    
    func uploadPositions() async throws {
        self.logger.debug("Start upload positions")
        let dtoPositions = try await positionsProvider.fetchPositions()
        try await positionsRepository.importPositions(dtoPositions)
        self.logger.debug("Finish upload positions")
    }
    
    func deletePosition(by itemIds: [NSManagedObjectID]) {
        positionsRepository.deletePosition(by: itemIds)
    }
    
    func deletePosition(_ items: [Position]) async throws {
        try await positionsRepository.deletePosition(items)
    }
    
}
