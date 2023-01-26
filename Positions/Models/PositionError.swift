//
//  PositionError.swift
//  Positions
//
//  Created by Petrov Anton on 24.01.2023.
//

import Foundation

enum PositionError: Error {
    case wrongDataFormat(error: Error)
    case missingData
    case requestFailed
    case decodingFailed(error: Error)
    case creationError
    case batchInsertError
    case batchDeleteError
    case persistentHistoryChangeError
    case unexpectedError(error: Error)
}

extension PositionError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .wrongDataFormat(let error):
            return NSLocalizedString("Could not digest the fetched data. \(error.localizedDescription)", comment: "")
        case .missingData:
            return NSLocalizedString("Found and will discard a quake missing a valid code, magnitude, place, or time.", comment: "")
        case .creationError:
            return NSLocalizedString("Failed to create a new Quake object.", comment: "")
        case .batchInsertError:
            return NSLocalizedString("Failed to execute a batch insert request.", comment: "")
        case .batchDeleteError:
            return NSLocalizedString("Failed to execute a batch delete request.", comment: "")
        case .persistentHistoryChangeError:
            return NSLocalizedString("Failed to execute a persistent history change request.", comment: "")
        case .unexpectedError(let error):
            return NSLocalizedString("Received unexpected error. \(error.localizedDescription)", comment: "")
        case .requestFailed:
            return NSLocalizedString("Request failed.", comment: "")
        case let .decodingFailed(error):
            return NSLocalizedString("Decoding failed \(error.localizedDescription)", comment: "")
        }
    }
}

extension PositionError: Identifiable {
    var id: String? {
        errorDescription
    }
}
