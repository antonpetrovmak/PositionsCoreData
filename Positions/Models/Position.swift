//
//  Position.swift
//  Positions
//
//  Created by Petrov Anton on 24.01.2023.
//
//

import Foundation
import CoreData
import SwiftUI

@objc(Position)
public class Position: NSManagedObject, Identifiable {
    
    public enum Keys {
        static let time = "time"
    }
    
    @NSManaged public var canonicalPlace: Float
    @NSManaged public var magnitude: Float
    @NSManaged public var code: String
    @NSManaged public var time: Date
    @NSManaged public var place: String

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Position> {
        return NSFetchRequest<Position>(entityName: "Position")
    }
}

extension Position {
    
    /// The color which corresponds with the quake's magnitude.
    var color: Color {
        switch magnitude {
        case 0..<1:
            return .green
        case 1..<2:
            return .yellow
        case 2..<3:
            return .orange
        case 3..<5:
            return .red
        case 5..<Float.greatestFiniteMagnitude:
            return .init(red: 0.8, green: 0.2, blue: 0.7)
        default:
            return .gray
        }
    }
    
    /// An earthquake for use with canvas previews.
    static var previewInstance: Position {
        let positions = Position.makePreviews(count: 1)
        return positions[0]
    }

    @discardableResult
    static func makePreviews(count: Int) -> [Position] {
        var quakes = [Position]()
        let viewContext = AppPersistenceController.preview.container.viewContext
        for index in 0..<count {
            let quake = Position(context: viewContext)
            quake.code = UUID().uuidString
            quake.time = Date().addingTimeInterval(Double(index) * -300)
            quake.magnitude = .random(in: -1.1...10.0)
            quake.place = "15km SSW of Cupertino, CA"
            quakes.append(quake)
        }
        return quakes
    }
}
