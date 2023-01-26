//
//  PositionsProvider.swift
//  Positions
//
//  Created by Petrov Anton on 24.01.2023.
//

import Foundation
import OSLog

protocol PositionsProvider {
    func fetchPositions() async throws -> [PositionDTO]
}

struct PositionsProviderImpl: PositionsProvider {
    let networkManager: NetworkManager
    
    private let url = URL(string: "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_month.geojson")!
    private let logger = Logger(subsystem: "com.PAM.Positions", category: "Provider")
    
    func fetchPositions() async throws -> [PositionDTO] {
        logger.debug("Start fetching positions from server")
        let geo: GeoJSON = try await networkManager.perform(url: url)
        logger.debug("Finish fetched positions from server")
        return geo.positionList
    }
    
}
