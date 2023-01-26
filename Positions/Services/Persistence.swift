//
//  Persistence.swift
//  Positions
//
//  Created by Petrov Anton on 24.01.2023.
//

import CoreData
import OSLog

protocol PersistenceController {
    var inMemory: Bool { get }
    var container: NSPersistentContainer { get }
    
    func getNewBackgroundContext() -> NSManagedObjectContext
}

final class AppPersistenceController: PersistenceController {
    static let shared = AppPersistenceController()
    
    private let logger = Logger(subsystem: "com.PAM.Positions", category: "Persistence")

    static var preview: PersistenceController = {
        let result = AppPersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let newItem = Position(context: viewContext)
            newItem.code = UUID().uuidString
            newItem.time = Date()
            newItem.magnitude = Float((0...5).randomElement()!)
            newItem.place = "Place"
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    private(set) var inMemory: Bool
    private(set) lazy var container: NSPersistentContainer = {
        logger.debug("🚀Start create NSPersistentContainer")
        let container = NSPersistentContainer(name: "Positions")
        
        guard let description = container.persistentStoreDescriptions.first
        else { fatalError("Failed to retrieve a persistent store description.") }
        
        if inMemory {
            description.url = URL(fileURLWithPath: "/dev/null")
        }
        
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = false
        container.viewContext.name = "viewContext"
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.undoManager = nil
        container.viewContext.shouldDeleteInaccessibleFaults = true
        
        logger.debug("🏁Finish create NSPersistentContainer")
        return container
    }()

    init(inMemory: Bool = false) {
        self.inMemory = inMemory
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didChangeStore(_:)),
            name: .NSPersistentStoreRemoteChange,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .NSPersistentStoreRemoteChange, object: nil)
    }

    final func getNewBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.undoManager = nil
        logger.debug("🆕Create new background context")
        return context
    }
    
    // MARK: - Fetch History
    /// A peristent history token used for fetching transactions from the store.
    private var lastToken: NSPersistentHistoryToken?
    
    @objc private func didChangeStore(_ notification: Notification) {
        let name = notification.name.rawValue
        Task {
            logger.debug("Recive notification about 'NSPersistentStoreRemoteChange' Name: \(name)")
            await mergeLastHistoryChanges()
        }
    }
    
    private func mergeLastHistoryChanges() async {
        do {
            try await fetchLastHistory()
        } catch {
            logger.debug("🛑 Error fetchLastHistory: \(error)")
        }
    }
    
    private func fetchLastHistory() async throws {
        let bgContext = getNewBackgroundContext()
        bgContext.name = "UniqueFetchHistory"
        bgContext.transactionAuthor = "UniqueFetchHistory"
        
        try await bgContext.perform {
            self.logger.debug("Start fetching history")
            let changeRequest = NSPersistentHistoryChangeRequest.fetchHistory(after: self.lastToken)
            let historyResult = try bgContext.execute(changeRequest) as? NSPersistentHistoryResult
            if let history = historyResult?.result as? [NSPersistentHistoryTransaction],
               !history.isEmpty {
                self.logger.debug("Recive fetched history")
                self.mergeHistoryTransactions(history)
                return
            }

            self.logger.debug("No persistent history transactions found.")
            throw PositionError.persistentHistoryChangeError
        }
    }
    
    private func mergeHistoryTransactions(_ transactions: [NSPersistentHistoryTransaction]) {
        let context = container.viewContext
        
        context.perform {
            self.logger.debug("Start merge to main contex")
            for transaction in transactions {
                context.mergeChanges(fromContextDidSave: transaction.objectIDNotification())
                self.lastToken = transaction.token
            }
            self.logger.debug("Finish merged to the main contex. Last token: \(self.lastToken.debugDescription)")
        }
    }
}
